INSERT INTO addr_obj_params
SELECT 
 xmltable.*
FROM 
(
select
 myXmlColumn
from 
  unnest(
        xpath
             ('//PARAMS/PARAM'
              ,XMLPARSE(DOCUMENT convert_from(pg_read_binary_file('/var/lib/postgresql/AS_TEMP.xml'), 'UTF8'))
             )) AS myTempTable(myXmlColumn)
) as all_rows,
     XMLTABLE('/PARAM'
                PASSING(myXmlColumn)
      COLUMNS id int PATH '@ID',
                 objectid int PATH '@OBJECTID',
			     CHANGEID int PATH '@CHANGEID',
			     CHANGEIDEND int PATH '@CHANGEIDEND',
                 typeid int PATH '@TYPEID',
                 value text PATH '@VALUE',
	             UPDATEDATE date PATH '@UPDATEDATE',
			     STARTDATE date PATH '@STARTDATE',
   			     ENDDATE date PATH '@ENDDATE'
			)
where xmltable.TYPEID in (6, ---ОКАТО
			  7, ---OKTMO
			  10 ---КЛАДР
			 )
			 and xmltable.CHANGEIDEND = 0
			 and xmltable.ENDDATE > CURRENT_DATE;
