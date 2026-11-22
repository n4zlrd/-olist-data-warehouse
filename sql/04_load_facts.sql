-- 04_load_facts.sql
-- Fills the 2 fact tables. We keep only DELIVERED orders that have a delivery date.

INSERT INTO dw.fact_sales
  (order_id, order_item_id, purchase_date_key, customer_key, product_key,
   seller_key, price, freight_value)
SELECT oi.order_id, oi.order_item_id::int,
       to_char(o.order_purchase_timestamp::timestamp,'YYYYMMDD')::int,
       c.customer_key, p.product_key, s.seller_key,
       oi.price::numeric, oi.freight_value::numeric
FROM stg.order_items oi
JOIN stg.orders o       ON o.order_id    = oi.order_id
JOIN dw.dim_customer c  ON c.customer_id = o.customer_id
JOIN dw.dim_product p   ON p.product_id  = oi.product_id
JOIN dw.dim_seller s    ON s.seller_id   = oi.seller_id
WHERE o.order_status = 'delivered'
  AND NULLIF(o.order_delivered_customer_date,'') IS NOT NULL;

INSERT INTO dw.fact_orders
  (order_id, purchase_date_key, customer_key, items_count, items_value,
   freight_total, payment_total, review_score, delivery_days, delay_days, is_late)
SELECT o.order_id,
       to_char(o.order_purchase_timestamp::timestamp,'YYYYMMDD')::int,
       c.customer_key,
       COALESCE(i.items_count,0), COALESCE(i.items_value,0),
       COALESCE(i.freight_total,0), COALESCE(pay.payment_total,0),
       r.review_score,
       o.order_delivered_customer_date::timestamp::date
         - o.order_purchase_timestamp::timestamp::date,
       o.order_delivered_customer_date::timestamp::date
         - o.order_estimated_delivery_date::timestamp::date,
       o.order_delivered_customer_date::timestamp::date
         > o.order_estimated_delivery_date::timestamp::date
FROM stg.orders o
JOIN dw.dim_customer c ON c.customer_id = o.customer_id
LEFT JOIN (SELECT order_id, COUNT(*) AS items_count,
                  SUM(price::numeric) AS items_value,
                  SUM(freight_value::numeric) AS freight_total
           FROM stg.order_items GROUP BY order_id) i ON i.order_id = o.order_id
LEFT JOIN (SELECT order_id, SUM(payment_value::numeric) AS payment_total
           FROM stg.order_payments GROUP BY order_id) pay ON pay.order_id = o.order_id
LEFT JOIN (SELECT order_id, ROUND(AVG(review_score::numeric),2) AS review_score
           FROM stg.order_reviews GROUP BY order_id) r ON r.order_id = o.order_id
WHERE o.order_status = 'delivered'
  AND NULLIF(o.order_delivered_customer_date,'') IS NOT NULL;
