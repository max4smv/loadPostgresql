update gar_houses
   set id=a.id, 
         parent_id_adm =a.parent_id_adm, 
         objectguid=a.objectguid, 
		 housenum=a.housenum, 
		 typename=a.typename, 
		 full_typename=a.full_typename,
		 addnum1=a.addnum1,
		 add_typename1=a.add_typename1,
		 add_full_typename1=a.add_full_typename1,
		 addnum1=a.addnum2,
		 add_typename2=a.add_typename2,
		 add_full_typename2=a.add_full_typename2,
	     opertypeid=a.opertypeid, 
		 post=a.post
from (
select
 house_obj.id,
 house_obj.objectid as object_id,
 adm_hierarchy.parentobjid as parent_id_adm,
 house_obj.objectguid,
 house_obj.housenum,
 ht.shortname as typename,
 ht.name as full_typename,
 house_obj.addnum1,
 ht_add.shortname add_typename1,
 ht_add.name add_full_typename1,
 house_obj.addnum2,
 ht_add2.shortname add_typename2,
 ht_add2.name add_full_typename2,
 house_obj.opertypeid,
 p1.value as post
from house_obj
left join adm_hierarchy on adm_hierarchy.objectid = house_obj.objectid
left join houses_params as p1 on p1.objectid = house_obj.objectid and p1.typeid = 5 ---почтовый индекс
left join houses_types as ht on ht.id = house_obj.housetype
left join houses_types_add as ht_add on ht_add.id = house_obj.addtype1
left join houses_types_add as ht_add2 on ht_add2.id = house_obj.addtype2
) a
where gar_houses.object_id = a.object_id;

insert into gar_houses 
select 
 a.id,
 a.object_id,
 a.parent_id_adm,
 a.objectguid,
 a.housenum,
 a.typename,
 a.full_typename,
 a.addnum1,
 a.add_typename1,
 a.add_full_typename1,
 a.addnum2,
 a.add_typename2,
 a.add_full_typename2,
 a.opertypeid,
 a.post
from (
select
 house_obj.id,
 house_obj.objectid as object_id,
 adm_hierarchy.parentobjid as parent_id_adm,
 house_obj.objectguid,
 house_obj.housenum,
 ht.shortname as typename,
 ht.name as full_typename,
 house_obj.addnum1,
 ht_add.shortname add_typename1,
 ht_add.name add_full_typename1,
 house_obj.addnum2,
 ht_add2.shortname add_typename2,
 ht_add2.name add_full_typename2,
 house_obj.opertypeid,
 p1.value as post,
 gh.object_id as ghobj_id
from house_obj
left join adm_hierarchy on adm_hierarchy.objectid = house_obj.objectid
left join houses_params as p1 on p1.objectid = house_obj.objectid and p1.typeid = 5 ---почтовый индекс
left join houses_types as ht on ht.id = house_obj.housetype
left join houses_types_add as ht_add on ht_add.id = house_obj.addtype1
left join houses_types_add as ht_add2 on ht_add2.id = house_obj.addtype2
left join gar_houses as gh on gh.object_id = house_obj.objectid
) a
where a.ghobj_id is null;
