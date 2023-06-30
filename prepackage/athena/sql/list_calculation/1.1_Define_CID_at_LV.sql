/* 1.1 Define CID at LV */

/* Delete list_id dubles from previous calculation - to avoid errors  */
delete from lvmodel.m_pre_itbf_new_list_to_check where list_id = ? and id is not null;



/* Define initial parameters and statuses for the new list id */
merge into lvmodel.m_pre_itbf_new_list_to_check t 
using
	(
		select 
			ca.cid, l.id as list_id 
		from "lv-prepackage".app_lv.lists l 
		inner join "lv-prepackage".app_lv.campaigns ca on ca.id = l.campaign_id and ca.type = 2
		where l.id = ?
	) s
on (t.list_id = s.list_id and t.status is null)
when matched then update set cid = s.cid, status = 0, id = (select max(case when id is null then 0 else id end) from lvmodel.m_pre_itbf_new_list_to_check) + 1;