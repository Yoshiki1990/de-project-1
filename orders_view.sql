create or replace view analysis.orders as 
with ls as(
select order_id, status_id, row_number () over(partition by order_id order by dttm desc) as last_status
from production.orderstatuslog
)
select o.order_id, order_ts, user_id, bonus_payment, payment, cost, bonus_grant, ls.status_id as status from production.orders o
join ls on o.order_id = ls.order_id 
where last_status = 1;