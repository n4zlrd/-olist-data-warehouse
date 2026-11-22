-- 05_checks.sql  (run it, compare with the PDF)

-- A) row counts of the landing tables
--    expect roughly: 99441 / 99441 / 112650 / 32951 / 3095
SELECT 'customers' AS t, COUNT(*) FROM stg.customers UNION ALL
SELECT 'orders', COUNT(*) FROM stg.orders UNION ALL
SELECT 'order_items', COUNT(*) FROM stg.order_items UNION ALL
SELECT 'products', COUNT(*) FROM stg.products UNION ALL
SELECT 'sellers', COUNT(*) FROM stg.sellers;

-- B) row counts of the warehouse
SELECT 'dim_date' AS t, COUNT(*) FROM dw.dim_date UNION ALL
SELECT 'dim_customer', COUNT(*) FROM dw.dim_customer UNION ALL
SELECT 'dim_product', COUNT(*) FROM dw.dim_product UNION ALL
SELECT 'dim_seller', COUNT(*) FROM dw.dim_seller UNION ALL
SELECT 'fact_sales', COUNT(*) FROM dw.fact_sales UNION ALL
SELECT 'fact_orders', COUNT(*) FROM dw.fact_orders;

-- C) money must match between landing and warehouse (the 2 numbers must be EQUAL)
SELECT
 (SELECT SUM(oi.price::numeric) FROM stg.order_items oi
    JOIN stg.orders o ON o.order_id = oi.order_id
   WHERE o.order_status = 'delivered'
     AND NULLIF(o.order_delivered_customer_date,'') IS NOT NULL) AS staging_revenue,
 (SELECT SUM(price) FROM dw.fact_sales) AS warehouse_revenue;
