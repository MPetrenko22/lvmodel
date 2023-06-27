/* 8 Final Status Updates */
/* Update statuses when calculation has been finished*/

merge into lvmodel.m_pre_itbf_new_list_to_check t 
using
	(select list_id, count(distinct contact_id) cnt from lvmodel.m_pre_itbf_final where list_id = ? group by list_id) s
on (t.list_id = s.list_id and t.status = 0)
when matched then update set prepackage_contact_count = s.cnt, status = 1, processed_at = NOW() ;