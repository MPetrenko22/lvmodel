
/* Clean contact history table before new load */
delete from lvmodel.m_pre_itbf_contact_history_table;


/* Load contact history datea */
insert into lvmodel.m_pre_itbf_contact_history_table
WITH CC AS (
		SELECT ca.cid, ca.type, c.campaign_id, c.email, c.id AS contact_id, c.contact_id AS ext_contact_id, ct.title, c.state,
						com.id AS company_id, com.company_id AS ext_company_id
		FROM "lv-prepackage".app_lv.campaigns ca
		INNER JOIN "lv-prepackage".app_lv.contacts c ON c.campaign_id = ca.id
		INNER JOIN "lv-prepackage".app_lv.contact_titles ct ON ct.contact_id = c.id
		INNER JOIN "lv-prepackage".app_lv.lists l ON l.id = c.list_id and l.local_type = 0
		INNER JOIN "lv-prepackage".app_lv.companies com ON com.id = c.company_id
		WHERE ca.type = 2
					AND c.ov_status_id IN (27,28,29,30,31) 
),
JF AS (
		SELECT 	cid, type, campaign_id, email,  contact_id,  ext_contact_id, parameter, mapping
		FROM 
				(SELECT DISTINCT c.contact_id , c.email, t.title, ca.cid, ca.type, c.ext_contact_id, c.campaign_id,
									ctm1.id AS param_id, par1.parameter , ctm1.mapping,
									rtm1.template_id, rtm1.history_order, ss.version_id
				FROM  "lv-prepackage".app_lv.campaign_template_mappings ctm1
				INNER  JOIN  "lv-prepackage".app_lv.report_template_mappings rtm1 on rtm1.mapping_id = ctm1.id 
				INNER  JOIN  "lv-prepackage".app_lv.campaign_template_columns col1 on col1.id = rtm1.template_column_id
				INNER  JOIN  "lv-prepackage".app_lv.campaign_template_parameters par1 on col1.parameter_id = par1.id
				INNER  JOIN CC c ON c.contact_id = rtm1.entity_id AND rtm1.entity_type = 'App\Contact'
				INNER JOIN "lv-prepackage".app_lv.contact_titles t ON t.contact_id = c.contact_id
				INNER JOIN "lv-prepackage".app_lv.campaigns ca ON c.campaign_id = ca.id
				INNER JOIN "lv-prepackage".app_lv.campaign_templates ss ON ss.id = rtm1.template_id
					AND rtm1.history_order = 0) jlev
),
IND AS (
		SELECT DISTINCT c.company_id , c.ext_company_id, c.campaign_id,
							ctm1.id AS param_id, par1.parameter , ctm1.mapping,
							rtm1.template_id, rtm1.history_order
		FROM  "lv-prepackage".app_lv.campaign_template_mappings ctm1
		INNER  JOIN  "lv-prepackage".app_lv.report_template_mappings rtm1 on rtm1.mapping_id = ctm1.id 
		INNER  JOIN  "lv-prepackage".app_lv.campaign_template_columns col1 on col1.id = rtm1.template_column_id
		INNER  JOIN  "lv-prepackage".app_lv.campaign_template_parameters par1 on col1.parameter_id = par1.id
		INNER  JOIN CC c ON c.company_id = rtm1.entity_id AND rtm1.entity_type = 'App\Company'
      	WHERE  par1.parameter in ('industry', 'sub_industry')
				AND rtm1.history_order = 0
)
SELECT CC.campaign_id, 'contact' AS entity_type, contact_id AS entity_id, ext_contact_id AS ext_entity_id,  'title' AS attribute_name, title AS value
FROM CC
/**/
UNION 
SELECT JF.campaign_id, 'contact' AS entity_type, contact_id, ext_contact_id,  parameter AS attribute_name, mapping AS value
FROM JF
/**/
UNION
select distinct CC.campaign_id, 'contact' AS entity_type, CC.contact_id, CC.ext_contact_id,  'a_country' AS attribute_name, co.short_name AS VALUE
FROM CC
INNER JOIN "lv-prepackage".app_lv.contact_countries s on s.contact_id  = CC.contact_id
INNER JOIN "lv-prepackage".app_lv.countries co ON co.id = s.country_id
/**/
UNION
SELECT distinct CC.campaign_id, 'contact' AS entity_type, CC.contact_id, CC.ext_contact_id,  'a_state' AS attribute_name, CC.state AS VALUE
FROM CC
/**/
UNION
SELECT IND.campaign_id, 'company' AS entity_type, IND.company_id, IND.ext_company_id,  IND.parameter, IND.mapping AS VALUE 
FROM IND
/**/
UNION
SELECT distinct CC.campaign_id, 'company' AS entity_type, CC.company_id, CC.ext_company_id, 'a_industry' AS attribute_name, i.name AS value
FROM CC
INNER JOIN "lv-prepackage".app_lv.companies com ON com.id = CC.company_id
INNER JOIN "lv-prepackage".app_lv.company_industries ci ON ci.ref_id = com.industry_ref
INNER JOIN "lv-prepackage".app_lv.industries i ON i.id = ci.industry_id
/**/
UNION
SELECT CC.campaign_id, 'company' AS entity_type, CC.company_id, CC.ext_company_id, 'a_sub_industry' AS attribute_name, i.name AS value
FROM CC
INNER JOIN "lv-prepackage".app_lv.companies com ON com.id = CC.company_id
INNER JOIN "lv-prepackage".app_lv.company_industries ci ON ci.ref_id = com.industry_ref
INNER JOIN "lv-prepackage".app_lv.industries i ON i.id = ci.sub_industry_id 
/**/
UNION
SELECT CC.campaign_id, 'company' AS entity_type, CC.company_id, CC.ext_company_id, 'a_employee' AS attribute_name, CONCAT(cast(r."min" as varchar(20)), ';', cast(r."max"as varchar(20))) AS value
FROM CC
INNER JOIN "lv-prepackage".app_lv.companies com ON com.id = CC.company_id
INNER JOIN "lv-prepackage".app_lv.company_ranges r ON r.ref_id = com.employees_ref AND r.type = 'employee'
where r.min < 1000000000 and r.max < 1000000000
/**/
union 
SELECT 	distinct 	
		ca.id AS campaign_id
		, 'company' AS entity_type
		, com0.id AS entiry_id
		, com0.company_id AS ext_entity_id
		, f."field" AS attribute_name
		, REPLACE(cast(JSON_EXTRACT(r.cells, CONCAT('$.', cast(dmc.column_id as varchar(10)), '.value') ) as varchar(255)), '"', '') AS "value"
