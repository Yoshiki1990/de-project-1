insert into analysis.tmp_rfm_frequency
with rec as(
	select * from analysis.orders o
	where o.status = 4 and extract('year' from order_ts) > 2021
	),
usertab2 as (select id
		,coalesce(count(distinct order_id),count(distinct order_id), 0) as cnt
	from analysis.users u
	left join rec f on u.id = f.user_id 
	group by u.id
)
select id as user_id
	,ntile(5) over(order by cnt) as frequency
from usertab2 u;