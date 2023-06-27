/* 1.3 New Collection at LV*/
/* Import all contacts and companies from LV belong to the new list id */

insert into lvmodel.m_pre_itbf_contact_new_collection
(
	cid,
	"type",
	campaign_id,
	list_id,
	session_id,
	email_id,
	email,
	id,
	contact_id,
	ext_contact_id,
	title,
	country,
	state,
	contact_phone,
	mobile_phone,
	pv_comment,
	company_id,
	ext_company_id,
	employee,
	industry,
	company_phone,
	status
)
SELECT 
	ca.cid
	, ca.type
	, c.campaign_id
	, c.list_id
	, 0 as session_id
	, c.email_id
	, c.email
	, c.id
	, c.id AS contact_id
	, cast(c.contact_id as bigint) AS ext_contact_id
	, ct.title
	, co.short_name AS country
	, c.state
	, case when cph.phone in ('','DNC') then null else cph.phone end as contact_phone
	, case when cmp.mobile_phone in ('','DNC') then null else cmp.mobile_phone end mobile_phone
	, pr.key_name as pv_comment
	, com.id AS company_id
	, com.company_id AS ext_company_id
	, CONCAT(cast(r."min" AS varchar(255)), ';', cast(r."max" AS varchar(255))) AS employee
	, CONCAT(i.name, ';', i2.name) AS industry
	, case when comph.phone in ('','DNC') then null else comph.phone end as company_phone
	, 0
FROM "lv-prepackage".app_lv.campaigns ca
INNER JOIN "lv-prepackage".app_lv.contacts c ON c.campaign_id = ca.id
INNER JOIN "lv-prepackage".app_lv.contact_titles ct ON ct.contact_id = c.id
INNER JOIN "lv-prepackage".app_lv.lists l ON l.id = c.list_id and l.local_type = 0
INNER JOIN "lv-prepackage".app_lv.states s ON s.abbr = c.state AND s.state_id > 0
INNER JOIN "lv-prepackage".app_lv.contact_countries sc on sc.contact_id = c.id
INNER JOIN "lv-prepackage".app_lv.countries co ON co.id = sc.country_id
INNER JOIN "lv-prepackage".app_lv.companies com ON com.id = c.company_id
INNER JOIN "lv-prepackage".app_lv.company_ranges r ON r.ref_id = com.employees_ref AND r."type" = 'employee' 
INNER JOIN "lv-prepackage".app_lv.company_industries ci ON ci.ref_id = com.industry_ref
INNER JOIN "lv-prepackage".app_lv.industries i ON i.id = ci.industry_id
INNER JOIN "lv-prepackage".app_lv.industries i2 ON i2.id = ci.sub_industry_id
inner join "lv-prepackage".app_lv.phone_reasons pr on pr.id = c.phone_reason_id
left join "lv-prepackage".app_lv.contact_phones cph on cph.contact_id = c.id
left join "lv-prepackage".app_lv.contact_mobile_phones cmp on cmp.contact_id = c.id
left join "lv-prepackage".app_lv.company_phones comph on comph.ref_id = com.phone_ref
where 
	r.min < 1000000000 and r.max < 1000000000 /*to avoid int out of range error*/
	and l.id = ?
;