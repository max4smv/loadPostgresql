#!/bin/bash
set -e 
SOURCE_PATH='/home/maksim/fias'

cat psql_truncate_end_table.sql | PGPASSWORD=momqV93V psql -h 127.0.0.1 -U shmv -d shmv #выполнили скрипт очистки результирующих таблиц

unzip -l $SOURCE_PATH/gar_xml.zip | grep AS_HOUSES_PARAMS | cut -d '/' -f1 | rev | cut -c 1-2 | rev | sort | while read folder  #цикл по папкам в архиве
do
 unzip $SOURCE_PATH/gar_xml.zip $folder"/*" -d $SOURCE_PATH ##"./" #распаковали архив
 echo "Распаковали архив : $folder"
 
 cat psql_truncate_temp.sql | PGPASSWORD=momqV93V psql -h 127.0.0.1 -U shmv -d shmv #выполнили скрипт очистки временных таблиц
 
  sudo -S < <(echo "mmm")  ./load_addr $folder
  sudo -S < <(echo "mmm")  ./load_addr_obj_params $folder
  sudo -S < <(echo "mmm")  ./load_adm_hierarchy $folder
  sudo -S < <(echo "mmm")  ./load_house $folder
  sudo -S < <(echo "mmm")  ./load_houses_params $folder
  sudo -S < <(echo "mmm")  ./load_mun_hierarchy $folder
  echo "Загрузили данные во временные таблицы"
  
  cat psql_gar_addr.sql | PGPASSWORD=momqV93V psql -h 127.0.0.1 -U shmv -d shmv #выполнили скрипт добавления данных в gar_addr
  cat psql_gar_houses.sql | PGPASSWORD=momqV93V psql -h 127.0.0.1 -U shmv -d shmv #выполнили скрипт добавления данных в gar_houses
  echo "Загрузили данные в результирующие таблицы"
  
 rm -rf $SOURCE_PATH/$folder #удаляем распакованный каталог
 echo "Удалили каталог : $folder "
done 

sudo -S < <(echo "mmm") rm -f /var/lib/postgresql/AAS_HOUSE_TYPES.xml  /var/lib/postgresql/ADM_HIERARCHY.XML  /var/lib/postgresql/AS_ADDR_OBJ_ALL.xml  /var/lib/postgresql/AS_ADDR_OBJ_PARAMS.XML  /var/lib/postgresql/AS_ADM_HIERARCHY.XML  /var/lib/postgresql/AS_HOUSES_OBJ.XML  /var/lib/postgresql/AS_HOUSES_PARAMS.XML  /var/lib/postgresql/AS_MUN_HIERARCHY.XML
 echo "Удалили временные файлы"
