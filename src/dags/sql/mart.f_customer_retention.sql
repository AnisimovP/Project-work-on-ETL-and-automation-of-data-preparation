delete from mart.f_customer_retention;

insert into mart.f_customer_retention (period_id,
                                       new_customers_count, 
                                       returning_customers_count, 
                                       refunded_customer_count, 
                                       period_name, item_id, 
                                       new_customers_revenue, 
                                       returning_customers_revenue,
                                       customers_refunded)
with tabl as (
 select distinct
 	tabl1.period_id as period_id,
 	tabl1.customer_id as customer_id,
 	case when tabl1.status='shipped' and tabl1.cust_events_count = 1 then 'Y' else 'N' end as is_new_cust,
 	case when tabl1.status='refunded' then 'Y' end as is_refunded
 from 	(select 
			d.week_of_year as period_id,
			s.customer_id as customer_id,
			s.status as status,
			count(s.id) as cust_events_count
		from mart.f_sales as s
		left join mart.d_calendar as d on s.date_id = d.date_id
		group by period_id, customer_id, status) tabl1),
tabl2 as (
	select 
		d.week_of_year as period_id,
		s.customer_id as customer_id,
		s.status as status,
		s.item_id as item_id,
		count(s.id) as cust_events_count,
		sum(s.payment_amount) as revenue
	from mart.f_sales as s
		left join mart.d_calendar as d on s.date_id = d.date_id
	group by period_id, customer_id, status, item_id
		)		
			select 
			 	tabl2.period_id as period_id,
			 	count(case when tabl2.status='shipped' and tabl.is_new_cust = 'Y'  then 1 end) as new_customers_count,
			 	count(case when tabl2.status='shipped' and tabl.is_new_cust = 'N'  then 1 end) as returning_customers_count,
			 	count(case when tabl2.status='refunded' and tabl.is_refunded = 'Y' then 1 end) as refunded_customer_count,
			 	('weekly') as period_name,
			 	tabl2.item_id as item_id,
			 	sum (case when tabl.is_new_cust = 'Y' then tabl2.revenue end) as new_customers_revenue,
			 	sum (case when tabl.is_new_cust = 'N' then tabl2.revenue end) as returning_customers_revenue,
			 	sum (case when tabl2.status = 'refunded' then tabl2.cust_events_count end) as customers_refunded
		 	from tabl2 left join tabl on tabl.period_id = tabl2.period_id and tabl.customer_id = tabl2.customer_id
		 	group by tabl2.period_id, tabl2.item_id;