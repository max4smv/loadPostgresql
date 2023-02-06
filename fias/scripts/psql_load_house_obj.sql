INSERT INTO house_obj 
SELECT 
 xmltable.*
FROM 
(
select
 myXmlColumn
from 
  unnest(
        xpath
             ('//HOUSES/HOUSE'
              ,XMLPARSE(DOCUMENT convert_from(pg_read_binary_file('/var/lib/postgresql/AS_TEMP.xml'), 'UTF8'))
             )) AS myTempTable(myXmlColumn)
) as all_rows,
     XMLTABLE('/HOUSE'
                PASSING(myXmlColumn)
      COLUMNS id int PATH '@ID',
              objectid int PATH '@OBJECTID',
		      objectguid text PATH '@OBJECTGUID',
			  CHANGEID int PATH '@CHANGEID',
			  HOUSENUM text PATH '@HOUSENUM',
			  ADDNUM1 text PATH '@ADDNUM1',
			  ADDNUM2 text PATH '@ADDNUM2',
			  HOUSETYPE int PATH '@HOUSETYPE',
			  ADDTYPE1 int PATH '@ADDTYPE1',
			  ADDTYPE2 int PATH '@ADDTYPE2',
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
            xmltable.ISACTIVE = 1 and
            xmltable.ENDDATE > CURRENT_DATE;			
