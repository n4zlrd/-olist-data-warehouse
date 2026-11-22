-- 06_analysis_queries.sql : the 6 business questions

-- Q1 Revenue per month
SELECT d.year_number, d.month_number, ROUND(SUM(f.price),2) AS revenue
FROM dw.fact_sales f JOIN dw.dim_date d ON d.date_key = f.purchase_date_key
GROUP BY d.year_number, d.month_number
ORDER BY 1, 2;

-- Q2 Top 10 product categories by revenue
SELECT p.category_en, ROUND(SUM(f.price),2) AS revenue, COUNT(*) AS items_sold
FROM dw.fact_sales f JOIN dw.dim_product p ON p.product_key = f.product_key
GROUP BY p.category_en
ORDER BY revenue DESC LIMIT 10;

-- Q3 Revenue per customer state
SELECT c.state, ROUND(SUM(f.price),2) AS revenue
FROM dw.fact_sales f JOIN dw.dim_customer c ON c.customer_key = f.customer_key
GROUP BY c.state
ORDER BY revenue DESC;

-- Q4 Delivery speed and lateness per customer state
SELECT c.state, ROUND(AVG(o.delivery_days),1) AS avg_days,
       ROUND(100.0*AVG(CASE WHEN o.is_late THEN 1 ELSE 0 END),1) AS pct_late
FROM dw.fact_orders o JOIN dw.dim_customer c ON c.customer_key = o.customer_key
GROUP BY c.state
ORDER BY pct_late DESC;

-- Q5 Do late deliveries get worse reviews?
SELECT o.is_late, COUNT(*) AS orders, ROUND(AVG(o.review_score),2) AS avg_review
FROM dw.fact_orders o
WHERE o.review_score IS NOT NULL
GROUP BY o.is_late;

-- Q6 Top 10 sellers by revenue
SELECT s.seller_id, s.state, ROUND(SUM(f.price),2) AS revenue
FROM dw.fact_sales f JOIN dw.dim_seller s ON s.seller_key = f.seller_key
GROUP BY s.seller_id, s.state
ORDER BY revenue DESC LIMIT 10;
