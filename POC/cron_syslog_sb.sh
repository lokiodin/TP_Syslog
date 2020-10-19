#! /bin/sh

# Pour le site relay-sb
# Script permettant de supprimer les logs syslog-ng qui sont vieux de 7 ans (epoch time : 220838400) (regarde au niveau du mois)
# Et de compresser/archiver les logs qui ont plus de 2 ans.


cd test2
if ! [ -d ./archive ]; then
    mkdir ./archive
fi

# Sur les fichier logs
lst=$(ls | grep -E "[0-9]{4}.[0-9]{2}.[0-9]{2}.log")


for file in $lst; do

    # echo $file | grep -q -E "[0-9]{4}.[0-9]{2}.[0-9]{2}.log"
    # echo "j\'ai le fichier $file"
    name=${file#./*}
    name=${name%*.log}
    # echo "Date $file"
    YEAR=$(echo $name | sed 's/\./ /g' | awk '{print $1}')
    MONTH=$(echo $name | sed 's/\./ /g' | awk '{print $2}')
    DAY=$(echo $name | sed 's/\./ /g' | awk '{print $3}')

    ## Compression des logs
    if [ $(expr $(date +%s) - $(date --date="$YEAR/$MONTH/$DAY" +%s)) -ge 63072000 ]; then
        # echo "Je supprime le fichier $file car il a plus de 2 ans !!"
        tar -cjf ./archive/$YEAR.$MONTH.$DAY.bz2 ./$file
        rm -f ./$file
    fi
done

cd ./archive
lst=$(ls | grep -E "[0-9]{4}.[0-9]{2}.[0-9]{2}.zip")

for file in $lst; do

    # echo $file | grep -q -E "[0-9]{4}.[0-9]{2}.[0-9]{2}.log"
    # echo "j\'ai le fichier $file"
    name=${file#./*}
    name=${name%*.log}
    # echo "Date $file"
    YEAR=$(echo $name | sed 's/\./ /g' | awk '{print $1}')
    MONTH=$(echo $name | sed 's/\./ /g' | awk '{print $2}')
    DAY=$(echo $name | sed 's/\./ /g' | awk '{print $3}')

    ## Supression
    # En epoch time : 7ans == 220838400
    if [ $(expr $(date +%s) - $(date --date="$YEAR/$MONTH/$DAY" +%s)) -ge 220838400 ]; then
        # echo "Je supprime le fichier $file car il a plus de 2 ans !!"
        rm -rf $file
    fi
done