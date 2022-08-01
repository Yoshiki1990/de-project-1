insert into analysis.tmp_rfm_monetary_value
with rec as(
	select * from analysis.orders o
	where o.status = 4 and extract('year' from order_ts) > 2021
	),
usertab3 as (select id
		,coalesce(sum(payment), sum(payment), 0) as pay_sum
	from analysis.users u
	left join rec f on u.id = f.user_id 
	group by u.id
)
select id as user_id
	,ntile(5) over(order by pay_sum) as monetary_value
from usertab3 u;

