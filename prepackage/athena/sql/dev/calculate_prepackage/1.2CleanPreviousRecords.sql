/* 1.2 Clean previous records of new list id from Result Table (if new list id was calculated before)*/

merge into lvmodel_dev.m_pre_itbf_final t 
using
	(select distinct list_id from lvmodel_dev.m_pre_itbf_new_list_to_check where list_id = ?) s
on (t.list_id = s.list_id)
when matched then delete
;
