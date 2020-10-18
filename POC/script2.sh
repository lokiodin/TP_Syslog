#!/bin/bash

SP='192.168.1.58'
SD='192.168.1.46'
SB='192.168.1.45'
SA='192.168.1.47'
SL='192.168.1.57'
SM='192.168.1.48'


## Permet d'envoyer tout ce qui est CA aux server

# Envoie vers le SA
echo "Envoi sur le **SA**"
sshpass -p "toorpw" ssh root@$SA 'rm -rf ca.d/ cert.d/'
sshpass -p "toorpw" ssh root@$SA mkdir /etc/syslog-ng/ca.d
sshpass -p "toorpw" ssh root@$SA mkdir /etc/syslog-ng/cert.d
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no ./CA/relaySAkey.pem root@$SA:/etc/syslog-ng/cert.d/
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no ./CA/relaySAcert.pem root@$SA:/etc/syslog-ng/cert.d/
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no ./CA/cacert.pem root@$SA:/etc/syslog-ng/ca.d/
sshpass -p "toorpw" ssh root@$SA 'ln -s /etc/syslog-ng/ca.d/cacert.pem /etc/syslog-ng/ca.d/$(openssl x509 -noout -hash -in /etc/syslog-ng/ca.d/cacert.pem).0'

# Envoie vers le SL
echo "Envoi sur le **SL**"
sshpass -p "toorpw" ssh root@$SL 'rm -rf ca.d/ cert.d/'
sshpass -p "toorpw" ssh root@$SL mkdir /etc/syslog-ng/ca.d
sshpass -p "toorpw" ssh root@$SL mkdir /etc/syslog-ng/cert.d
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no ./CA/relaySLkey.pem root@$SL:/etc/syslog-ng/cert.d/
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no ./CA/relaySLcert.pem root@$SL:/etc/syslog-ng/cert.d/
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no ./CA/cacert.pem root@$SL:/etc/syslog-ng/ca.d/
sshpass -p "toorpw" ssh root@$SL 'ln -s /etc/syslog-ng/ca.d/cacert.pem /etc/syslog-ng/ca.d/$(openssl x509 -noout -hash -in /etc/syslog-ng/ca.d/cacert.pem).0'

# Envoie vers le SP
echo "Envoi sur le **SP**"
sshpass -p "toorpw" ssh root@$SP 'rm -rf ca.d/ cert.d/'
sshpass -p "toorpw" ssh root@$SP mkdir /etc/syslog-ng/ca.d
sshpass -p "toorpw" ssh root@$SP mkdir /etc/syslog-ng/cert.d
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no ./CA/relaySPkey.pem root@$SP:/etc/syslog-ng/cert.d/
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no ./CA/relaySPcert.pem root@$SP:/etc/syslog-ng/cert.d/
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no ./CA/cacert.pem root@$SP:/etc/syslog-ng/ca.d/
sshpass -p "toorpw" ssh root@$SP 'ln -s /etc/syslog-ng/ca.d/cacert.pem /etc/syslog-ng/ca.d/$(openssl x509 -noout -hash -in /etc/syslog-ng/ca.d/cacert.pem).0'

# Envoie vers le SD
echo "Envoi sur le **SD**"
sshpass -p "toorpw" ssh root@$SD 'rm -rf ca.d/ cert.d/'
sshpass -p "toorpw" ssh root@$SD mkdir /etc/syslog-ng/ca.d
sshpass -p "toorpw" ssh root@$SD mkdir /etc/syslog-ng/cert.d
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no ./CA/relaySDkey.pem root@$SD:/etc/syslog-ng/cert.d/
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no ./CA/relaySDcert.pem root@$SD:/etc/syslog-ng/cert.d/
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no ./CA/cacert.pem root@$SD:/etc/syslog-ng/ca.d/
sshpass -p "toorpw" ssh root@$SD 'ln -s /etc/syslog-ng/ca.d/cacert.pem /etc/syslog-ng/ca.d/$(openssl x509 -noout -hash -in /etc/syslog-ng/ca.d/cacert.pem).0'

# Envoie vers le SB
echo "Envoi sur le **SB**"
sshpass -p "toorpw" ssh root@$SB 'rm -rf ca.d/ cert.d/'
sshpass -p "toorpw" ssh root@$SB mkdir /etc/syslog-ng/ca.d
sshpass -p "toorpw" ssh root@$SB mkdir /etc/syslog-ng/cert.d
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no ./CA/relaySBkey.pem root@$SB:/etc/syslog-ng/cert.d/
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no ./CA/relaySBcert.pem root@$SB:/etc/syslog-ng/cert.d/
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no ./CA/cacert.pem root@$SB:/etc/syslog-ng/ca.d/
sshpass -p "toorpw" ssh root@$SB 'ln -s /etc/syslog-ng/ca.d/cacert.pem /etc/syslog-ng/ca.d/$(openssl x509 -noout -hash -in /etc/syslog-ng/ca.d/cacert.pem).0'

# Envoie vers le SM
echo "Envoi sur le **SM**"
sshpass -p "toorpw" ssh root@$SM 'rm -rf ca.d/ cert.d/'
sshpass -p "toorpw" ssh root@$SM mkdir /etc/syslog-ng/ca.d
sshpass -p "toorpw" ssh root@$SM mkdir /etc/syslog-ng/cert.d
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no ./CA/relaySMkey.pem root@$SM:/etc/syslog-ng/cert.d/
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no ./CA/relaySMcert.pem root@$SM:/etc/syslog-ng/cert.d/
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no ./CA/cacert.pem root@$SM:/etc/syslog-ng/ca.d/
sshpass -p "toorpw" ssh root@$SM 'ln -s /etc/syslog-ng/ca.d/cacert.pem /etc/syslog-ng/ca.d/$(openssl x509 -noout -hash -in /etc/syslog-ng/ca.d/cacert.pem).0'