FROM "lv-prepackage".app_lv.campaigns ca
INNER JOIN "lv-prepackage".app_lv.lists l3                    ON l3."campaign_id" = ca."id" AND l3."local_type" = 3     
INNER JOIN "lv-prepackage".app_lv.list_report_data_mapped lr  ON lr."list_id" = l3."id"
INNER JOIN "lv-prepackage".app_lv.data_mapped_columns dmc     ON dmc."sheet_id" = lr."data_mapped_sheet_id"        
INNER JOIN "lv-prepackage".app_lv.data_mapped_rows r          ON r."sheet_id" = lr."data_mapped_sheet_id"           
INNER JOIN "lv-prepackage".app_lv.campaign_template_columns rtm1    ON rtm1."campaign_id" = ca."id"
INNER JOIN "lv-prepackage".app_lv.campaign_template_parameters par  ON par."id" = rtm1."parameter_id" AND par."parameter" = dmc."title"
INNER JOIN "lv-prepackage".app_lv.campaign_template_fields f        ON f."id" = rtm1."field_id"                     
INNER JOIN "lv-prepackage".app_lv.contacts c3 ON c3.id = r."row_id"
INNER JOIN "lv-prepackage".app_lv.lists l0 ON l0.id = l3.parent_id AND l0.local_type = 0
INNER JOIN "lv-prepackage".app_lv.contacts c0 ON c0.list_id = l0.id AND c0.email_id = c3.email_id
INNER JOIN "lv-prepackage".app_lv.companies com0 ON com0.id = c0.company_id
inner join CC on CC.company_id = com0.id
WHERE r."row_id" > 0  
	AND dmc."title" IN ('employees')
UNION
SELECT 
	ca.id AS campaign_id
	, 'contact' AS entity_type
	, c0.id AS entity_id
	, c0.contact_id AS ext_entity_id
	, f.field AS attribute_name
	, REPLACE(cast(JSON_EXTRACT(r.cells, CONCAT('$.', cast(dmc.column_id as varchar(10)), '.value') ) as varchar(255)), '"', '') AS value
FROM "lv-prepackage".app_lv.campaigns ca
INNER JOIN "lv-prepackage".app_lv.lists l3                    ON l3.campaign_id = ca.id AND l3.local_type = 3     
INNER JOIN "lv-prepackage".app_lv.list_report_data_mapped lr  ON lr.list_id = l3.id
INNER JOIN "lv-prepackage".app_lv.data_mapped_columns dmc     ON dmc.sheet_id = lr.data_mapped_sheet_id        
INNER JOIN "lv-prepackage".app_lv.data_mapped_rows r          ON r.sheet_id = lr.data_mapped_sheet_id          
INNER JOIN "lv-prepackage".app_lv.campaign_template_columns rtm1    ON rtm1.campaign_id = ca.id
INNER JOIN "lv-prepackage".app_lv.campaign_template_parameters par  ON par.id = rtm1.parameter_id AND par.parameter = dmc.title
INNER JOIN "lv-prepackage".app_lv.campaign_template_fields f        ON f.id = rtm1.field_id                   
INNER JOIN "lv-prepackage".app_lv.contacts c3 ON c3.id = r.row_id
INNER JOIN "lv-prepackage".app_lv.lists l0 ON l0.id = l3.parent_id AND l0.local_type = 0
INNER JOIN "lv-prepackage".app_lv.contacts c0 ON c0.list_id = l0.id AND c0.email_id = c3.email_id
INNER JOIN CC ON CC.contact_id = c0.id
WHERE
	r.row_id > 0
	AND dmc.title IN ('country', 'state')
