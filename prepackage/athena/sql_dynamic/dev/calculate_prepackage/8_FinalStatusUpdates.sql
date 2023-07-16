/* 8 Final Status Updates */

/*Insert Final Result into common table*/
INSERT INTO lvmodel_dev.m_pre_itbf_final
SELECT * FROM lvmodel_dev.m_pre_itbf_final_?
;


DELETE FROM lvmodel_dev.m_pre_itbf_new_list_to_check WHERE list_id = lvmodel_dev.m_pre_itbf_new_list_to_check
;



/* Update statuses when calculation has been finished*/
INSERT INTO lvmodel_dev.m_pre_itbf_new_list_to_check(cid, list_id, status, prepackage_contact_count, created_at, processed_at)
WITH ST AS
(
	SELECT f.cid, f.list_id, 1 AS status, COUNT(*) AS prepackage_contact_count, NOW() AS created_at, NOW() AS processed_at
	FROM lvmodel_dev.m_pre_itbf_final_? f
	GROUP BY f.cid, f.list_id
)
SELECT cid, list_id, status, prepackage_contact_count, created_at, processed_at
FROM ST
;



insert into lvmodel_dev.m_pre_itbf_new_list_to_check(list_id, status,  created_at, processed_at)
WITH ST AS
(
	SELECT ch.list_id, -1 AS status, NOW() AS created_at, NOW() AS processed_at
	FROM lvmodel_dev.m_pre_itbf_new_list_to_check ch
	left join lvmodel_dev.m_pre_itbf_new_list_to_check_? ch1 on ch1.list_id = ch.list_id 
	where ch.status = 0 and ch1.list_id is NULL AND ch.list_id = ?
)
SELECT list_id, status, created_at, processed_at
FROM ST
;
