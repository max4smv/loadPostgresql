#!/bin/bash
url="https://fias.nalog.ru/Updates"
log="/home/maksim/fias/scripts/log_update.txt"
file_name="gar_delta_xml.zip"

cd /home/maksim/fias/scripts

if (( $(grep -c load_mode=DELTA "/home/maksim/fias/scripts/config.ini") ==1 )) # проверили config.ini
 then

   curl -s $url  | grep -E -o 'https://fias-file.nalog.ru/downloads/.{10}/gar_delta_xml.zip'  | sort | while read link
   do
    if (($(grep -c $link  $log)  == 0)) #если в логе ссылки нет, то 
     then 
       wget -P /home/maksim/fias/ $link #загрузили архив обновлений с сайта
       ./unpack_and_load.bash #запустили процедуру загрузки	 
	   echo $link >> $log  #записали имя загруженного архива в лог
	   rm /home/maksim/fias/$file_name #удалили прхив
    fi 
   done
 
else 
   echo "в config.ini необходимо установить load_mode=DELTA"
   exit 2
 fi 
