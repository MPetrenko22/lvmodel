





drop table lvmodel_stage.m_pre_itbf_campaign_requirement_options;

CREATE TABLE lvmodel_stage.m_pre_itbf_campaign_requirement_options (
	id int, 
	campaign_id int, 
	cid string,
	list_id bigint,
	session_id int,
	is_latest boolean, 
	employees_empty boolean, 
	employees_skip boolean, 
	geo_empty boolean, 
	geo_skip boolean, 
	industry_skip boolean,
	status int
)
LOCATION 's3://lvprepackage/iceberg'
TBLPROPERTIES (
  'table_type'='iceberg',
  'format'='parquet'
);





delete from lvmodel_stage.app_lv_campaign_requirement_options;





drop table lvmodel_stage.m_pre_itbf_campaign_demand_mask;

CREATE TABLE lvmodel_stage.m_pre_itbf_campaign_demand_mask(
		cid string,
		list_id bigint,
		session_id int,
		entity_type string,
		entity_demand_type string,
		bit_mask INT,
		country int,
		a_country int,
		state int,
		a_state int,
		job_level int,
		job_area int,
		job_function int,
		industry int,
		a_industry int,
		employee int,
		a_employee int,
		status int
)
LOCATION 's3://lvprepackage/iceberg'
TBLPROPERTIES (
  'table_type'='iceberg',
  'format'='parquet'
);





drop table lvmodel_stage.m_pre_itbf_final ;

CREATE TABLE lvmodel_stage.m_pre_itbf_final (
		cid string, 
		list_id int, 
		session_id int,
		email string, 
		contact_id bigint, 
		ext_contact_id bigint, 
		company_id bigint,
		ext_company_id bigint, 
		title string, 
		job_level_mapping string, 
		job_area_mapping string, 
		job_function_mapping string,
		industry_mapping string,
		sub_industry_mapping string,
		pv_comment string,
		prepackage_code int,
		rule_type string
)
LOCATION 's3://lvprepackage/iceberg'
TBLPROPERTIES (
  'table_type'='iceberg',
  'format'='parquet'
);

delete from lvmodel_stage.m_pre_itbf_final ;










drop table lvmodel_stage.m_pre_itbf_new_list_to_check ;

CREATE TABLE lvmodel_stage.m_pre_itbf_new_list_to_check  (
	id int ,
	list_id int,
	cid string,
	status int,
	prepackage_contact_count int,
	created_at timestamp,
	processed_at timestamp,
	used_at timestamp
)
LOCATION 's3://lvprepackage/iceberg'
TBLPROPERTIES (
  'table_type'='iceberg',
  'format'='parquet'
);





drop table lvmodel_stage.m_pre_itbf_contact_history_table;

CREATE TABLE lvmodel_stage.m_pre_itbf_contact_history_table  (
	campaign_id int,
	entity_type string,
	entity_id int,
	ext_entity_id int,
	attribute_name string,
	value string
)
LOCATION 's3://lvprepackage/iceberg'
TBLPROPERTIES (
  'table_type'='iceberg',
  'format'='parquet'
);





drop table lvmodel_stage.m_pre_itbf_template_demands;

CREATE TABLE lvmodel_stage.m_pre_itbf_template_demands  (
	cid string,
	list_id bigint,
	session_id int,
	entity_type string,
	field string,
	value string,
	status int
)
LOCATION 's3://lvprepackage/iceberg'
TBLPROPERTIES (
  'table_type'='iceberg',
  'format'='parquet'
);






drop table lvmodel_stage.m_pre_itbf_contact_new_collection;

CREATE TABLE lvmodel_stage.m_pre_itbf_contact_new_collection (
	cid string,
	type bigint,
	campaign_id bigint,
	list_id bigint,
	session_id int,
	email_id bigint,
	email string,
	id bigint,
	contact_id bigint,
	ext_contact_id bigint,
	title string,
	country string,
	state string,
	contact_phone string,
	mobile_phone string,
	pv_comment string,
	company_id bigint,
	ext_company_id bigint,
	employee string,
	industry string,
	company_phone string,
	status int
)
LOCATION 's3://lvprepackage/iceberg'
TBLPROPERTIES (
  'table_type'='iceberg',
  'format'='parquet'
);





drop table lvmodel_stage.m_pre_itbf_approved_new_collection;

CREATE TABLE lvmodel_stage.m_pre_itbf_approved_new_collection (
	cid string,
	list_id bigint,
	session_id int,
	contact_id bigint,
	title_approved int,
	address_approved int,
	employee_approved int,
	contact_approved int,
	status int
)
LOCATION 's3://lvprepackage/iceberg'
TBLPROPERTIES (
  'table_type'='iceberg',
  'format'='parquet'
);






CREATE TABLE lvmodel_stage.m_pre_itbf_industry_dict (
	industry string,
	sub_industry string
)
LOCATION 's3://lvprepackage/iceberg'
TBLPROPERTIES (
  'table_type'='iceberg',
  'format'='parquet'
);


insert into lvmodel.m_pre_itbf_industry_dict
select i.name , s.name 
from "lv-prepackage".app_lv.industries i
inner join "lv-prepackage".app_lv.industries s on s.parent_id = i.id;






CREATE TABLE lvmodel_stage.m_pre_itbf_pv_history (
	ext_contact_id bigint,
	contact_id bigint,
	pv_comment string,
	contact_phone string,
	mobile_phone string,
	company_phone string
)
LOCATION 's3://lvprepackage/iceberg'
TBLPROPERTIES (
  'table_type'='iceberg',
  'format'='parquet'
);




CREATE TABLE lvmodel_stage.m_pre_itbf_approve_history (
	approve_type string,
	email_id bigint,
	ext_company_id bigint, 
	date_approve timestamp, 
	value string
)
LOCATION 's3://lvprepackage/iceberg'
TBLPROPERTIES (
  'table_type'='iceberg',
  'format'='parquet'
);