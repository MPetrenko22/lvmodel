/* 4 CID Requirement Option*/
/*Create Table*/

CREATE TABLE lvmodel_dev.m_pre_itbf_campaign_requirement_options_? (
	id int, 
	campaign_id int, 
	cid string,
	list_id bigint,
	session_id int,
	is_latest boolean, 
	employees_empty boolean, 
	employees_skip boolean, 
	geo_empty boolean, 
	geo_skip boolean, 
	industry_skip boolean,
	status int
)
LOCATION 's3://lvprepackage/dev/iceberg/'
TBLPROPERTIES (
  'table_type'='iceberg',
  'format'='parquet'
)
;



/* Import the verification requirements for the campaign */

insert into lvmodel_dev.m_pre_itbf_campaign_requirement_options_?
(
	id, 
	campaign_id, 
	cid,
	list_id,
	session_id,
	is_latest, 
	employees_empty, 
	employees_skip, 
	geo_empty, 
	geo_skip, 
	industry_skip,
	status
)
SELECT  DISTINCT
	q.id, q.campaign_id, null as cid, l.id as list_id, 0 as session_id, q.is_latest, q.employees_empty, q.employees_skip, q.geo_empty, q.geo_skip, q.industry_skip, 0 
FROM "lv-prepackage-stage".lv_athena_stage.campaign_requirement_options q
INNER JOIN "lv-prepackage-stage".lv_athena_stage.lists l on l.campaign_id = q.campaign_id
where q.is_latest = cast(1 as boolean)
	and l.id = ?
;




/* Skip the employee, geo and industry demands when campaign verification requirements have their skip*/
merge into lvmodel_dev.m_pre_itbf_campaign_demand_mask_? t 
using
	(
		select distinct
			o.cid,
			o.list_id,
			case when o.employees_empty = try_cast(1 as boolean) or o.employees_skip = try_cast(1 as boolean) then 0 else null end skip_employee,
			case when o.geo_empty = try_cast(1 as boolean) or o.geo_skip = try_cast(1 as boolean) then 0 else null end skip_geo,
			case when o.industry_skip = try_cast(1 as boolean) then 0 else null end skip_industry
		from lvmodel_dev.m_pre_itbf_campaign_requirement_options_? o
		where o.list_id = ?
	) s
on (t.list_id = s.list_id)
when matched then update set 
							country = if(s.skip_geo = 0, 0, country),
							a_country = if(s.skip_geo = 0, 0, a_country),
							state = if(s.skip_geo = 0, 0, state),
							a_state = if(s.skip_geo = 0, 0, a_state),
							employee = if(s.skip_employee = 0, 0, employee),
							a_employee = if(s.skip_employee = 0, 0, a_employee),
							industry = if(s.skip_industry = 0, 0, industry),
							a_industry = if(s.skip_industry = 0, 0, a_industry),
							status = 2
;
