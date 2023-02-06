#!/bin/bash

#trap 'echo "# $BASH_COMMAND";read' DEBUG

set -e 

########### читаем ini файл ##################################################
if [ -e config.ini ]; then echo "загрузили config.ini"; else  echo "не найде config.ini";  exit 2; fi

LOAD_MODE=$(awk -F "=" '/load_mode/ {print $2}' config.ini)
if [[ $LOAD_MODE =~ "FULL" ]]
 then
  ARCH_NAME=$(awk -F "=" '/archiv_name/ {print $2}' config.ini);
  SOURCE_PATH=$(awk -F "=" '/source_path/ {print $2}' config.ini);
  FIRST_FIOLDER=$(awk -F "=" '/folder_first/ {print $2}' config.ini);
  LAST_FOLDER=$(awk -F "=" '/folder_end/ {print $2}' config.ini);
  CLEAR_REZULT=$(awk -F "=" '/clear_rezult/ {print $2}' config.ini);
  if [[ $CLEAR_REZULT =~ "yes" ]]
   then
    while true; do
      read -p "Удаляем данные из результирующих таблиц? y/n:" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit 2;;
        * ) echo "Please answer yes or no.";;
    esac
   done
  fi
 elif [[ $LOAD_MODE =~ "DELTA" ]]
  then
  ARCH_NAME="gar_delta_xml.zip"
  SOURCE_PATH=$(awk -F "=" '/source_path/ {print $2}' config.ini)
  FIRST_FIOLDER="01"
  LAST_FOLDER="999"
  CLEAR_REZULT="no"
 else
  echo "неверное значение load mode!" 
  exit 2
 fi 
 
  if [[ $CLEAR_REZULT =~ "yes" ]]
   then
      cat psql_truncate_end_table.sql | PGPASSWORD=momqV93V psql -h 127.0.0.1 -U shmv -d shmv #выполнили скрипт очистки результирующих таблиц
  fi	  

echo $SOURCE_PATH
echo $ARCH_NAME
echo ""

unzip -l $SOURCE_PATH/$ARCH_NAME | grep AS_HOUSES_PARAMS | cut -d '/' -f1 | rev | cut -c 1-2 | rev | sort | while read folder  #цикл по папкам в архиве
do
 if [[ $FIRST_FIOLDER < $folder||$FIRST_FIOLDER = $folder ]]&&[[ $LAST_FOLDER > $folder||$LAST_FOLDER = $folder ]]
 then
  unzip $SOURCE_PATH/$ARCH_NAME $folder"/*" -d $SOURCE_PATH ##"./" #распаковали архив
  echo "Распаковали архив : $folder"
 
  cat psql_truncate_temp.sql | PGPASSWORD=momqV93V psql -h 127.0.0.1 -U shmv -d shmv #выполнили скрипт очистки временных таблиц
 
   sudo -S < <(echo "mmm")  ./load_folder.bash $folder
    echo "Загрузили данные во временные таблицы"
  
   if [[ $LOAD_MODE =~ "FULL" ]]
    then
      cat psql_gar_addr.sql | PGPASSWORD=momqV93V psql -h 127.0.0.1 -U shmv -d shmv #выполнили скрипт добавления данных в gar_addr
      cat psql_gar_houses.sql | PGPASSWORD=momqV93V psql -h 127.0.0.1 -U shmv -d shmv #выполнили скрипт добавления данных в gar_houses
	  echo "Загрузили данные в результирующие таблицы"
    else
      cat psql_delta_gar_addr.sql | PGPASSWORD=momqV93V psql -h 127.0.0.1 -U shmv -d shmv #выполнили ДЕЛЬТА скрипт добавления данных в gar_addr
      cat psql_delta_gar_houses.sql | PGPASSWORD=momqV93V psql -h 127.0.0.1 -U shmv -d shmv #выполнили ДЕЛЬТА скрипт добавления данных в gar_houses
	  echo "Загрузили ДЕЛЬТУ в результирующие таблицы"
    fi
  
  
  rm -rf $SOURCE_PATH/$folder #удаляем распакованный каталог
  echo "Удалили каталог : $folder "
 else
   echo "Не грузим каталог : $folder "
 fi
done 
