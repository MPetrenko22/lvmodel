/* 8 Final Status Updates */

/*Insert Final Result into common table*/
INSERT INTO lvmodel_dev.m_pre_itbf_final
SELECT * FROM lvmodel_dev.m_pre_itbf_final_?
;




/* Update statuses when calculation has been finished*/
INSERT INTO lvmodel_dev.m_pre_itbf_new_list_to_check(list_id, status, prepackage_contact_count, created_at, processed_at)
WITH ST AS
(
	SELECT f.list_id, 1 AS status, COUNT(*) AS prepackage_contact_count, NOW() AS created_at, NOW() AS processed_at
	FROM lvmodel_dev.m_pre_itbf_final_? f
	GROUP BY f.list_id
)
SELECT list_id, status, prepackage_contact_count, created_at, processed_at
FROM ST
;

