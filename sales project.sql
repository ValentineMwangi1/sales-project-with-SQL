-- Create a new database
CREATE DATABASE sales_project;
USE sales_project;

-- Create the table
CREATE TABLE sales_data (
    TransactionID INT PRIMARY KEY,
    Date DATE,
    CustomerID VARCHAR(10),
    Gender CHAR(1),
    Age INT,
    ProductCategory VARCHAR(50),
    Quantity INT,
    PricePerUnit DECIMAL(10,2),
    TotalAmount DECIMAL(10,2)
);

--  Insert sample data
INSERT INTO sales_data VALUES
(1, '2024-08-01', 'C001', 'M', 28, 'Electronics', 1, 500.00, 500.00),
(2, '2024-08-02', 'C002', 'F', 34, 'Clothing', 2, 40.00, 80.00),
(3, '2024-08-03', 'C003', 'M', 22, 'Beauty', 3, 15.00, 45.00),
(4, '2024-08-04', 'C004', 'F', 29, 'Electronics', 1, 1200.00, 1200.00),
(5, '2024-08-05', 'C005', 'F', 41, 'Clothing', 4, 35.00, 140.00),
(6, '2024-08-05', 'C002', 'F', 34, 'Beauty', 2, 18.00, 36.00),
(7, '2024-08-06', 'C001', 'M', 28, 'Electronics', 1, 750.00, 750.00),
(8, '2024-08-07', 'C006', 'M', 31, 'Clothing', 1, 60.00, 60.00),
(9, '2024-08-08', 'C007', 'F', 25, 'Beauty', 5, 20.00, 100.00),
(10, '2024-08-09', 'C003', 'M', 22, 'Electronics', 1, 400.00, 400.00);

--  Verify the data
SELECT * FROM sales_data;
-- how many rows? date range? categories?
SELECT 
  COUNT(*) AS  count,
  MIN(Date) AS first_date,
  MAX(Date) AS last_date
FROM sales_data;

SELECT DISTINCT ProductCategory FROM sales_data ORDER BY 1;

--  data quality check – does TotalAmount = Quantity * PricePerUnit?
SELECT *
FROM sales_data
WHERE TotalAmount <> Quantity * PricePerUnit;
-- KPIs total revenue, units sold, unique customers, orders
SELECT
  SUM(TotalAmount) AS total_revenue,
  SUM(Quantity)    AS units_sold,
  COUNT(*)         AS orders,
  COUNT(DISTINCT CustomerID) AS unique_customers
FROM sales_data;

-- Average Order Value (AOV)
SELECT ROUND(AVG(TotalAmount), 2) AS avg_order_value FROM sales_data;
-- daily trend
SELECT Date, SUM(TotalAmount) AS revenue
FROM sales_data
GROUP BY Date
ORDER BY Date;

-- monthly trend (will show 1 month with the sample)
SELECT DATE_FORMAT(Date, '%Y-%m') AS month, SUM(TotalAmount) AS revenue
FROM sales_data
GROUP BY DATE_FORMAT(Date, '%Y-%m')
ORDER BY month;
-- top 5 days by revenue
SELECT Date, SUM(TotalAmount) AS revenue
FROM sales_data
GROUP BY Date
ORDER BY revenue DESC
LIMIT 5;
-- revenue by category
SELECT ProductCategory, 
       SUM(Quantity) AS units_sold, 
       SUM(TotalAmount) AS revenue,
       ROUND(AVG(PricePerUnit),2) AS avg_price
FROM sales_data
GROUP BY ProductCategory
ORDER BY revenue DESC;

-- best category by quantity (volume)
SELECT ProductCategory, SUM(Quantity) AS units_sold
FROM sales_data
GROUP BY ProductCategory
ORDER BY units_sold DESC;

-- revenue and order count by gender
SELECT Gender,
       COUNT(*) AS orders,
       SUM(TotalAmount) AS revenue,
       ROUND(AVG(TotalAmount),2) AS avg_order_value
FROM sales_data
GROUP BY Gender;

-- most popular category by gender (ranked)
WITH cat_gender AS (
  SELECT Gender, ProductCategory, 
         SUM(Quantity) AS units_sold,
         SUM(TotalAmount) AS revenue
  FROM sales_data
  GROUP BY Gender, ProductCategory
),
ranked AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY Gender ORDER BY revenue DESC) AS rnk
  FROM cat_gender
)
SELECT Gender, ProductCategory, units_sold, revenue
FROM ranked
WHERE rnk = 1;

-- define age groups and summarize performance
SELECT 
  CASE 
    WHEN Age < 20 THEN '<20'
    WHEN Age BETWEEN 20 AND 29 THEN '20-29'
    WHEN Age BETWEEN 30 AND 39 THEN '30-39'
    WHEN Age BETWEEN 40 AND 49 THEN '40-49'
    ELSE '50+'
  END AS age_group,
  COUNT(*) AS orders,
  SUM(TotalAmount) AS revenue,
  ROUND(AVG(TotalAmount),2) AS avg_order_value
