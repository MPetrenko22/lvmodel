/* 1.3 New Collection at LV*/
/* Import all contacts and companies from LV belong to the new list id */

CREATE TABLE lvmodel_dev.m_pre_itbf_contact_new_collection_?
LOCATION 's3://lvprepackage/dev/iceberg/'
TBLPROPERTIES (
  'table_type'='iceberg',
  'format'='parquet'
)
AS SELECT DISTINCT
	ca.cid
	, ca.type
	, c.campaign_id
	, c.list_id
	, 0 AS session_id
	, c.email_id
	, c.email
	, c.id
	, c.id AS contact_id
	, CAST(c.contact_id AS bigint) AS ext_contact_id
	, ct.title
	, co.short_name AS country
	, c.state
	, CASE WHEN cph.phone IN ('','DNC') THEN NULL ELSE cph.phone END AS contact_phone
	, CASE WHEN cmp.mobile_phone IN ('','DNC') THEN NULL ELSE cmp.mobile_phone END AS mobile_phone
	, pr.key_name AS pv_comment
	, com.id AS company_id
	, com.company_id AS ext_company_id
	, CONCAT(CAST(r."min" AS varchar(255)), ';', CAST(r."max" AS varchar(255))) AS employee
	, CONCAT(i.name, ';', i2.name) AS industry
	, CASE WHEN comph.phone IN ('','DNC') THEN NULL ELSE comph.phone END AS company_phone
	, 0
FROM "lv-prepackage-stage".lv_athena_stage.campaigns ca
INNER JOIN "lv-prepackage-stage".lv_athena_stage.contacts c ON c.campaign_id = ca.id
INNER JOIN "lv-prepackage-stage".lv_athena_stage.contact_titles ct ON ct.contact_id = c.id
INNER JOIN "lv-prepackage-stage".lv_athena_stage.lists l ON l.id = c.list_id and l.local_type = 0
INNER JOIN "lv-prepackage-stage".lv_athena_stage.states s ON s.abbr = c.state AND s.state_id > 0
INNER JOIN "lv-prepackage-stage".lv_athena_stage.contact_countries sc on sc.contact_id = c.id
INNER JOIN "lv-prepackage-stage".lv_athena_stage.countries co ON co.id = sc.country_id
INNER JOIN "lv-prepackage-stage".lv_athena_stage.companies com ON com.id = c.company_id
INNER JOIN "lv-prepackage-stage".lv_athena_stage.company_ranges r ON r.ref_id = com.employees_ref AND r."type" = 'employee' 
INNER JOIN "lv-prepackage-stage".lv_athena_stage.company_industries ci ON ci.ref_id = com.industry_ref
INNER JOIN "lv-prepackage-stage".lv_athena_stage.industries i ON i.id = ci.industry_id
INNER JOIN "lv-prepackage-stage".lv_athena_stage.industries i2 ON i2.id = ci.sub_industry_id
INNER JOIN "lv-prepackage-stage".lv_athena_stage.phone_reasons pr ON pr.id = c.phone_reason_id
LEFT JOIN "lv-prepackage-stage".lv_athena_stage.contact_phones cph ON cph.contact_id = c.id
LEFT JOIN "lv-prepackage-stage".lv_athena_stage.contact_mobile_phones cmp ON cmp.contact_id = c.id
LEFT JOIN "lv-prepackage-stage".lv_athena_stage.company_phones comph ON comph.ref_id = com.phone_ref
WHERE 
	r.min < 1000000000 AND r.max < 1000000000 /*to avoid int out of range error*/
	AND l.id = ?
;
