use mavenfuzzyfactory;

-- 1

select (select count(distinct order_id) from superstore where ship_date=order_date)/count(distinct order_id) as perc_of_total_orders
from superstore;

select distinct order_id, Ship_Date,Order_Date from superstore where ship_date=order_date;

-- 2

select customer_name, sum(sales) as TotalOrderValue
from superstore
group by 1
order by 2 desc
limit 3;

-- 3

select distinct product_id, avg(sales) as average_sales
from superstore 
group by 1
order by 2 desc
limit 5;

-- 4

select customer_name, avg(sales) as average_order_value
from superstore
group by 1
order by 2 desc;

-- 5

select city, highest_orders,lowest_orders,highest_customer_name,lowest_customer_name
from(
select ho.*,lo.lowest_customer_name,lo.lowest_orders
from
(with highest_orders as (
select city,customer_name as highest_customer_name, sum(sales) as highest_orders
from superstore
group by 1,2
order by 1)
select a.*
from highest_orders a
left join highest_orders b on a.city=b.city and a.highest_orders<b.highest_orders
where b.highest_orders is null) as ho

inner join (

with lowest_orders as (
select city, customer_name as lowest_customer_name, sum(sales) as lowest_orders
from superstore
group by 1,2
order by 1)
select a.*
from lowest_orders a
left join lowest_orders b on a.city=b.city and a.lowest_orders>b.lowest_orders
where b.lowest_orders is null) as lo on ho.city=lo.city) as final_table;

-- 6

select sub_category, sum(sales) as total_sales
from superstore
where Region="west"
group by 1
order by 2 desc
limit 1;

-- 7

select order_id, count(product_id) as no_of_products
from superstore
group by 1
order by 2 desc
limit 1;





-- 8

select order_id, sum(sales) as cumulative_value
from superstore
group by 1
order by 2 desc
limit 1;

-- 9
select segment
from superstore
where ship_mode="first class"
group by 1
order by count(distinct order_id) desc
limit 1;

drop table segement_demand;

select * from segment_demand;

select segment, count(distinct order_id) as total_orders
from superstore
where ship_mode="first class"
group by 1
order by 2 desc
limit 1;

-- 10

select city, sum(sales)
from superstore
group by 1
order by 2
limit 1;

-- 11

select convert(sum(date_diff)/count(date_diff),decimal(65,8)) as average_time
from (select datediff(ship_date,order_date) as date_diff
from superstore) as avg_date;

select datediff(ship_date,order_date) as date_diff
from superstore;

select convert(avg(datediff(ship_date,order_date)),decimal(65,8)) as average_time
from superstore;

-- 12

select h.state, no_of_orders, order_sales, highest_order_segment,largest_individual_segment, customer_id
from(
WITH states_table AS (select state, segment as highest_order_segment, (count(distinct order_id)) as no_of_orders
from superstore group by 1,2 order by 1)
SELECT a.*
FROM states_table a                 
left JOIN states_table b            
ON a.state=b.state and a.no_of_orders < b.no_of_orders
WHERE b.no_of_orders is NULL) as h
inner join 
(
WITH states_individual_table AS (select state, segment as largest_individual_segment,Customer_ID ,(sum(sales)) as order_sales
from superstore group by 1,2,3 order by 1)
SELECT a.*
FROM states_individual_table a                 
left JOIN states_individual_table b            
ON a.state=b.state and a.order_sales < b.order_sales
WHERE b.order_sales is NULL) as l on h.state=l.state;


select h.state, no_of_orders, order_sales, highest_order_segment,largest_individual_segment, customer_id
from
(
SELECT a.*
FROM (select state, segment as highest_order_segment, (count(distinct order_id)) as no_of_orders
from superstore group by 1,2 order by 1) a                 
left JOIN (select state, segment as highest_order_segment, (count(distinct order_id)) as no_of_orders
from superstore group by 1,2 order by 1) b            
ON a.state=b.state and a.no_of_orders < b.no_of_orders
WHERE b.no_of_orders is NULL) as h

inner join
(
SELECT a.*
FROM (select state, segment as largest_individual_segment,Customer_ID ,(sum(sales)) as order_sales
from superstore group by 1,2,3 order by 1) a                 
left JOIN (select state, segment as largest_individual_segment,Customer_ID ,(sum(sales)) as order_sales
from superstore group by 1,2,3 order by 1) b            
ON a.state=b.state and a.order_sales < b.order_sales
WHERE b.order_sales is NULL) as l on h.state=l.state;



WITH states_table AS (select state, segment as highest_order_segment, (count(distinct order_id)) as no_of_orders
from superstore group by 1,2 order by 1)
SELECT a.*
FROM states_table a                 
left JOIN states_table b            
ON a.state=b.state and a.no_of_orders < b.no_of_orders
WHERE b.no_of_orders is NULL;

select state, segment as highest_order_segment, (count(distinct order_id)) as no_of_orders
from superstore group by 1,2 order by 1;



-- 13

with repeat_orders as (select distinct order_id, customer_name, order_date from superstore)
select *,datediff(a.order_date,b.order_date)
from repeat_orders a
inner join repeat_orders b on a.customer_name=b.customer_name and datediff(a.order_date,b.order_date)=1 or datediff(a.order_date,b.order_date)=-1 and a.customer_name=b.customer_name;

create temporary table repeat_2
with repeat_orders as (select distinct order_id, customer_name, order_date from superstore)
select a.customer_name as a_customer_name,a.order_date as second_order_date,b.customer_name as b_customer_name,b.order_date as first_order_date,datediff(a.order_date,b.order_date)
from repeat_orders a
inner join repeat_orders b on a.customer_name=b.customer_name and datediff(a.order_date,b.order_date)=1 and a.customer_name=b.customer_name;

select * from repeat_2;
with repeat_orders as (select distinct order_id, customer_name, order_date from superstore)
select c.customer_name as c_customer_name,c.order_date as third_order_date,r.*,datediff(c.order_date,second_order_date)
from repeat_orders c
inner join repeat_2 r on c.customer_name=r.a_customer_name and datediff(c.order_date,second_order_date)=1 and c.customer_name=r.a_customer_name;

select * from repeat_2;

with repeat_orders as (select distinct order_id, customer_name, order_date from superstore)
select c.customer_name as c_customer_name,c.order_date as third_order_date,r.*,datediff(c.order_date,second_order_date)
from repeat_orders c
inner join 
(
with repeat_orders as (select distinct order_id, customer_name, order_date from superstore)
select a.customer_name as a_customer_name,a.order_date as second_order_date,b.customer_name as b_customer_name,b.order_date as first_order_date,datediff(a.order_date,b.order_date)
from repeat_orders a
inner join repeat_orders b on a.customer_name=b.customer_name and datediff(a.order_date,b.order_date)=1 and a.customer_name=b.customer_name) as r 
on c.customer_name=r.a_customer_name and datediff(c.order_date,second_order_date)=1 and c.customer_name=r.a_customer_name;


-- 14

select distinct product_name, product_id from superstore where Product_Name="staples" ;

select count(distinct Product_id) from superstore;

select count(distinct product_name) from superstore;


select count(distinct customer_name), count(distinct customer_id) from superstore;

select * from superstore;