FROM sales_data
GROUP BY age_group
ORDER BY revenue DESC;

-- top 5 customers by total spend
SELECT CustomerID,
       COUNT(*) AS orders,
       SUM(TotalAmount) AS total_spend,
       ROUND(AVG(TotalAmount),2) AS avg_order_value
FROM sales_data
GROUP BY CustomerID
ORDER BY total_spend DESC
LIMIT 5;

-- repeat vs one-time customers
WITH cust_orders AS (
  SELECT CustomerID, COUNT(*) AS orders
  FROM sales_data
  GROUP BY CustomerID
)
SELECT 
  SUM(CASE WHEN orders = 1 THEN 1 ELSE 0 END) AS one_time_customers,
  SUM(CASE WHEN orders > 1 THEN 1 ELSE 0 END) AS repeat_customers
FROM cust_orders;

-- customers whose average order value is above overall AOV
WITH cust AS (
  SELECT CustomerID, AVG(TotalAmount) AS cust_aov
  FROM sales_data
  GROUP BY CustomerID
)
SELECT c.CustomerID, ROUND(c.cust_aov,2) AS cust_aov
FROM cust c
WHERE c.cust_aov > (SELECT AVG(TotalAmount) FROM sales_data)
ORDER BY cust_aov DESC;
-- top 3 customers by category
WITH spend AS (
  SELECT ProductCategory, CustomerID, SUM(TotalAmount) AS spend_cat
  FROM sales_data
  GROUP BY ProductCategory, CustomerID
),
ranked AS (
  SELECT *,
         DENSE_RANK() OVER (PARTITION BY ProductCategory ORDER BY spend_cat DESC) AS rnk
  FROM spend
)
SELECT ProductCategory, CustomerID, spend_cat
FROM ranked
WHERE rnk <= 3
ORDER BY ProductCategory, spend_cat DESC;

-- customers with no purchases since a given date
SET @cutoff := '2024-08-08';

SELECT DISTINCT CustomerID
FROM sales_data
WHERE CustomerID NOT IN (
  SELECT DISTINCT CustomerID
  FROM sales_data
  WHERE Date > @cutoff
)
ORDER BY CustomerID;

-- orders whose total is > mean + 2*stddev
WITH stats AS (
  SELECT AVG(TotalAmount) AS mean_amt,
         STDDEV_POP(TotalAmount) AS sd_amt
  FROM sales_data
)
SELECT s.*
FROM sales_data s
CROSS JOIN stats t
WHERE s.TotalAmount > t.mean_amt + 2 * t.sd_amt
ORDER BY s.TotalAmount DESC;
-- store top 3 spenders permanently
CREATE OR REPLACE VIEW v_sales_enriched AS
SELECT 
  TransactionID, Date, CustomerID, Gender, Age, ProductCategory,
  Quantity, PricePerUnit, TotalAmount,
  DATE_FORMAT(Date, '%Y-%m') AS month,
  CASE 
    WHEN Age < 20 THEN '<20'
    WHEN Age BETWEEN 20 AND 29 THEN '20-29'
    WHEN Age BETWEEN 30 AND 39 THEN '30-39'
    WHEN Age BETWEEN 40 AND 49 THEN '40-49'
    ELSE '50+' END AS age_group
FROM sales_data;

-- example 
SELECT month, ProductCategory, SUM(TotalAmount) AS revenue
FROM v_sales_enriched
GROUP BY month, ProductCategory
ORDER BY month, revenue DESC;

-- monthly trend view
CREATE VIEW monthly_sales_trends AS
SELECT 
    DATE_FORMAT(Date, '%Y-%m') AS month,
    SUM(TotalAmount) AS total_sales
FROM sales
GROUP BY month
ORDER BY month;
-- top products per month
CREATE VIEW top_products_per_month AS
SELECT 
    DATE_FORMAT(Date, '%Y-%m') AS month,
    ProductCategory,
    SUM(Quantity) AS total_units_sold
FROM sales
GROUP BY month, ProductCategory
ORDER BY month, total_units_sold DESC;

DELIMITER //
CREATE PROCEDURE GetTopProductsByMonth(IN month_param VARCHAR(7), IN top_n INT)
BEGIN
    SELECT 
        ProductCategory,
        SUM(Quantity) AS total_units_sold
    FROM sales
    WHERE DATE_FORMAT(Date, '%Y-%m') = month_param
    GROUP BY ProductCategory
    ORDER BY total_units_sold DESC
    LIMIT top_n;
END //
DELIMITER ;
