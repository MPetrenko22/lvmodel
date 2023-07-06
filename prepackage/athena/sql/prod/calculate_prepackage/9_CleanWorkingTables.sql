/* 9 Clean working tables where calculations have finished*/

delete from lvmodel.m_pre_itbf_template_demands where list_id = ?
;
delete from lvmodel.m_pre_itbf_contact_new_collection where list_id = ?
;
delete from lvmodel.m_pre_itbf_campaign_requirement_options where list_id = ?
;
delete from lvmodel.m_pre_itbf_campaign_demand_mask where list_id = ?
;
delete from lvmodel.m_pre_itbf_approved_new_collection where list_id = ?
;
