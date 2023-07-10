
/* 7 Define PV*/
/* LC Statuses */

merge into  lvmodel_dev.m_pre_itbf_final f
using (
	select  distinct
		n.contact_id, pv.pv_comment
	from lvmodel_dev.m_pre_itbf_contact_new_collection n 
	inner join lvmodel_dev.m_pre_itbf_pv_history pv 
		on pv.ext_contact_id = n.ext_contact_id 
		and (n.contact_phone = pv.contact_phone or n.mobile_phone  = pv.mobile_phone)
		and pv.pv_comment in ('lc1','lc2','lc3','lc4')
		and n.pv_comment = 'n/a'
	where n.list_id = ?
) p
on (p.contact_id = f.contact_id)
when matched then update 
	set pv_comment = p.pv_comment
;



/* CC Statuses */
merge into  lvmodel_dev.m_pre_itbf_final f
using (
	select  distinct
		n.contact_id, pv.pv_comment
	from lvmodel_dev.m_pre_itbf_contact_new_collection n 
	inner join lvmodel_dev.m_pre_itbf_pv_history pv 
		on pv.ext_contact_id = n.ext_contact_id 
		and n.company_phone = pv.company_phone
		and pv.pv_comment in ('cc1','cc2','cc3','cc4')
		and n.pv_comment = 'n/a'
	where n.list_id = ?
) p
on (p.contact_id = f.contact_id)
when matched then update 
	set pv_comment = p.pv_comment
;




/* Prepackafe PV Code */
update lvmodel_dev.m_pre_itbf_final
set prepackage_code = 1
where list_id = ?
	and pv_comment in ('lc1','lc2','lc3','lc4','cc1','cc2','cc3','cc4')
;
