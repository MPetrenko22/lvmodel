/* 0 Insert List ID */ 
/* Insert list id into Status Table for the further algorithm */
insert into lvmodel_dev.m_pre_itbf_new_list_to_check(list_id, status , created_at) values (?, 0, NOW())
;
