/* 2 Define Template Demand at LV*/
/* Define the new campaign template demands */

CREATE TABLE lvmodel_dev.m_pre_itbf_template_demands_?  (
	cid string,
	list_id bigint,
	session_id int,
	entity_type string,
	field string,
	value string,
	status int
)
LOCATION 's3://lvprepackage/dev/iceberg/'
TBLPROPERTIES (
  'table_type'='iceberg',
  'format'='parquet'
)
;


INSERT INTO lvmodel_dev.m_pre_itbf_template_demands_?
WITH MP AS (
		SELECT DISTINCT
			ca.cid,
			l.id AS list_id,
			0 as session_id,
			ctc.id AS column_id,
			ctc.parameter_id AS parameter_id,
			ctc.field_id AS field_id,
			ctp."parameter",
			ctm.mapping AS mapping_value
		FROM "lv-prepackage-stage".lv_athena_stage.campaign_template_columns ctc
		INNER JOIN "lv-prepackage-stage".lv_athena_stage.campaigns ca ON ca.id  = ctc.campaign_id
		INNER JOIN "lv-prepackage-stage".lv_athena_stage."campaign_template_parameters" ctp ON ctp.id = ctc.parameter_id
		INNER JOIN "lv-prepackage-stage".lv_athena_stage.campaign_templates ct ON ct.column_id = ctc.id
		INNER JOIN "lv-prepackage-stage".lv_athena_stage.campaign_template_mappings ctm ON ctm.campaign_template_id = ct.id
		INNER JOIN "lv-prepackage-stage".lv_athena_stage.lists l on l.campaign_id = ca.id
		WHERE l.id = ?
)
SELECT 
	cid, 
	CAST(list_id AS bigint),
	session_id,
	CASE WHEN "parameter" IN  ('country', 'state', 'job_level', 'job_area', 'job_function') THEN 'contact' WHEN  "parameter" IN  ( 'industry', 'sub_industry','employees') THEN 'company' ELSE NULL END AS entity_type, 
	"parameter", 
	CASE WHEN mapping_value IN ( 'Unated State', 'United States', 'Unated States', 'US') AND "parameter" IN ('country','a_country') THEN 'USA' ELSE mapping_value END AS mapping_value
FROM MP
WHERE mapping_value IS NOT NULL
;