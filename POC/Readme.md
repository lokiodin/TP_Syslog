# Readme.md

> **Quelques infos des commandes que l'on a utilisé et fichiers**

## Fichiers pour le poc

``syslog-ng`` : fichier pour le crontab des relays.

``cron_syslog_*`` : fichier cron pour les sites.

``client.conf`` : exemple de conf syslog-ng poour un client.

``relay_*`` : fichier de configuration syslog-ng pour les relays des sites.

``hosts`` : fichier pour faire office de DNS interne des VM (contient les IP des VM de tests).

Répertoire ``CA`` : contient tous les fichiers lié à la CA.


## Fichier d'automatisation de transfert de fichier

``script.sh`` pour automatiser le transfert des configurations syslog-ng et autres.

``script2.sh`` pour automatiser le transfert des fichier de la CA.

## Création et Conf CA + Infos sur TLS/SSL dans syslog-ng
```
cd ~
mkdir CA
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
## SL
openssl req -nodes -new -x509 -keyout relaySLkey.pem -out relaySLreq.pem -days 365 -config openssl.cnf
openssl x509 -x509toreq -in relaySLreq.pem -signkey relaySLkey.pem -out tmpSL.pem
openssl ca -config openssl.cnf -policy policy_anything -out relaySLcert.pem -infiles tmpSL.pem
rm tmpSL.pem
## SA
openssl req -nodes -new -x509 -keyout relaySAkey.pem -out relaySAreq.pem -days 365 -config openssl.cnf
openssl x509 -x509toreq -in relaySAreq.pem -signkey relaySAkey.pem -out tmpSA.pem
openssl ca -config openssl.cnf -policy policy_anything -out relaySAcert.pem -infiles tmpSA.pem
rm tmpSA.pem
## SD
openssl req -nodes -new -x509 -keyout relaySDkey.pem -out relaySDreq.pem -days 365 -config openssl.cnf
openssl x509 -x509toreq -in relaySDreq.pem -signkey relaySDkey.pem -out tmpSD.pem
openssl ca -config openssl.cnf -policy policy_anything -out relaySDcert.pem -infiles tmpSD.pem
rm tmpSD.pem
## SP
openssl req -nodes -new -x509 -keyout relaySPkey.pem -out relaySPreq.pem -days 365 -config openssl.cnf
openssl x509 -x509toreq -in relaySPreq.pem -signkey relaySPkey.pem -out tmpSP.pem
openssl ca -config openssl.cnf -policy policy_anything -out relaySPcert.pem -infiles tmpSP.pem
rm tmpSP.pem
## SB
openssl req -nodes -new -x509 -keyout relaySBkey.pem -out relaySBreq.pem -days 365 -config openssl.cnf
openssl x509 -x509toreq -in relaySBreq.pem -signkey relaySBkey.pem -out tmpSB.pem
openssl ca -config openssl.cnf -policy policy_anything -out relaySBcert.pem -infiles tmpSB.pem
rm tmpSB.pem
## SM
openssl req -nodes -new -x509 -keyout relaySMkey.pem -out relaySMreq.pem -days 365 -config openssl.cnf
openssl x509 -x509toreq -in relaySMreq.pem -signkey relaySMkey.pem -out tmpSM.pem
openssl ca -config openssl.cnf -policy policy_anything -out relaySMcert.pem -infiles tmpSM.pem
rm tmpSM.pem


#### Ensuite une fois tous les certificats créé
# Sur le server syslog (SP là)
cd /etc/syslog-ng
mkdir cert.d ca.d
cp ~/CA/servercert.pem /etc/syslog-ng/cert.d
cp ~/CA/serverkey.pem /etc/syslog-ng/cert.d
cp ~/CA/cacert.pem /etc/syslog-ng/ca.d

cd ca.d/
ln -s cacert.pem $(openssl x509 -noout -hash -in cacert.pem).0
####### Exemple a mettre dans le syslog-ng.conf du server SP
# Adopt the following configuration example to your syslog-ng.conf by changing the IP and port parameters and directories to your local environment. In the log statement replace €œd_local€ with an actual log destination name in your configuration (for example the one that refers to/var/log/messages).
# source demo_tls_source {    # Definition des sources "exterieurs" pour le TLS agit en tant que listener
#     tcp(ip(0.0.0.0) port(6514)
#         tls( key_file("/etc/syslog-ng/cert.d/serverkey.pem")
#             cert_file("/etc/syslog-ng/cert.d/servercert.pem")
#             ca_dir("/etc/syslog-ng/ca.d")
#         )
#     ); 
# };
# destination d_logs_tls {    # Definition des destinations locales TLS
#     file("/var/log/syslog-ng/logs_tls.txt"
#         owner("root")
#         group("root")
#         perm(0777)
#     ); 
# };
# log {   # Logging local TLS
#     source(demo_tls_source); 
#     destination(d_logs_tls); 
# };

# Sur les clients (SA là):
cd /etc/syslog-ng
mkdir cert.d ca.d
cp ~/CA/clientSLcert.pem /etc/syslog-ng/cert.d
cp ~/CA/clientSLkey.pem /etc/syslog-ng/cert.d
cp ~/CA/cacert.pem /etc/syslog-ng/ca.d
cd ca.d/
ln -s cacert.pem $(openssl x509 -noout -hash -in cacert.pem).0
####### Exemple a mettre dans le syslog-ng.conf du client SA
# destination demo_tls_destination {  # Definition des destinations exterieures, vers le relay-SP en TLS
#    network("relay-sp" port(6514)
#        transport("tls")
#        tls( ca_dir("/etc/syslog-ng/ca.d")
#            key_file("/etc/syslog-ng/cert.d/relaySAkey.pem")
#            cert_file("/etc/syslog-ng/cert.d/relaySAcert.pem") 
#        )
# };
# log {   # Logging vers SP TLS
#     source(src);
#     destination(demo_tls_destination);
# };

```
