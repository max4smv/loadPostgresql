insert into gar_addr
select 
 addr_obj.id,
 adm_hierarchy.parentobjid as parent_id_adm,
 mun_hierarchy.parentobjid as parent_id_mun,
 addr_obj.objectid as object_id,
 addr_obj.objectguid,
 addr_obj.name,
 addr_obj.typename,
 addr_obj.level,
 p1.value as okato,
 p1.value as oktmo,
 p2.value as kladr
from addr_obj 
left join mun_hierarchy on mun_hierarchy.objectid = addr_obj.objectid
left join adm_hierarchy on adm_hierarchy.objectid = addr_obj.objectid
left join addr_obj_params as p1 on p1.objectid = addr_obj.objectid and p1.typeid = 6 ---ОКАТО
left join addr_obj_params as p2 on p2.objectid = addr_obj.objectid and p2.typeid = 7 ---OKTMO
left join addr_obj_params as p3 on p3.objectid = addr_obj.objectid and p3.typeid = 10 ---КЛАДР
;
