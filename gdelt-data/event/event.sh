#!/usr/bin/env bash

set -e

workpath='/gdelt/'
writelogs='/gdelt/event_writelogs.txt'

get_url() {
    local result=$(wget -qO - http://data.gdeltproject.org/gdeltv2/lastupdate.txt | awk 'FNR == 1 {print}' | awk {'print $3'})
    echo $result
}

get_latest() {
    local result=$(tail -n 1 $writelogs | awk {'print $1'} | awk -F / '{print $NF}')
    echo $result
}

upload_to_S3() {
    local filename=$1
    echo "Start uploading $filename to $target"
    aws s3 cp $workpath$filename $target$filename
    echo "Done !"

}

while true;
do
    url=$(get_url)
    filename=$(echo ${url##*/})
    latest=$(tail -n 1 $writelogs | awk {'print $1'})
    target="s3://gdelt-tharid/event/$(date +'%Y%m%d')/"

    if [ "$latest" == "$url" ] 
    then
        echo "Terminate downloading because $filename already exists !"
        sleep 180
    else 
        echo "Start downloading $filename !"
        wget $url -P $workpath
        
        echo $url $(date) >> $writelogs #commit
        
        filename=$(get_latest)
        echo "Start unzip $filename"
        unzip $workpath$filename -d $workpath

        echo "Start converting ${filename%.*} to gzip"
        gzip -f $workpath${filename%.*}

        rm -rf $workpath$filename 

        filetarget=${filename%.*}".gz"

        upload_to_S3 $filetarget
        sleep 5
        rm -rf $workpath$filetarget

        sleep 180
    fi
done

