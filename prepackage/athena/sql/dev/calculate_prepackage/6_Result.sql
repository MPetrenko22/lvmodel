/* 6 Result*/
/* Insert into Result tables contacts which is Prepackage for new list id*/

insert into lvmodel_dev.m_pre_itbf_final
(
	cid, 
	list_id, 
	session_id,
	email, 
	contact_id, 
	ext_contact_id, 
	company_id,
	ext_company_id, 
	title, 
	job_level_mapping, 
	job_area_mapping, 
	job_function_mapping,
	industry_mapping,
	sub_industry_mapping,
	pv_comment,
	prepackage_code,
	rule_type
)
WITH NC AS (
		SELECT distinct a.contact_id, a.list_id, a.ext_contact_id, a.title, a.country, a.state, a.company_id, a.ext_company_id, a.employee, a.industry, a.cid
		FROM lvmodel_dev.m_pre_itbf_contact_new_collection a
		inner join lvmodel_dev.m_pre_itbf_approved_new_collection f on f.contact_id = a.contact_id and f.cid = a.cid and f.contact_approved = 1
		where  a.list_id = ?
),
CC AS (
		SELECT DISTINCT NC.cid, NC.list_id, NC.contact_id AS new_contact_id, h.entity_id, 'contact_id+title' AS rule_type, NULL AS title
		FROM NC
		INNER JOIN lvmodel_dev.m_pre_itbf_contact_history_table h ON h.ext_entity_id = NC.ext_contact_id AND h.attribute_name = 'title' AND h.value = NC.title
		UNION ALL
		SELECT DISTINCT NC.cid, NC.list_id, NC.contact_id AS new_contact_id, h.entity_id, 'title' AS rule_type, NC.title
		FROM NC
		INNER JOIN lvmodel_dev.pre2_new_title_cm t ON t.title = NC.title
		INNER JOIN lvmodel_dev.m_pre_itbf_contact_history_table h ON h.entity_type = 'contact' AND h.attribute_name = 'title' AND h.value = NC.title
),
RES_C AS (
		SELECT CC.cid, CC.list_id, CC.new_contact_id, h.entity_id, h.campaign_id, h.entity_type, h.ext_entity_id, h.attribute_name, h.value AS value_h, CC.rule_type, CC.title
		FROM CC
		INNER JOIN lvmodel_dev.m_pre_itbf_contact_history_table h ON CC.entity_id = h.entity_id  AND h.entity_type = 'contact'
),
RES_COM AS (
		SELECT DISTINCT NC.cid, NC.list_id, NC.ext_company_id, h.entity_id, h.campaign_id, h.entity_type, h.ext_entity_id, h.attribute_name, h.value AS value_h, NULL AS rule_type, NULL AS title
		FROM NC
		INNER JOIN lvmodel_dev.m_pre_itbf_contact_history_table h ON h.ext_entity_id = NC.ext_company_id AND h.entity_type = 'company'
),
RES_T AS (
		SELECT  *
		FROM RES_C
		UNION ALL
		SELECT *
		FROM RES_COM
),
RES AS (
		SELECT DISTINCT 
			RES_T.cid, RES_T.list_id, RES_T.new_contact_id, RES_T.entity_id, RES_T.campaign_id, RES_T.entity_type, RES_T.ext_entity_id, RES_T.attribute_name, 
			CASE 
				WHEN RES_T.attribute_name = 'job_level' AND RES_T.rule_type = 'title' AND nt.id IS NOT NULL THEN nt.job_level
				WHEN RES_T.attribute_name = 'job_area' AND RES_T.rule_type = 'title' AND nt.id IS NOT NULL THEN nt.job_area
				WHEN RES_T.attribute_name = 'job_function' AND RES_T.rule_type = 'title' AND nt.id IS NOT NULL THEN nt.job_function
				ELSE RES_T.value_h
			END value_h,
			D.cid AS cid_d, RES_T.rule_type
		FROM RES_T
		INNER JOIN lvmodel_dev.m_pre_itbf_template_demands D ON D.cid = RES_T.cid and D.list_id = RES_T.list_id AND D.entity_type = RES_T.entity_type AND D.field = RES_T.attribute_name AND D.value = RES_T.value_h
		LEFT JOIN lvmodel_dev.pre2_new_title_cm nt ON nt.title = RES_T.title AND RES_T.attribute_name IN ('job_level', 'job_area', 'job_function')
		UNION ALL
		SELECT a.cid, a.list_id, a.contact_id, H.entity_id, H.campaign_id, H.entity_type, H.ext_entity_id, H.attribute_name,  a.country AS value, a.cid AS cid_d, NULL
		FROM NC a
		INNER JOIN RES_C H ON H.entity_type = 'contact' AND H.new_contact_id = a.contact_id AND H.attribute_name = 'a_country' AND a.country = H.value_h
		UNION ALL
		SELECT a.cid, a.list_id, a.contact_id, H.entity_id, H.campaign_id, H.entity_type, H.ext_entity_id, H.attribute_name,  a.state AS value, a.cid AS cid_d, NULL
		FROM NC a
		INNER JOIN RES_C H ON H.entity_type = 'contact' AND H.new_contact_id = a.contact_id AND H.attribute_name = 'a_state' AND a.state = H.value_h
		UNION ALL
		SELECT a.cid, a.list_id, a.ext_company_id, H.entity_id, H.campaign_id, H.entity_type, H.ext_entity_id, H.attribute_name,  a.industry AS value, a.cid AS cid_d, NULL
		FROM NC a
		INNER JOIN RES_COM H ON H.entity_type = 'company' AND H.ext_entity_id = a.ext_company_id AND H.attribute_name = 'a_industry' 
		INNER JOIN RES_COM H2 ON H2.campaign_id = H.campaign_id and H2.list_id = H.list_id AND H2.entity_type = 'company' AND H2.attribute_name = 'a_sub_industry' AND H2.entity_id = H.entity_id AND CONCAT(H.value_h, ';', H2.value_h) = a.industry
		UNION ALL
		SELECT a.cid, a.list_id, a.ext_company_id, H.entity_id, H.campaign_id, H.entity_type, H.ext_entity_id, H.attribute_name,  a.employee AS value, a.cid AS cid_d, NULL
		FROM NC a
		INNER JOIN RES_COM H ON  H.entity_type = 'company' AND H.ext_entity_id = a.ext_company_id AND H.attribute_name = 'a_employee' AND a.employee = H.value_h
),
RES1 as (
	select cid, list_id, new_contact_id, entity_id, campaign_id, entity_type, ext_entity_id, attribute_name, value_h, cid_d, rule_type,
		if(attribute_name = 'country', 1, 0) as country,
		if(attribute_name = 'a_country', 1, 0) as a_country,
		if(attribute_name = 'state', 1, 0) as state,
		if(attribute_name = 'a_state', 1, 0) as a_state,
		if(attribute_name = 'job_level', 1, 0) as job_level,
		if(attribute_name = 'job_area', 1, 0) as job_area,
		if(attribute_name = 'job_function', 1, 0) as job_function,
		if(attribute_name = 'industry', 1, 0) as industry,
		if(attribute_name = 'sub_industry', 1, 0) as sub_industry,
		if(attribute_name = 'a_industry', 1, 0) as a_industry,
		if(attribute_name = 'employees', 1, 0) as employee,
		if(attribute_name = 'a_employee', 1, 0) as a_employee
	from RES
),
SAT AS (
		SELECT  cid, list_id, entity_type, entity_id, new_contact_id, max(rule_type) rule_type,
				max(country) country, max(a_country) a_country, max(state) state, max(a_state) a_state, max(job_level) job_level, max(job_area) job_area, 
				max(job_function) job_function, max(industry) industry, max(sub_industry) sub_industry, max(a_industry) a_industry, max(employee) employee, max(a_employee) a_employee,
				max(jl) jl, max(ja) ja, max(jf) jf
		FROM (
				SELECT DISTINCT 
					cid, list_id, entity_type, entity_id, new_contact_id, rule_type, country, a_country, state, a_state, job_level, job_area, job_function, industry, sub_industry, a_industry, employee, a_employee,
					case when attribute_name = 'job_level' then value_h else null end jl,
					case when attribute_name = 'job_area' then value_h else null end ja,
					case when attribute_name = 'job_function' then value_h else null end jf
				FROM RES1
				) AA
		GROUP BY AA.cid, AA.list_id, AA.entity_type, AA.entity_id, AA.new_contact_id
),
FIN as (
		SELECT 
			a.cid, 
			a.list_id, 
			a.session_id,
			a.email, 
			a.contact_id, 
			a.ext_contact_id, 
			a.company_id,
			a.ext_company_id, 
			a.title,
			a.pv_comment,
			s1.jl as job_level_mapping, 
			s1.ja as job_area_mapping, 
			s1.jf as job_function_mapping, 
			s1.rule_type,
			row_number()over(partition by a.cid, a.list_id, a.contact_id order by s1.entity_id desc) rn,
			IND.industry_h,
			IND.sub_industry_h
		FROM lvmodel_dev.m_pre_itbf_contact_new_collection a
		INNER JOIN SAT AS s1 ON a.cid = s1.cid and a.list_id = s1.list_id AND s1.entity_type = 'contact' AND s1.new_contact_id = a.contact_id
		INNER JOIN (SELECT DISTINCT cid, list_id, country, a_country, state, a_state, job_level, job_area, job_function  FROM lvmodel_dev.m_pre_itbf_campaign_demand_mask) DM1
			ON DM1.cid = s1.cid and DM1.list_id = s1.list_id and s1.entity_type = 'contact'
				AND (DM1.country = 1 and DM1.country = s1.country OR DM1.country = 0) 
				AND (DM1.a_country = 1 and DM1.a_country = s1.a_country OR DM1.a_country = 0)
				AND (DM1.state = 1 and DM1.state = s1.state OR DM1.state = 0)
				AND (DM1.a_state = 1 and DM1.a_state = s1.a_state OR DM1.a_state = 0)
				AND (DM1.job_level = 1 and DM1.job_level = s1.job_level OR DM1.job_level = 0)
				AND (DM1.job_area = 1 and DM1.job_area = s1.job_area OR DM1.job_area = 0)
				AND (DM1.job_function = 1 and DM1.job_function = s1.job_function OR DM1.job_function = 0)			
		INNER JOIN SAT AS s2 ON a.cid = s2.cid and a.list_id = s2.list_id AND s2.entity_type = 'company' AND s2.new_contact_id = a.ext_company_id
		INNER JOIN (SELECT DISTINCT cid, list_id, industry, a_industry, employee, a_employee  FROM lvmodel_dev.m_pre_itbf_campaign_demand_mask) DM2 
			ON DM2.cid = s2.cid and DM2.list_id = s2.list_id AND s2.entity_type = 'company'
				AND (DM2.industry = 1 and DM2.industry = s2.industry OR DM2.industry = 0)
				AND (DM2.industry = 1 and DM2.industry = s2.sub_industry OR DM2.industry = 0)
				AND (DM2.a_industry = 1 and DM2.a_industry = s2.a_industry OR DM2.a_industry = 0)
				AND (DM2.employee = 1 and DM2.employee = s2.employee OR DM2.employee = 0)
				AND (DM2.a_employee = 1 and DM2.a_employee = s2.a_employee OR DM2.a_employee = 0)
		INNER JOIN 
			(
				select II.new_contact_id, II.attribute_name, II.value_h as industry_h, SS.value_h as sub_industry_h
				from RES II
				inner join RES SS on SS.entity_id = II.entity_id and II.new_contact_id = SS.new_contact_id and SS.entity_type = 'company' and SS.attribute_name = 'sub_industry'
				inner join lvmodel_dev.m_pre_itbf_industry_dict SI on SI.industry = II.value_h and SI.sub_industry = SS.value_h
				where II.entity_type = 'company' and II.attribute_name = 'industry'
			) IND on IND.new_contact_id = a.ext_company_id
		where a.list_id = ?
)
select cid, list_id, session_id, email, contact_id, ext_contact_id, company_id, ext_company_id, title, job_level_mapping, job_area_mapping, job_function_mapping, industry_h, sub_industry_h, pv_comment, 2 as prepackage_code, rule_type
from FIN
where rn = 1
;
