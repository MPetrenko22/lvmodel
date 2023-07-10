/* 3 CID Demand Mask*/
/* Forms the mask for campaign demands - to keep set of demands */

insert into lvmodel_dev.m_pre_itbf_campaign_demand_mask
(
	cid,
	list_id,
	session_id,
	entity_type,
	entity_demand_type,
	bit_mask,
	country,
	a_country,
	state,
	a_state,
	job_level,
	job_area,
	job_function,
	industry,
	a_industry,
	employee,
	a_employee,
	status
)
with AA as (
	SELECT  
		d.cid,
		d.list_id,
		d.session_id,
		if(field = 'country', 1, 0) as country,
		if(field = 'country', 1, 0) as a_country,
		if(field = 'state', 1, 0) as state,
		if(field = 'state', 1, 0) as a_state,
		if(field = 'job_level', 1, 0) as job_level,
		if(field = 'job_area', 1, 0) as job_area,
		if(field = 'job_function', 1, 0) as job_function,
		if(field = 'industry', 1, 0) as industry,
		if(field = 'industry', 1, 0) as a_industry,
		if(field = 'employees', 1, 0) as employee,
		if(field = 'employees', 1, 0) as a_employee
	FROM lvmodel_dev.m_pre_itbf_template_demands d
	where d.list_id = ?
)
select cid, list_id, session_id, null, null, null, max(country), max(a_country), max(state), max(a_state),max(job_level),max(job_area),max(job_function),max(industry),max(a_industry),max(employee),max(a_employee), 0
from AA 
group by cid, list_id, session_id, null, null, null
;




/* Skip the employee, geo and industry demands when demads include full ranges (any value is valid) */					
merge into lvmodel_dev.m_pre_itbf_campaign_demand_mask t 
using
	(
		SELECT list_id, session_id, SUM(empl_mask) empl_mask, count(distinct state_name) as state_mask, count(distinct industry_name) as industry_mask
					FROM(
							SELECT 
								list_id, 
								session_id,
								CASE 
									WHEN d.field = 'employees' and d.value = '1 - 4' THEN 1 
									WHEN d.field = 'employees' and d.value = '5 - 9' THEN 2 
									WHEN d.field = 'employees' and d.value = '10 - 24' THEN 4
									WHEN d.field = 'employees' and d.value = '25 - 49' THEN 8
									WHEN d.field = 'employees' and d.value = '50 - 99' THEN 16
									WHEN d.field = 'employees' and d.value = '100 - 249' THEN 32
									WHEN d.field = 'employees' and d.value = '250 - 499' THEN 64
									WHEN d.field = 'employees' and d.value = '500 - 999' THEN 128
									WHEN d.field = 'employees' and d.value = '1,000 - 2,499' THEN 256
									WHEN d.field = 'employees' and d.value = '2,500 - 4,999' THEN 512
									WHEN d.field = 'employees' and d.value = '5,000 - 9,999' THEN 1024
									WHEN d.field = 'employees' and d.value = '10,000 - 19,999' THEN 2048
									WHEN d.field = 'employees' and d.value = '20,000 - 49,999' THEN 4096
									WHEN d.field = 'employees' and d.value = '50,000+' THEN 8192
									ELSE NULL 
								END empl_mask,
								case 
									when d.field = 'state' then d.value
								end state_name,
								case 
									when d.field = 'industry' then d.value 
								end industry_name
							FROM lvmodel_dev.m_pre_itbf_template_demands d
							where d.list_id = ?
					) AA
					GROUP BY list_id, session_id
	) s
on (t.list_id = s.list_id)
when matched then update set 
							employee = if(s.empl_mask = 16383, 0, employee),
							a_employee = if(s.empl_mask = 16383, 0, a_employee),
							state = if(s.state_mask = 51, 0, state),
							a_state = if(s.state_mask = 51, 0, a_state),
							industry = if(s.industry_mask = 24, 0, industry),
							a_industry = if(s.industry_mask = 24, 0, a_industry),
							status = 1
;
