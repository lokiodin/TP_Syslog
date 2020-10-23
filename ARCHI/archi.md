# Architecture logs management M&A Inc.
> Auteurs :
>   David DESCHAMPS
>
>   David MONTEIRO
>
>   Théo LAW BO KANG
>
>   Théo SIGARI
>
>   Romain BOIREAU


## Vocabulaire

| Mot utilisé | Explication |
| ------------------------- | ------------------------- |
| SB | Site de Backup |
| SP | Site Principal |
| SD | Site de Dévolution |
| SA | Site Autonome |
| SL | Site Local |
| SM | Site Mobile  |
| relay-[SB/SP/SD/SA/SL/SM] | Serveur Syslog du site en question |


## Contexte

> Vous avez été mandaté par l'entreprise Mercenaires & Associés Inc. (M&A Inc.) pour rénover le système de rénovation.
> Le client vous a donné les schémas de leur infrastructure actuelle.


## Architecture actuelle
Schéma de l'implantation des sites :
![Figure 1](schema_infra_implantation_sites.png "Schéma de l'implantation des sites de M&A Inc.")

Schéma de principe :
![Figure 2](schema_principe.png "Schéma de principe M&A Inc.")


### Architecture et solutions choisies

Nous avons choisi de respecter la hiérarchie entre les sites suivantes :
* Les relay-SL envoient les logs aux relay-SA,
* Les relay-SA envoient les logs au relay-SP,
* Les relay-SM envoient les logs au relay-SP,
* Le relay-SP réplique ses logs au relay-SD,
* Les relay-SP et relay-SD envoient leurs logs au relay-SB pour la sauvegardes des logs.
Le coeur syslog est donc le site ``SP``. ``SD`` étant en réplication et ``SB`` le site de backup.

Les envois de logs se font en TCP sur le port 6514, chiffrés en TLS/SSL. Pour cela il faut diposer d'une infrastructure CA.

#### Partie CA

Pour tester l'architecture, nous avons utilisé l'outil `openssl`.
Voici un example des commandes :
```sh
$ cd CA
$ mkdir certs crl newcerts private
$ echo "01" > serial
$ cp /dev/null index.txt
$ cp /etc/ssl/openssl.cnf openssl.cnf
# Changer la ligne
# [ CA_default ]
# dir             = ./demoCA              # Where everything is kept
# certs           = $dir/certs            # Where the issued certs are kept
# en 
# [ CA_default ]
# dir             = .                     # Where everything is kept
# certs           = $dir/certs            # Where the issued certs are kept

# Generer le certificat de la CA
$ openssl req -new -x509 -keyout private/cakey.pem -out cacert.pem -days 365 -config openssl.cnf

# Generer les certificat des clients
$ nomSite=relay-sa
$ openssl req -nodes -new -x509 -keyout $nomSitekey.pem -out $nomSitereq.pem -days 365 -config openssl.cnf
$ openssl x509 -x509toreq -in $nomSitereq.pem -signkey $nomSitekey.pem -out tmp$nomSite.pem
$ openssl ca -config openssl.cnf -policy policy_anything -out $nomSitecert.pem -infiles tmp$nomSite.pem
$ rm tmp$nomSite.pem
```

**Attention** : Ne pas oublier lors de changement du certificat :
```sh
$ ln -s /etc/syslog-ng/ca.d/cacert.pem /etc/syslog-ng/ca.d/$(openssl x509 -noout -hash -in /etc/syslog-ng/ca.d/cacert.pem).0
```

Il faut mettre les fichiers ``$nomSitekey.pem`` et ``$nomSitecert.pem`` dans le répertoire ``/etc/syslog-ng/cert.d/`` et ``cakey.pem`` dans le répertoire ``/etc/syslog-ng/ca.d/``.

#### Partie sauvegarde des logs

Les logs enregistrés en local seront tous sauvegardés dans le répertoire parent ``/var/log/syslog-ng/``, dans le répertoire ``ANNEE.MOI.JOUR/``. Il y aura donc un répertoire par jour dans le dossier ``/var/log/syslog-ng/``. Enfin, un fichier log sera enregistré par site.
Dans le cas du site de backup, un dossier ``/var/log/syslog-ng/archive`` sera créé et les logs compressés seront dans celui-ci.

Par exemple nous pourrions retrouver l'arborescence ci-dessous sur un ``SA`` :
```sh
$ tree /var/log/syslog-ng/
/var/log/syslog-ng
├── 2020.10.22
│   ├── logs_SA-QUEBEC.log
│   ├── logs_SL-NYC.log
│   └── logs_SL-RIO.log
└── 2020.10.23
    ├── logs_SA-QUEBEC.log
    ├── logs_SL-NYC.log
    └── logs_SL-RIO.log
```

