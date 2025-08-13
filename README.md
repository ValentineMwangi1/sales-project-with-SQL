# # Retail Sales Analytics – SQL Project

##  Project Overview
This project analyzes retail sales data using **MySQL** to answer key business questions such as:
- Which customers and products drive the most revenue?
- What are the monthly sales trends?
- Which demographic segments are the most profitable?
- Which products are popular in each month?

The project demonstrates **SQL skills** (Joins, Group By, Views, Stored Procedures, Aggregations) and **business analytics thinking**.

---

##  Dataset Description
| Column Name       | Description |
|-------------------|-------------|
| TransactionID     | Unique identifier for each transaction |
| Date              | Date of purchase |
| CustomerID        | Unique identifier for each customer |
| Gender            | Customer gender (Male/Female) |
| Age               | Customer age |
| ProductCategory   | Category of product purchased (Electronics, Clothing, Beauty, etc.) |
| Quantity          | Number of units purchased |
| PricePerUnit      | Price per unit of the product |
| TotalAmount       | Total value of the transaction |

---

## Technologies Used
- **MySQL** – Database & queries
- **GitHub** – Project documentation 

---

##  Business Questions Answered
1. Total revenue generated
2. Sales breakdown by gender
3. Age segmentation spending patterns
4. Best-selling product categories
5. Monthly sales trends
6. Top products per month
7. Customer segment profitability
8. Top N products for a selected month *(via stored procedure)*

---

## SQL Features Demonstrated
- **CREATE DATABASE** & **CREATE TABLE**
- **INSERT INTO** for data loading
- **Aggregate functions** (`SUM`, `COUNT`, `AVG`)
- **GROUP BY** and **ORDER BY**
- **CASE WHEN** for segmentation
- **Views** for reusable queries
- **Stored Procedures** for dynamic analysis

---

## Views Created
- **`monthly_sales_trends`** – Monthly revenue trends
- **`top_products_per_month`** – Best-selling products each month
- **`customer_segment_profit`** – Spending by age & gender segments
- **`top_spenders`** – Highest spending customers

---

##  Stored Procedure
**`GetTopProductsByMonth(month_param, top_n)`**
- Returns top N products for a given month.
  
## Key Insights
Electronics consistently rank as top sellers.

Adults (25–40) are the highest-spending demographic.

Revenue peaks in December, indicating strong holiday season sales.

##Author
Valentine Njeri
 Contact: [njerivalentine6@gmail.com]
