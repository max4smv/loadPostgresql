#!/bin/bash
N_FOLDER=$1  #'23'
SCRIPT_PATH='/home/maksim/fias/scripts'
WORK_PATH='/home/maksim/fias/'
TEMP_PATH='/home/maksim/fias/temp'
DEST_PATH='/var/lib/postgresql' 

function get_num_file() {   #возвращаем номер обрабатываемого файла
 if [[ $1 =~ "AS_ADDR_OBJ_202" ]] 
  then echo 1
 elif [[ $1 =~ "AS_ADDR_OBJ_PARAMS_" ]] 
  then echo 2
 elif [[ $1 =~ "AS_ADM_HIERARCHY_" ]] 
  then echo 3
 elif [[ $1 =~ "AS_HOUSES_202" ]] 
  then echo 4
 elif [[ $1 =~ "AS_HOUSES_PARAMS_" ]] 
  then echo 5
 #elif [[ $1 =~ "AS_MUN_HIERARCHY_" ]] 
  #then echo 6
 else  echo 0
 fi
}

function get_tag() {   #возвращаем тег для временного файла
 if (( $1 == 1 )) 
  then echo 'ADDRESSOBJECTS'
 elif (( $1 == 2 ))
  then echo 'PARAMS'
 elif (( $1 == 3 ))
  then echo 'ITEMS'
 elif (( $1 == 4 ))
  then echo 'HOUSES'
 elif (( $1 == 5 ))
  then echo 'PARAMS'
 #elif (( $1 == 6 ))
  #then echo 'ITEMS'
 else  echo 'ERROR'
 fi
}

function load_base(){
  if (( $NUMBER_FILE == 1 )) 
    then cat $SCRIPT_PATH/psql_load_addr_obj.sql | PGPASSWORD=momqV93V psql -h 127.0.0.1 -U shmv -d shmv #выполнили скрипт загрузки в базу
   elif (( $NUMBER_FILE == 2 ))
    then cat $SCRIPT_PATH/psql_load_addr_obj_params.sql | PGPASSWORD=momqV93V psql -h 127.0.0.1 -U shmv -d shmv #выполнили скрипт загрузки в базу
   elif (( $NUMBER_FILE == 3 ))
    then cat $SCRIPT_PATH/psql_load_adm_hierarchy.sql | PGPASSWORD=momqV93V psql -h 127.0.0.1 -U shmv -d shmv #выполнили скрипт загрузки в базу
   elif (( $NUMBER_FILE == 4 ))
    then cat $SCRIPT_PATH/psql_load_house_obj.sql | PGPASSWORD=momqV93V psql -h 127.0.0.1 -U shmv -d shmv #выполнили скрипт загрузки в базу
   elif (( $NUMBER_FILE == 5 ))
    then cat $SCRIPT_PATH/psql_load_houses_params.sql | PGPASSWORD=momqV93V psql -h 127.0.0.1 -U shmv -d shmv #выполнили скрипт загрузки в базу
   #elif (( $NUMBER_FILE == 6 ))
    #then cat $SCRIPT_PATH/psql_load_mun_hierarchy.sql | PGPASSWORD=momqV93V psql -h 127.0.0.1 -U shmv -d shmv #выполнили скрипт загрузки в базу
   else  echo 'ERROR NUMBER FILE'
 fi
}

function smol_file { ### обработка маленького файла ##################
  rm -f $TEMP_PATH/*  #почистили временную папку
  cp $FULL_NAME $TEMP_PATH/AS_TEMP.XML #скопировали файл во временную папку с именем AS_TEMP.XML
  sed -i  '1s/^\xEF\xBB\xBF//' $TEMP_PATH/AS_TEMP.XML  #перекодировали в UTF-8
  sudo -S < <(echo "mmm") cp -f $TEMP_PATH/AS_TEMP.XML $DEST_PATH/AS_TEMP.xml  #скопировали в домашнюю директорию POSTGRESQL
  ############### грузим xml в базу
  load_base
 echo 'LOAD smol file' $FLN 'номер файла '$NUMBER_FILE
 }
 
 function big_file { ### обработка большого файла ################
  rm -f $TEMP_PATH/*  #почистили временную папку
  cp $FULL_NAME $TEMP_PATH/AS_TEMP.XML
 xml_split -s 300Mb $TEMP_PATH/AS_TEMP.XML  #разбиваем файл на части по 500Мб
  
  ############## цикл по разбитым файлам #######################################################################
  ls $TEMP_PATH/ | grep -wv 'AS_TEMP-00.XML\|AS_TEMP.XML' | while read TMP_FL  
  do
   sed -i  '1s/^\xEF\xBB\xBF//' $TEMP_PATH/$TMP_FL  #перекодировали в UTF-8
   TAG=$(get_tag $NUMBER_FILE) #определяем и заменяем первый и последний теги 
   sed -i 's&<xml_split:root xmlns:xml_split="http://xmltwig.com/xml_split">&<'$TAG'>&' $TEMP_PATH/$TMP_FL
   sed -i 's&</xml_split:root>&</'$TAG'>&' $TEMP_PATH/$TMP_FL
   ############### подготовили файл к загрузке
   sudo -S < <(echo "mmm") cp -f $TEMP_PATH/$TMP_FL $DEST_PATH/AS_TEMP.xml  #скопировали в домашнюю директорию POSTGRESQL
   ############### грузим xml в базу
   load_base
   echo 'LOAD BIG file' $TMP_FL 'номер файла '$NUMBER_FILE
  done 
 }

######################################################## КОНЕЦ БЛОКА ФУНКЦИЙ и НАЧАЛО ОСНОВНОЙ ЧАСТИ ####################################

########### цикл по файлам в папке ####################################################################################################################################################
ls $WORK_PATH$N_FOLDER/  | grep -E 'AS_ADDR_OBJ_202*|AS_ADDR_OBJ_PARAMS_*|AS_ADM_HIERARCHY_*|AS_HOUSES_202*|AS_HOUSES_PARAMS_*' |  while read FLN  ###убрали |AS_MUN_HIERARCHY_*
do

 NUMBER_FILE=$(get_num_file $FLN)
 FULL_NAME=$WORK_PATH$N_FOLDER/$FLN
 FSIZE=$(stat -c%s "$FULL_NAME")
 let FSIZE=FSIZE/1000000
 
 if (($FSIZE<=300))
  then smol_file
  else big_file
 fi 
 
done

