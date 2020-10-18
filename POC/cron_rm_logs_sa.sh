#! /bin/sh

# Pour les relay-sa
# Script permettant de supprimer les logs syslog-ng qui sont vieux de 2 ans (epoch time : 63072000) (regarde au niveau du mois)

cd test2
lst=$(ls | grep -E "[0-9]{4}.[0-9]{2}.[0-9]{2}.log")

for file in $lst; do

    # echo $file | grep -q -E "[0-9]{4}.[0-9]{2}.[0-9]{2}.log"
    # echo "j\'ai le fichier $file"
    file=${file#./*}
    file=${file%*.log}
    # echo "Date $file"
    YEAR=$(echo $file | sed 's/\./ /g' | awk '{print $1}')
    MONTH=$(echo $file | sed 's/\./ /g' | awk '{print $2}')
    DAY=$(echo $file | sed 's/\./ /g' | awk '{print $3}')

    # En epoch time : 2ans == 63072000
    if [ $(expr $(date +%s) - $(date --date="$YEAR/$MONTH/$DAY" +%s)) -ge 63072000 ]; then
        # echo "Je supprime le fichier $file car il a plus de 2 ans !!"
        rm -rf $file
    fi
done

