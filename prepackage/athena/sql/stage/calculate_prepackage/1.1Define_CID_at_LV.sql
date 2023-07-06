/* 1.1 Define CID at LV */

/* Delete list_id dubles from previous calculation - to avoid errors  */
delete from lvmodel_stage.m_pre_itbf_new_list_to_check where list_id = ? and id is not null;




/* Define initial parameters and statuses for the new list id */

merge into lvmodel_stage.m_pre_itbf_new_list_to_check t 
using
	(
		select 
			ca.cid, l.id as list_id 
		from "lv-prepackage-stage".lv_stage_hotfix.lists l 
		inner join "lv-prepackage-stage".lv_stage_hotfix.campaigns ca on ca.id = l.campaign_id and ca.type = 2
		where l.id = ?
	) s
on (t.list_id = s.list_id and t.status is null)
when matched then update set cid = s.cid, status = 0, id = (select max(case when id is null then 0 else id end) from lvmodel_stage.m_pre_itbf_new_list_to_check) + 1;


update lvmodel_stage.m_pre_itbf_new_list_to_check
set status = -1, id = (select max(case when c2.id is null then 0 else c2.id end) from lvmodel_stage.m_pre_itbf_new_list_to_check c2) + 1 
where status is null and list_id = ?;
