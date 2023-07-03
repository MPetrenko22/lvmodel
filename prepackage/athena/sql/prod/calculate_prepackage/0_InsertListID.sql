/* 0 Insert List ID */ 
/* Insert list id into Status Table for the further algorithm */
insert into lvmodel.m_pre_itbf_new_list_to_check(list_id, created_at) values (?, NOW());



/* 0.1 Clean Buffers After Errors */
delete from lvmodel.m_pre_itbf_template_demands where list_id = ?;
delete from lvmodel.m_pre_itbf_contact_new_collection where list_id = ?;
delete from lvmodel.m_pre_itbf_campaign_requirement_options where list_id = ?;
delete from lvmodel.m_pre_itbf_campaign_demand_mask where list_id = ?;
delete from lvmodel.m_pre_itbf_approved_new_collection where list_id = ?;