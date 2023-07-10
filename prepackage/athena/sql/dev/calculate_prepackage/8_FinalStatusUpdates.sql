/* 8 Final Status Updates */
/* Update statuses when calculation has been finished*/

merge into lvmodel_stage.m_pre_itbf_new_list_to_check t 
using
	(
		select c.list_id, count(distinct f.contact_id) cnt 
		from lvmodel_stage.m_pre_itbf_new_list_to_check c
		left join lvmodel_stage.m_pre_itbf_final f on f.list_id = c.list_id 
		where c.list_id = ? 
		group by c.list_id
	) s
on (t.list_id = s.list_id and t.status = 0)
when matched then update set prepackage_contact_count = s.cnt, status = 1, processed_at = NOW()
;
