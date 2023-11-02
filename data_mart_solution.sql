use datamart;

select * from weekly_sales;

# Data Cleansing

create table clean_weekly_sales as
select week_date,
week(week_date) as week_number,
month(week_date) as month_number,
year(week_date) as calender_year,
region,platform,
case
    when segment=null then "Unknown"
    else segment
    end as segment,
case
    when right(segment,1)="1" then "Young Adults"
    when right(segment,1)="2" then "Middle Aged"
    when right(segment,1) in ("3","4") then "Retirees"
    else "Unknown"
    end as age_band,
case
    when left(segment,1)="C" then "Couples"
    when left(segment,1)="F" then "Families"
    else "Unknown"
    end as demographic,
customer_type,transactions,sales,
round(sales/transactions,2) as "avg_transactions"
from weekly_sales;

select * from clean_weekly_sales limit 10;


# Data Exploration
# 1. Which week numbers are missing from the dataset?
create table seq100
(x int not null auto_increment primary key);
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 select x + 50 from seq100;

select * from seq100;
create table seq52 as (select x from seq100 limit 52);
select * from seq52;

select distinct x as week_day from seq52 
where x not in(select distinct week_number from clean_weekly_sales); 

select distinct week_number from clean_weekly_sales;


# 2. How many total transactions were there for each year in the dataset?
select calender_year,sum(transactions) as Total_transaction
from clean_weekly_sales group by calender_year;


# 3. What are the total sales for each region for each month?
select region, month_number, sum(sales) total_sales
from clean_weekly_sales
group by month_number, region
order by month_number;

# 4. What is the total count of transactions for each platform
select platform, sum(transactions) as total_transactions
from clean_weekly_sales
group by platform;

# 5. What is the percentage of sales for Retail vs Shopify for each month?
with cte_monthly_platform_sales as
 (select month_number, calender_year, platform,
 sum(sales) as monthly_sales
 from clean_weekly_sales
 group by month_number, calender_year, platform)
 
 select calender_year, month_number,
 round(100*max(case when platform = "Retail"
 then monthly_sales else null end)/sum(monthly_sales),2)
 as retail_percentage,
 round(100*max(case when platform = "Shopify"
 then monthly_sales else null end)/sum(monthly_sales),2)
 as shopify_percentage
 from cte_monthly_platform_sales
 group by month_number,calender_year
 order by calender_year,month_number;
 
 # Or 
 
 SELECT
    month_number,
    SUM(CASE WHEN platform = 'Retail' THEN sales ELSE 0 END) AS retail_sales,
    SUM(CASE WHEN platform = 'Shopify' THEN sales ELSE 0 END) AS shopify_sales,
    (SUM(CASE WHEN platform = 'Retail' THEN sales ELSE 0 END) / SUM(sales)) * 100 AS retail_percentage,
    (SUM(CASE WHEN platform = 'Shopify' THEN sales ELSE 0 END) / SUM(sales)) * 100 AS shopify_percentage
FROM clean_weekly_sales
GROUP BY month_number
ORDER BY month_number;
 
 

# 6. What is the percentage of sales by demographic for each year in the dataset?
SELECT calender_year, demographic, SUM(sales) AS total_sales,
   (SUM(sales) / (
        SELECT SUM(sales) 
        FROM clean_weekly_sales 
        WHERE calender_year = t.calender_year
    )) * 100 AS sales_percentage
FROM clean_weekly_sales t
GROUP BY calender_year, demographic
ORDER BY calender_year, demographic;

# 7. Which age_band and demographic values contribute the most to Retail sales?
SELECT
    age_band,
    demographic,
    SUM(CASE WHEN platform = 'Retail' THEN sales ELSE 0 END) AS retail_sales
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
ORDER BY retail_sales DESC;



