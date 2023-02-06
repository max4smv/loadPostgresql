insert into gar_houses 
select
 house_obj.id,
 house_obj.objectid as object_id,
 adm_hierarchy.parentobjid as parent_id_adm,
 mun_hierarchy.parentobjid as parent_id_mun,
 house_obj.objectguid,
 house_obj.housenum,
 ht.shortname as typename,
 house_obj.opertypeid,
 p1.value as okato,
 p2.value as oktmo,
 p3.value as post
from house_obj
left join mun_hierarchy on mun_hierarchy.objectid = house_obj.objectid
left join adm_hierarchy on adm_hierarchy.objectid = house_obj.objectid
left join houses_params as p1 on p1.objectid = house_obj.objectid and p1.typeid = 6 ---ОКАТО
left join houses_params as p2 on p2.objectid = house_obj.objectid and p2.typeid = 7 ---OKTMO
left join houses_params as p3 on p3.objectid = house_obj.objectid and p3.typeid = 5 ---почтовый индекс
left join houses_types as ht on ht.id = house_obj.housetype;
