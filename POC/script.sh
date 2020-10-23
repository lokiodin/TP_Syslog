#! /bin/bash

# SP='192.168.1.58'
# SD='192.168.1.46'
# SB='192.168.1.45'
# SA='192.168.1.47'
# SL='192.168.1.57'
# SM='192.168.1.48'
SP='192.168.1.146'
SD='192.168.1.43'
SB='192.168.1.4'
SA='192.168.1.54'
SL='192.168.1.25'
SM='192.168.1.157'

# Envoie vers le SD
echo "Envoie et restart du service sur SD"
sshpass -p "toorpw" ssh root@$SD 'rm /etc/syslog-ng/syslog-ng.conf'
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no relay_SD.conf root@$SD:/etc/syslog-ng/syslog-ng.conf
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no hosts root@$SD:/etc/
sshpass -p "toorpw" ssh root@$SD 'systemctl restart syslog-ng.service'
sshpass -p "toorpw" ssh root@$SD 'rm -rf /var/log/syslog-ng/*'
sshpass -p "toorpw" ssh root@$SD 'mkdir /var/log/syslog-ng/logs-buffer/'
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no syslog-ng root@$SD:/etc/cron.d/syslog-ng
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no cron_syslog_sp-sd.sh root@$SD:/etc/cron.daily/cron_syslog
sshpass -p "toorpw" ssh root@$SD 'systemctl restart cron.service'

# Envoie vers le SA
echo "Envoie et restart du service sur SA"
sshpass -p "toorpw" ssh root@$SA 'rm /etc/syslog-ng/syslog-ng.conf'
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no relay_SA.conf root@$SA:/etc/syslog-ng/syslog-ng.conf
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no hosts root@$SA:/etc/
sshpass -p "toorpw" ssh root@$SA 'systemctl restart syslog-ng.service'
sshpass -p "toorpw" ssh root@$SA 'rm -rf /var/log/syslog-ng/*'
sshpass -p "toorpw" ssh root@$SA 'mkdir /var/log/syslog-ng/logs-buffer/'
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no syslog-ng root@$SA:/etc/cron.d/syslog-ng
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no cron_syslog_sa.sh root@$SA:/etc/cron.daily/cron_syslog
sshpass -p "toorpw" ssh root@$SA 'systemctl restart cron.service'

# Envoie vers le SP
echo "Envoie et restart du service sur SP"
sshpass -p "toorpw" ssh root@$SP 'rm /etc/syslog-ng/syslog-ng.conf'
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no relay_SP.conf root@$SP:/etc/syslog-ng/syslog-ng.conf
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no hosts root@$SP:/etc/
sshpass -p "toorpw" ssh root@$SP 'systemctl restart syslog-ng.service'
sshpass -p "toorpw" ssh root@$SP 'rm -rf /var/log/syslog-ng/*'
sshpass -p "toorpw" ssh root@$SP 'mkdir /var/log/syslog-ng/logs-buffer/'
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no syslog-ng root@$SP:/etc/cron.d/syslog-ng
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no cron_syslog_sp-sd.sh root@$SP:/etc/cron.daily/cron_syslog
sshpass -p "toorpw" ssh root@$SP 'systemctl restart cron.service'

# Envoie vers le SL
echo "Envoie et restart du service sur SL"
sshpass -p "toorpw" ssh root@$SL 'rm /etc/syslog-ng/syslog-ng.conf'
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no relay_SL.conf root@$SL:/etc/syslog-ng/syslog-ng.conf
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no hosts root@$SL:/etc/
sshpass -p "toorpw" ssh root@$SL 'systemctl restart syslog-ng.service'
sshpass -p "toorpw" ssh root@$SL 'rm -rf /var/log/syslog-ng/*'
sshpass -p "toorpw" ssh root@$SL 'mkdir /var/log/syslog-ng/logs-buffer/'

# Envoie vers le SB
echo "Envoie et restart du service sur SB"
sshpass -p "toorpw" ssh root@$SB 'rm /etc/syslog-ng/syslog-ng.conf'
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no relay_SB.conf root@$SB:/etc/syslog-ng/syslog-ng.conf
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no hosts root@$SB:/etc/
sshpass -p "toorpw" ssh root@$SB 'systemctl restart syslog-ng.service'
sshpass -p "toorpw" ssh root@$SB 'rm -rf /var/log/syslog-ng/*'
sshpass -p "toorpw" ssh root@$SB 'mkdir /var/log/syslog-ng/logs-buffer/'
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no syslog-ng root@$SB:/etc/cron.d/syslog-ng
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no cron_syslog_sb.sh root@$SB:/etc/cron.daily/cron_syslog
sshpass -p "toorpw" ssh root@$SB 'systemctl restart cron.service'

# Envoie vers le SM
echo "Envoie et restart du service sur SM"
sshpass -p "toorpw" ssh root@$SM 'rm /etc/syslog-ng/syslog-ng.conf'
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no relay_SM.conf root@$SM:/etc/syslog-ng/syslog-ng.conf
sshpass -p "toorpw" scp -o StrictHostKeyChecking=no hosts root@$SM:/etc/
sshpass -p "toorpw" ssh root@$SM 'systemctl restart syslog-ng.service'
sshpass -p "toorpw" ssh root@$SM 'rm -rf /var/log/syslog-ng/*'
sshpass -p "toorpw" ssh root@$SM 'mkdir /var/log/syslog-ng/logs-buffer/'
