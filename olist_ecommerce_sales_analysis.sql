-- ==============================================================
-- E-COMMERCE SALES ANALYSIS PROJECT
-- Dataset: Brazilian E-commerce Dataset (Olist)
-- Author: Neeraj Sharma
-- Tools: SQL (BigQuery), Tableau
-- Objective: Analyze revenue, customers, and product performance
-- ===============================================================

-- ===============================================================
-- 1. Data Cleaning & Validation
-- ===============================================================

-- Validate data for missing values and inconsistencies
SELECT
COUNT(*) AS missing_prices
FROM ecommerce_analysis.order_items
WHERE price IS NULL;

-- Check for invalid negative prices
SELECT COUNT(*) AS negative_prices
FROM ecommerce_analysis.order_items
WHERE price < 0;

-- Check missing product catergories
SELECT COUNT(*) AS missing_catergories
FROM ecommerce_analysis.products
WHERE product_category_name IS NULL;

-- ===============================================================
-- 2. Explore Orders Table
-- ===============================================================

-- Preview first 10 rows
SELECT * FROM ecommerce_analysis.orders
LIMIT 10;

-- Count total orders
SELECT COUNT(*) AS total_orders
FROM ecommerce_analysis.orders;

-- =============================================================
-- 3. Customer Order Analysis
-- =============================================================

-- Identify customers with the highest number of orders
SELECT
c.customer_id,
COUNT(o.order_id) AS total_orders
FROM  ecommerce_analysis.customers c
JOIN ecommerce_analysis.orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY total_orders DESC
LIMIT 10;

-- =============================================================
-- 4. Revenue Analysis
-- =============================================================

-- calculate total revenue generated from product sales
SELECT
SUM(price) AS total_revenue
FROM ecommerce_analysis.order_items;

-- =============================================================
-- 5. Product Performance Analysis
-- =============================================================

-- Identify product categories generating the highest revenue
SELECT
COALESCE(p.product_category_name, "Unknown") AS category,
sum(oi.price) AS revenue
FROM ecommerce_analysis.order_items oi
JOIN ecommerce_analysis.products p
ON oi.product_id = p.product_id
GROUP BY category
ORDER BY revenue DESC
LIMIT 10;

-- =============================================================
-- 6. Monthly Revenue Trend Analysis
-- =============================================================

-- Identify sales growth over time
SELECT
FORMAT_DATE('%y-%m', DATE(o.order_purchase_timestamp)) AS 
order_month,
SUM(oi.price) AS monthly_revenue
FROM ecommerce_analysis.orders o
JOIN ecommerce_analysis.order_items oi
ON o.order_id = oi.order_id
GROUP BY order_month
ORDER BY order_month;

-- =============================================================
-- 7. Average Order Value Analysis
-- =============================================================

-- Idenitfy the average revenue generated per order
SELECT
SUM(oi.price) / COUNT(DISTINCT o.order_id) AS avg_order_value
FROM ecommerce_analysis.orders o
JOIN ecommerce_analysis.order_items oi
ON o.order_id = oi.order_id;

-- =============================================================
-- 8. Customer Purchase Behavior Analysis
-- =============================================================

-- Identify how many orders each unique customer places
SELECT
c.customer_unique_id,
COUNT(o.order_id) AS total_orders
FROM ecommerce_analysis.orders o
JOIN ecommerce_analysis.customers c
ON o.customer_id = c.customer_id
GROUP BY customer_unique_id
ORDER BY total_orders DESC
LIMIT 10;

-- =============================================================
-- 9. Customer Retention Analysis
-- =============================================================

-- Identify how many customers purchase once vs multiple times
SELECT
CASE
    WHEN total_orders = 1 THEN 'one time customers'
    ELSE 'repeat customers'
END AS customer_type,
COUNT(*) AS number_of_customers
FROM (
    SELECT
    c.customer_unique_id,
    COUNT(o.order_id) AS total_orders
    FROM ecommerce_analysis.orders o
    JOIN ecommerce_analysis.customers c
    ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
)
GROUP BY customer_type;

-- =============================================================
-- 10. Geographic Sales Dataset (For Tableau)
-- =============================================================

-- Prepare geographic sales data by state
SELECT
c.customer_state,
COUNT(DISTINCT o.order_id) AS total_orders,
ROUND(SUM(oi.price),2) AS total_revenue
FROM ecommerce_analysis.orders o
JOIN ecommerce_analysis.customers c
ON o.customer_id = c.customer_id
JOIN ecommerce_analysis.order_items oi
ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_revenue desc;