;



/* Update country mapping at contact history  - different name into one standart USA */
UPDATE lvmodel.m_pre_itbf_contact_history_table 
SET "value" = 'USA'
WHERE "value" IN ( 'Unated State', 'United States', 'Unated States', 'US') AND attribute_name IN ('country','a_country');






/* Clean PV statuses history table */
delete from lvmodel.m_pre_itbf_pv_history;


/* Load PV history */
insert into lvmodel.m_pre_itbf_pv_history
with CON as (
	select distinct ext_entity_id as ext_contact_id
	from lvmodel.m_pre_itbf_contact_history_table h
	where h.entity_type = 'contact'
),
PV as (
	select 
		CON.ext_contact_id
		, c.id
		, c.email
		, c.phone_reason_id
		, r.key_name as pv_comment
		, v.date
		, row_number()over(partition by CON.ext_contact_id order by v.date desc, c.id desc) rn
		, case when cph.phone in ('','DNC') then null else cph.phone end as contact_phone
		, case when cmp.mobile_phone in ('','DNC') then null else cmp.mobile_phone end mobile_phone
		, case when comph.phone in ('','DNC') then null else comph.phone end as company_phone
	from CON
	inner join "lv-prepackage".app_lv.contacts c on c.contact_id = CON.ext_contact_id
	inner join "lv-prepackage".app_lv.phone_reasons r on r.id = c.phone_reason_id
	inner join "lv-prepackage".app_lv.verifications v ON v.id = c.lvp
	inner join "lv-prepackage".app_lv.companies com on com.id = c.company_id
	left join "lv-prepackage".app_lv.contact_phones cph on cph.contact_id = c.id
	left join "lv-prepackage".app_lv.contact_mobile_phones cmp on cmp.contact_id = c.id
	left join "lv-prepackage".app_lv.company_phones comph on comph.ref_id = com.phone_ref
	where DATE(v.date + INTERVAL '180' day) > NOW()
)
select 
	PV.ext_contact_id
	, PV.id
	, PV.pv_comment
	, PV.contact_phone
	, PV.mobile_phone
	, PV.company_phone
from PV
where PV.rn = 1
	and PV.pv_comment in ('lc1','lc2','lc3','lc4','cc1','cc2','cc3','cc4')
;






/* Clean Approve history table  */
delete from lvmodel.m_pre_itbf_approve_history ;


/* Load Approve history */
insert into lvmodel.m_pre_itbf_approve_history 
with 
APR_TIT as (
	select 'title' as approve_type, h.email_id, null as ext_company_id, h.date_approve, h.title_value, row_number()over(partition by h.email_id order by h.date_approve desc) rn
	from "lv-prepackage".app_lv.contacts_approves_history h 
	where h.title_value is not null
		and DATE(h.date_approve + INTERVAL '180' day) > NOW()	
),
APR_ST as (
	select 'state' as approve_type, h.email_id, null as ext_company_id, h.date_approve, h.state_value, row_number()over(partition by h.email_id order by h.date_approve desc) rn
	from "lv-prepackage".app_lv.contacts_approves_history h 
	where h.state_value is not null
),
APR_CN as (
	select 'country' as approve_type, h.email_id, null as ext_company_id, h.date_approve, c.short_name as country_value, row_number()over(partition by h.email_id order by h.date_approve desc) rn
	from "lv-prepackage".app_lv.contacts_approves_history h
	inner join "lv-prepackage".app_lv.countries c on cast(c.id as varchar(100)) = h.country_value
),
APR_EMP as (
	select 'employee' as approve_type, null email_id, h.ext_company_id as ext_company_id, h.date_approve, 
			concat(cast(h.employees_min_value as varchar(20)),';', cast(h.employees_max_value as varchar(20))) as employee_value, 
			row_number()over(partition by h.ext_company_id order by h.date_approve desc) rn
	from  "lv-prepackage".app_lv.companies_approves_history h
	where h.employees_min_value < 1000000000 and h.employees_max_value < 1000000000
		and h.employees_min_value is not null
		and DATE(h.date_approve + INTERVAL '360' day) > NOW()
)
select approve_type, email_id, ext_company_id, date_approve, title_value as value
from APR_TIT
where rn = 1
union all 
select approve_type, email_id, ext_company_id, date_approve, state_value as value
from APR_ST
where rn = 1
union all 
select approve_type, email_id, ext_company_id, date_approve, country_value as value
from APR_CN
where rn = 1
union all
select approve_type, email_id, ext_company_id, date_approve, employee_value as value
from APR_EMP
where rn = 1
;