Exemple sur un site ``SP``, ``SD`` :
```sh
$ tree /var/log/syslog-ng/
/var/log/syslog-ng
├── 2020.10.22
│   ├── logs_SA-QUEBEC.log
│   ├── logs_SB-SAT.log
│   ├── logs_SD-GRENOBLE.log
│   ├── logs_SM-BATEAU.log
│   ├── logs_SL-NYC.log
│   ├── logs_SL-RIO.log
│   └── logs_SP-MONTREUIL.log
└── 2020.10.23
    ├── logs_SA-QUEBEC.log
    ├── logs_SA-TOULOUSE.log
    ├── logs_SB-SAT.log
    ├── logs_SD-GRENOBLE.log
    ├── logs_SL-NYC.log
    ├── logs_SL-RIO.log
    └── logs_SP-MONTREUIL.log
```

Et sur un site ``SB`` :
```bash
$ tree /var/log/syslog-ng/
/var/log/syslog-ng
├── 2020.10.22
│   ├── logs_SA-QUEBEC.log
│   ├── logs_SB-SAT.log
│   ├── logs_SD-GRENOBLE.log
│   ├── logs_SM-BATEAU.log
│   ├── logs_SL-NYC.log
│   ├── logs_SL-RIO.log
│   └── logs_SP-MONTREUIL.log
├── 2020.10.23
|   ├── logs_SA-QUEBEC.log
|   ├── logs_SA-TOULOUSE.log
|   ├── logs_SB-SAT.log
|   ├── logs_SD-GRENOBLE.log
|   ├── logs_SL-NYC.log
|   ├── logs_SL-RIO.log
|   └── logs_SP-MONTREUIL.log
└── archive
    ├── 2018.10.21.bz2
    └── 2018.10.22.bz2
```

Les relays des sites de type ``SA`` enregistrerons leur logs en local pour une durée de 2 ans.  
Les relays des sites de type ``SP`` et ``SD`` enregistrerons leur logs en local pour une durée totale de 7 ans. Au bout de 2 ans les logs seront compressés au format bzip2 (format de compression choisi par son rapport de taux de compression / temps).
Pour le site de backup ``SB``, par sa fonction de backup, sauvegardera aussi les logs pendant 7 ans dans le format bzip2.
Les relays des sites de type ``SM`` enregistreront leur logs en local jusqu'au moment où ils seront connectés au site SP. Ils envoieront leur logs mais en flux non prioritaire pour eviter de ralentir les applications du client prioritaires.
Les sites dit ``SL``, les relays n'auront pas de logs en local car ils sont forcément connectés à un site dit ``SA``.


Les opérations de compression et suppression des logs se font à l'aide de script bash. Syslog-ng ne conseille pas l'utilisation de logrotate pour une infrastructure syslog centralisé.
Les scripts bash des relay des sites ``SA``, ``SP / SD / SB`` supprimeront les logs respectivement au bout de 2 et 7 ans. De plus le script bash du site ``SB`` comprimera les logs de plus de 2 ans. Ils seront lancés tout les jours à l'aide de cronjobs.


#### Les spécifités des configurations syslog-ng.conf

Le failover : le failover est configuré en mode fallback (retour au plus vite vers le site primaire (ici, le ``SP``)).

Site | Serveur Primaire destination | Serveur Secondaire destination | Serveur Tertiaire destination |
|:------------:|:------------:|:------------:|:------------:|
| ``SA`` | ``SP`` | ``SD`` |  |
| ``SM`` | ``SP`` | ``SD`` |  |
| ``SL`` | ``SA`` | ``SP`` | ``SD`` |

Buffer des logs : Un buffer de logs est configuré (en mode reliable) pour pallier les pertes de logs lors d'envoi/failover.

Filtres : Des filtres sont créés pour réduire la quantité de logs.
Les logs de niveau entre 0 et 4 ainsi que les logs de niveau 6 sont gardés.
Nous supprimons aussi les logs de keepalive de syslog-ng.

Les relays écoutent sur leur ports 514 en TCP uniquement pour les devices du site en question.
Hors du site ils interagissent avec les autres relays en SSL (partie vue plus haut).


#### Cron Tasks

Nous avons créé 3 scripts :
|Script|Relay correspondant|
|------|-----|
|``cron_syslog_sa.sh``|``SA``|
|``cron_syslog_sp-sd.sh``|``SP`` et ``SD``|
|``cron_syslog_sb.sh``|``SB``|

Ces scripts seront sur le relay des sites correspondant dans le répertoire ``/etc/cron.daily/``.

## Annexes

### Récapitulatif des emplacements des fichiers

|  | Emplacement |
| ------------ | ------------ |
|configuration syslog|``/etc/syslog-ng/syslog-ng.conf``|
|certificat CA|``/etc/syslog-ng/ca.d/cacert.pem``|
|certificat client|``/etc/syslog-ng/cert.d/relay<nomSite>cert.pem``|
|clé client|``/etc/syslog-ng/cert.d/relay<nomSite>key.pem``|
|logs|``/var/log/syslog-ng/``|
|script bash cron des ``SA``, ``SP``, ``SD`` ou ``SB`` |``/etc/cron.daily/cron_syslog``|
|script crontab ``syslog-ng``|``/etc/cron.d/syslog-ng``|