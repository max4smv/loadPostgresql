insert into gar_addr
select 
 addr_obj.id,
 adm_hierarchy.parentobjid as parent_id_adm,
 addr_obj.objectid as object_id,
 addr_obj.objectguid,
 addr_obj.name,
 addr_obj.typename,
 p2.name as full_typename,
 addr_obj.level,
 p1.value as kladr
from addr_obj 
left join adm_hierarchy on adm_hierarchy.objectid = addr_obj.objectid
left join addr_obj_params as p1 on p1.objectid = addr_obj.objectid and p1.typeid = 10 ---КЛАДР
left join addr_types p2 on p2.level = addr_obj.level and p2.shortname = addr_obj.typename;
