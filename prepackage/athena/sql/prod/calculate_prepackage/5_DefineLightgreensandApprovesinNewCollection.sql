/* 5 - Define Lightgreens and Approves in New Collection */ 
/* Collect Approves and LG from History */


insert into lvmodel.m_pre_itbf_approved_new_collection 
(
	cid, list_id, session_id, contact_id, title_approved, address_approved, employee_approved
)
with LG_TIT as (
	select nc.contact_id , nc.ext_contact_id , c.previous_ov_date 
	from lvmodel.m_pre_itbf_contact_new_collection nc
	inner join "lv-prepackage".app_lv.contacts c on c.id = nc.contact_id 
	where  nc.list_id = ?
		and c.previous_ov_date > DATE('2001-01-01')
		and date_add('day', 180, c.previous_ov_date) > NOW()
),
APR_TIT as (
	select nc.contact_id , nc.ext_contact_id , h.date_approve as title_date_approve
	from lvmodel.m_pre_itbf_contact_new_collection nc
	inner join lvmodel.m_pre_itbf_approve_history h on h.email_id = nc.email_id and h.approve_type = 'title' and h.value = nc.title 
	where  nc.list_id = ?
),
LG_ADR as (
	select nc.contact_id , nc.ext_contact_id , c.address_date
	from lvmodel.m_pre_itbf_contact_new_collection nc
	inner join "lv-prepackage".app_lv.contacts c on c.id = nc.contact_id
	where  nc.list_id = ?
		and c.address_date > DATE('2001-01-01')
),
APR_ADR as (
	select nc.contact_id , nc.ext_contact_id , h.date_approve as address_date_approve
	from lvmodel.m_pre_itbf_contact_new_collection nc
	inner join lvmodel.m_pre_itbf_approve_history h on h.email_id = nc.email_id and h.approve_type = 'country' and h.value = nc.country 
	inner join lvmodel.m_pre_itbf_approve_history h2 on h2.email_id = nc.email_id and h2.approve_type = 'state' and h2.value = nc.state 
	where  nc.list_id = ?
),
LG_EMP as (
	select nc.contact_id , nc.ext_contact_id , com.id as company_id, com.employee_date
	from lvmodel.m_pre_itbf_contact_new_collection nc
	inner join "lv-prepackage".app_lv.contacts c on c.id = nc.contact_id 
	inner join "lv-prepackage".app_lv.companies com on com.id = c.company_id
	where  nc.list_id = ?
		and com.employee_date > DATE('2001-01-01')
		and date_add('day', 360, com.employee_date)  > NOW()
),
APR_EMP as (
	select nc.contact_id , nc.ext_contact_id , h.date_approve as employee_date_approve
	from lvmodel.m_pre_itbf_contact_new_collection nc
	inner join lvmodel.m_pre_itbf_approve_history h on h.ext_company_id = nc.ext_company_id and h.approve_type = 'employee' and h.value = nc.employee 
	where  nc.list_id = ?
)
select distinct 
	n.cid,
	n.list_id,
	n.session_id,
	n.contact_id,
	case when LG_TIT.previous_ov_date is not null or APR_TIT.title_date_approve is not null then 1.0 else 0.0 end title_approved,
	case when LG_ADR.address_date is not null or APR_ADR.address_date_approve is not null then 1.0 else 0.0 end address_approved,
	case when LG_EMP.employee_date is not null or APR_EMP.employee_date_approve is not null then 1.0 else 0.0 end employee_approved
from lvmodel.m_pre_itbf_contact_new_collection n
left join LG_TIT on LG_TIT.contact_id = n.contact_id
left join LG_ADR on LG_ADR.contact_id = n.contact_id
left join LG_EMP on LG_EMP.contact_id = n.contact_id
left join APR_TIT on APR_TIT.contact_id = n.contact_id
left join APR_ADR on APR_ADR.contact_id = n.contact_id
left join APR_EMP on APR_EMP.contact_id = n.contact_id
;




/* Skip Demands */
merge into lvmodel.m_pre_itbf_approved_new_collection n
using (
			select distinct k.list_id, k.a_state, k.a_employee 
			from lvmodel.m_pre_itbf_campaign_demand_mask k
			where k.list_id = ?
		) m
on (n.list_id = m.list_id)
when matched then 
	update set
		address_approved = case when m.a_state = 0 then 1 else n.address_approved end,
		employee_approved = case when m.a_employee = 0 then 1 else n.employee_approved end
;



/* Total Contact Approves Calculation */
update  lvmodel.m_pre_itbf_approved_new_collection 
set contact_approved = case when title_approved = 1 and address_approved = 1 and employee_approved = 1 then 1 else 0 end
where  list_id = ?
;
