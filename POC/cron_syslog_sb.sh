#! /bin/sh

# Pour le site relay-sb
# Script permettant de supprimer les logs syslog-ng qui sont vieux de 7 ans (epoch time : 220838400) (regarde au niveau du mois)
# Et de compresser/archiver les logs qui ont plus de 2 ans.


dir='/var/log/syslog-ng'
if ! [ -d $dir/archive ]; then
    mkdir $dir/archive
fi

# Sur les fichier logs
lst=$(ls $dir | grep -E "[0-9]{4}.[0-9]{2}.[0-9]{2}")

for file in $lst; do

    YEAR=$(echo $file | sed 's/\./ /g' | awk '{print $1}')
    MONTH=$(echo $file | sed 's/\./ /g' | awk '{print $2}')
    DAY=$(echo $file | sed 's/\./ /g' | awk '{print $3}')


    ## Compression des logs
    if [ $(expr $(date +%s) - $(date --date="$YEAR/$MONTH/$DAY" +%s)) -ge 63072000 ]; then
        echo "Je commprese le fichier $dir/$file car il a plus de 2 ans !!"
        tar -cjf $dir/archive/$YEAR.$MONTH.$DAY.bz2 $dir/$file
        rm -rf $dir/$file
    fi
done

dir="$dir/archive"
lst=$(ls $dir | grep -E "[0-9]{4}.[0-9]{2}.[0-9]{2}.bz2")

for file in $lst; do


    name=${file%*.bz2}
    YEAR=$(echo $name | sed 's/\./ /g' | awk '{print $1}')
    MONTH=$(echo $name | sed 's/\./ /g' | awk '{print $2}')
    DAY=$(echo $name | sed 's/\./ /g' | awk '{print $3}')

    ## Supression
    # En epoch time : 7ans == 220838400
    if [ $(expr $(date +%s) - $(date --date="$YEAR/$MONTH/$DAY" +%s)) -ge 220838400 ]; then
        echo "Je supprime le fichier $dir/$file car il a plus de 7 ans !!"
        rm -rf $dir/$file
    fi
done