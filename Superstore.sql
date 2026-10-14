select * from customer limit(20)


---Q1.Total sales and profit by region

select region,
  SUM(sales) as total_sales,
  SUM(profit) as total_profit
  
From customer
GROUP BY region
ORDER BY total_sales DESC;


---Q2.Top 5 products by total sales

select product_name,
  SUM(sales) as total_sales
from customer
group by product_name
order by total_sales desc
limit(5);

--Q3.Second highest sale
select MAX(sales) as second_highest
 from customer
 where sales<(select MAX(sales) from customer)

---Q4.Duplicate records
select order_id, product_name, COUNT(*) as duplicate_count
from customer
group by order_id, product_name
having count(*)>1

---Q5.Customers who never placed an order
SELECT COLUMN_NAME
FROM information_schema.columns
WHERE table_schema ='public'
AND table_name='customer'

SELECT c.customer_id,c.customer_name
FROM customer AS c
LEFT JOIN customer AS o
ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

---	Q6.Month-wise sales trend for a year
SELECT
 EXTRACT (MONTH FROM order_date) AS month_no,
       SUM(sales)AS total_sales
FROM customer
WHERE EXTRACT(YEAR FROM order_date) = 2016
GROUP BY EXTRACT (MONTH FROM order_date)
ORDER BY month_no;

---Q7.Top 3 products in each category
WITH ranked AS (
    SELECT category,
           product_name,
           SUM(sales) AS total_sales,
           ROW_NUMBER() OVER (
               PARTITION BY category
               ORDER BY SUM(sales) DESC
           ) AS rn
    FROM customer
    GROUP BY category, product_name
)
SELECT category, product_name, total_sales
FROM ranked
WHERE rn <= 3;

---Q8.Running total of sales by month
WITH monthly AS (
    SELECT TO_CHAR(order_date, 'YYYY-MM') AS ym,
           SUM(sales) AS monthly_sales
    FROM CUSTOMER
    GROUP BY TO_CHAR(order_date, 'YYYY-MM')
)
SELECT ym,
       monthly_sales,
       SUM(monthly_sales) OVER (ORDER BY ym) AS running_total
FROM monthly;

---Q9.Month-over-month growth
WITH monthly AS (
    SELECT
        TO_CHAR(order_date, 'YYYY-MM') AS ym,
        SUM(sales) AS monthly_sales
    FROM customer
    GROUP BY TO_CHAR(order_date, 'YYYY-MM')
)
SELECT
    ym,
    monthly_sales,
    LAG(monthly_sales) OVER (ORDER BY ym) AS prev_month,
    ROUND(
        (
            (monthly_sales - LAG(monthly_sales) OVER (ORDER BY ym))
            / NULLIF(LAG(monthly_sales) OVER (ORDER BY ym), 0) * 100
        )::NUMERIC,
        2
    ) AS growth_pct
FROM monthly
ORDER BY ym;

---10.Customers with sales above the average
WITH cust AS (
    SELECT customer_id,
           customer_name,
           SUM(sales) AS total_sales
    FROM CUSTOMER
    GROUP BY customer_id, customer_name
)
SELECT *
FROM cust
WHERE total_sales > (SELECT AVG(total_sales) FROM cust)
ORDER BY total_sales DESC;