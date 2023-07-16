insert into lvmodel_dev.m_pre_itbf_new_list_to_check(list_id, status, created_at, processed_at)
with MX as
(
	select c.list_id, MAX(created_at) created_at_max
	from lvmodel_dev.m_pre_itbf_new_list_to_check c
	where c.list_id = ?
	group by c.list_id
)
select ch.list_id, -1 as status, NOW() AS created_at, NOW() AS processed_at
from lvmodel_dev.m_pre_itbf_new_list_to_check ch
inner join MX on MX.list_id = ch.list_id and ch.created_at = MX.created_at_max
where ch.status = 0
;
