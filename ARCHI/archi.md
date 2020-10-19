# Architecture logs management M&A Inc.

## Vocabulaire

| Mot utilisé | Explication |
| ------------- | ------------- |
| SB | Site de Backup |
| SP | Site Principal |
| SD | Site de Dévolution |
| SA | Site Autonome |
| SL | Site Local |
| SM | Site Mobile  |
| relay-[SB|SP|SD|SA|SL|SM] | Serveur Syslog du site en question |


## Contexte

> Vous été mandaté par l'entreprise Mercenaires & Associés Inc. (M&A Inc.) pour rénover le système de rénovation.
> Le client vous a donné les schémas de leur infrastructure actuelle.


## Architecture actuelle
Schéma de l'infrastructure de M&A Inc. :
![Figure 1](schema_infra.png "Schéma Infrastructure M&A actuelle")

Schéma de l'implantation des sites :
![Figure 2](schema_infra_implantation_sites.png "Schéma de l'implantation des sites de M&A Inc.")

### Explication

Les particularité des divers sites :
Type de site | Nom complet du site | Explication | Particularité |
| ------------- | ------------- | ------------- | ------------- |
SB | Site de Backup | Site de backup des sauvegardes et coffres numériques |
SP | Site Principal | Site central de l'infrastructure et de service de M&A Inc. |
SD | Site de Dévolution | Site de survie de M&A Inc., contient une réplication de l'infrastructure et services nécessaires en cas de coupure sur SP |
SA | Site Autonome | Site contenant une infrastructure autonome | Peut être déconnecté du SP |
SL | Site Local | Site local ne contenant que l'infrastructure "utilisateurs" | Doit être connecté au SA ou SP |
SM | Site Mobile | Site fonctionnant en autonomie | N'a que des connections épisodiques au SP |

Sur la partie logs management, la hierarchie est telle quelle suivant les sites :
* relay-SL envoie tous les logs au relay-SA ou relay-SP auquel il est connecté.
* relay-SA peut stocker une certaine quantité de logs. Il envoie les logs au SP lorsqu'il le peut.
* relay-SM peut stocker les logs en local. **METTRE QUELQUE CHOSE POUR L'ENVOIE DES LOGS LORSQU'IL EST CONNECTE**
* relay-SP stocke les logs pendant un certain temps. Réplique sa base de donnée dans le relay-SD.
* relay-SB est le serveur syslog ayant tous les logs d'une durée de moins de 7 ans en sauvegarde.

### Architecture choisie

Nous avons choisi de respecter la hierarchie entre les sites.
* Les relay-SL envoient les logs aux relay-SA,
* Les relay-SA envoient les logs au relay-SP,
* Les relay-SM envoient les logs au relay-SP,
* Le relay-SP réplique ses logs au relay-SD,
* Les relay-SP et relay-SD envoient leurs logs au relay-SB pour la sauvegardes des logs.

Les envois de logs se font en TCP sur le port 6514, chiffrés en TLS. Pour cela il faut diposer d'une infrastructure CA.
Pour tester l'architecture, nous avons utilisé l'outil `openssl`.
Voici un example des commandes :
```bash
cd CA
mkdir certs crl newcerts private
echo "01" > serial
cp /dev/null index.txt
cp /etc/ssl/openssl.cnf openssl.cnf
# Changer la ligne
# [ CA_default ]
# dir             = ./demoCA              # Where everything is kept
# certs           = $dir/certs            # Where the issued certs are kept
# en 
# [ CA_default ]
# dir             = .                     # Where everything is kept
# certs           = $dir/certs            # Where the issued certs are kept

# Generer le certificat de la CA
openssl req -new -x509 -keyout private/cakey.pem -out cacert.pem -days 365 -config openssl.cnf

# Generer les certificat des clients
nomSite=relay-sa
openssl req -nodes -new -x509 -keyout $nomSitekey.pem -out $nomSitereq.pem -days 365 -config openssl.cnf
openssl x509 -x509toreq -in $nomSitereq.pem -signkey $nomSitekey.pem -out tmp$nomSite.pem
openssl ca -config openssl.cnf -policy policy_anything -out $nomSitecert.pem -infiles tmp$nomSite.pem
rm tmp$nomSite.pem
```

Il faut mettre les fichiers ``$nomSitekey.pem`` et ``$nomSitecert.pem`` dans le repertoire ``/etc/syslog-ng/cert.d/`` et ``cakey.pem`` dans le repertoire ``/etc/syslog-ng/ca.d/``.


## Annexes
