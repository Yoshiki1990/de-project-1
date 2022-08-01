insert into analysis.tmp_rfm_recency
with rec as(
	select * from analysis.orders o
	where o.status = 4 and extract('year' from order_ts) > 2021
	),
usertab1 as (select id
		,coalesce(max(order_ts), max(order_ts), to_timestamp('2022-01-01 00:00:00.000', 'YYYY-MM-DD HH24:MI:SS.MS')) as recent
	from analysis.users u
	left join rec f on u.id = f.user_id 
	group by u.id
)
select id as user_id
	,ntile(5) over(order by recent) as recency
from usertab1 u;