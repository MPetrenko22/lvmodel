/* 1.2 Clean previous records of new list id from Result Table (if new list id was calculated before)*/

DELETE FROM lvmodel_dev.m_pre_itbf_final WHERE list_id = ?
;
