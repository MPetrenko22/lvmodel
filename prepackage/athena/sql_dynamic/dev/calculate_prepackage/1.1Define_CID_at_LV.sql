/* 1.1 Define CID at LV */
/*Create tmp table*/

CREATE TABLE lvmodel_dev.m_pre_itbf_new_list_to_check_? (
	cid string,
	list_id int,
	cid string,
	status int,
	prepackage_contact_count int
)
LOCATION 's3://lvprepackage/dev/iceberg/'
TBLPROPERTIES (
  'table_type'='iceberg',
  'format'='parquet'
)
;


INSERT INTO lvmodel_dev.m_pre_itbf_new_list_to_check_?
(cid, list_id, status)
SELECT ca.cid, l.id AS list_id, 0 AS status
FROM "lv-prepackage-stage".lv_athena_stage.lists l 
INNER JOIN "lv-prepackage-stage".lv_athena_stage.campaigns ca on ca.id = l.campaign_id and ca.type = 2
WHERE l.id = ?
;


INSERT INTO lvmodel_dev.m_pre_itbf_new_list_to_check (cid, list_id, status, created_at)
SELECT cid, list_id, CASE WHEN COUNT(*) > 0 THEN 0 ELSE -1 END, NOW() FROM lvmodel_dev.m_pre_itbf_new_list_to_check_?
GROUP BY cid, list_id
;
