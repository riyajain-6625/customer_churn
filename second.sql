-- 1. How many customers signed up each month? Which acquisition channel brought the most customers?
SELECT
    MONTH(signup_date) AS month, COUNT(*) AS "customer sign up"
FROM accounts
GROUP BY MONTH(signup_date)
ORDER BY MONTH(signup_date) ;

select  acquisition_channel,count(acquisition_channel) as "most brought channel"  from accounts
group by acquisition_channel;
-- 2. How many active customers did we have at the end of each month?
SELECT
    MONTH(dated) AS month,
    COUNT(DISTINCT account_id) AS "active customers"
FROM monthly_account_metrics
WHERE active_at_end = 1
GROUP BY MONTH(dated)
ORDER BY MONTH(month);

-- 3. How many customers churned each month? Include opening customers and new customers for context.
SELECT
a.customer_name
FROM monthly_account_metrics mac
JOIN accounts a
    ON a.account_id = mac.account_id
WHERE churned=1 and (  
mac.active_at_start=1 or
mac.new_customer=1);
-- 4. What was the monthly churn rate? Which month had the highest rate?
select month(dated) as month ,month(dated) *100/(select count(*) from  monthly_account_metrics) as"churned rate "from monthly_account_metrics 
where churned=1
order by month(dated);

-- 5. Which subscription plan had the highest churn rate?

select  distinct plan_name ,sum(month(dated) *100/(select count(*) from  monthly_account_metrics)) as "churn rate" from plans  p
join 
monthly_account_metrics mac
 on  p.plan_id= mac.plan_id
 group by plan_name;

-- 6. Which acquisition channel had the highest churn rate? Compare rates as well as counts.

SELECT
    p.plan_name,
    a.acquisition_channel,
    SUM(mac.churned) * 100.0 / COUNT(*) AS churn_rate
FROM monthly_account_metrics mac
JOIN accounts a
    ON a.account_id = mac.account_id
JOIN plans p
    ON p.plan_id = mac.plan_id
WHERE mac.active_at_start = 1
   OR mac.new_customer = 1
GROUP BY p.plan_name, a.acquisition_channel;

