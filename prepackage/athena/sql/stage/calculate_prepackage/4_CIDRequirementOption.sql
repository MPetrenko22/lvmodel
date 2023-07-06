/* 4 CID Requirement Option*/
/* Import the verification requirements for the campaign */


insert into lvmodel_stage.m_pre_itbf_campaign_requirement_options
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
	q.id, q.campaign_id, j.cid, j.list_id, j.id as session_id, q.is_latest, q.employees_empty, q.employees_skip, q.geo_empty, q.geo_skip, q.industry_skip, 0 
FROM "lv-prepackage-stage".lv_stage_hotfix.campaign_requirement_options q
INNER JOIN "lv-prepackage-stage".lv_stage_hotfix.lists l on l.campaign_id = q.campaign_id
INNER JOIN lvmodel_stage.m_pre_itbf_new_list_to_check j on j.list_id = l.id and j.status = 0
where q.is_latest = cast(1 as boolean)
	and j.list_id = ?;




/* Skip the employee, geo and industry demands when campaign verification requirements have their skip*/
merge into lvmodel_stage.m_pre_itbf_campaign_demand_mask t 
using
	(
		select distinct
			o.cid,
			o.list_id,
			case when o.employees_empty = try_cast(1 as boolean) or o.employees_skip = try_cast(1 as boolean) then 0 else null end skip_employee,
			case when o.geo_empty = try_cast(1 as boolean) or o.geo_skip = try_cast(1 as boolean) then 0 else null end skip_geo,
			case when o.industry_skip = try_cast(1 as boolean) then 0 else null end skip_industry
		from lvmodel_stage.m_pre_itbf_campaign_requirement_options o
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
							status = 2;
