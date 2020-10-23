#! /bin/sh

# Pour les relay-sp et relay-sd
# Script permettant de supprimer les logs syslog-ng qui sont vieux de 7 ans (epoch time : 220838400) (regarde au niveau du mois)
# A mettre
dir='/var/log/syslog-ng/'
lst=$(ls $dir | grep -E "[0-9]{4}.[0-9]{2}.[0-9]{2}")


for file in $lst; do

    YEAR=$(echo $file | sed 's/\./ /g' | awk '{print $1}')
    MONTH=$(echo $file | sed 's/\./ /g' | awk '{print $2}')
    DAY=$(echo $file | sed 's/\./ /g' | awk '{print $3}')

    # En epoch time : 7ans == 220838400
    if [ $(expr $(date +%s) - $(date --date="$YEAR/$MONTH/$DAY" +%s)) -ge 220838400 ]; then
        rm -rf $dir/$file
    fi
done

