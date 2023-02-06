INSERT INTO addr_obj 
SELECT 
 xmltable.*
FROM 
(
select
 myXmlColumn
from 
  unnest(
        xpath
             ('//ADDRESSOBJECTS/OBJECT'
              ,XMLPARSE(DOCUMENT convert_from(pg_read_binary_file('/var/lib/postgresql/AS_TEMP.xml'), 'UTF8'))
             )) AS myTempTable(myXmlColumn)
) as all_rows,
     XMLTABLE('/OBJECT'
                PASSING(myXmlColumn)
      COLUMNS id int PATH '@ID',
              objectid int PATH '@OBJECTID',
		      objectguid text PATH '@OBJECTGUID',
			  name text PATH '@NAME',
			  typename text PATH '@TYPENAME',
			  level int PATH '@LEVEL',
			  OPERTYPEID int PATH '@OPERTYPEID',
			  PREVID int PATH '@PREVID',
			  NEXTID int PATH '@NEXTID',
			  UPDATEDATE date PATH '@UPDATEDATE',
			  STARTDATE date PATH '@STARTDATE',
			  ENDDATE date PATH '@ENDDATE',
			  ISACTUAL int PATH '@ISACTUAL',
			  ISACTIVE int PATH '@ISACTIVE'
			)
where xmltable.ISACTUAL = 1 and
            xmltable.ISACTIVE = 1  and 
			xmltable.ENDDATE > CURRENT_DATE;
