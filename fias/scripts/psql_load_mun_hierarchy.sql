INSERT INTO mun_hierarchy 
SELECT 
 xmltable.*
FROM 
(
select
 myXmlColumn
from 
  unnest(
        xpath
             ('//ITEMS/ITEM'
              ,XMLPARSE(DOCUMENT convert_from(pg_read_binary_file('/var/lib/postgresql/AS_TEMP.xml'), 'UTF8'))
             )) AS myTempTable(myXmlColumn)
) as all_rows,
     XMLTABLE('/ITEM'
                PASSING(myXmlColumn)
      COLUMNS id int PATH '@ID',
                          objectid int PATH '@OBJECTID',
			              parentobjid int PATH '@PARENTOBJID',
			  			  CHANGEID int PATH '@CHANGEID',
			              oktmo bigint PATH '@OKTMO',
			  			  PREVID int PATH '@PREVID',
			  			  NEXTID int PATH '@NEXTID',
			              UPDATEDATE date PATH '@UPDATEDATE',
			              STARTDATE date PATH '@STARTDATE',
			              ENDDATE date PATH '@ENDDATE',
			              ISACTIVE int PATH '@ISACTIVE',
			              PATH text PATH '@PATH'
			)
where xmltable.ISACTIVE = 1 and
            xmltable.ENDDATE > CURRENT_DATE;
