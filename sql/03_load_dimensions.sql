-- 03_load_dimensions.sql
-- Fills the 4 dimension tables from the staging tables.

INSERT INTO dw.dim_date
  (date_key, full_date, day_of_month, month_number, month_name,
   quarter_number, year_number, day_name, is_weekend)
SELECT to_char(d,'YYYYMMDD')::int, d::date,
       EXTRACT(DAY FROM d)::int, EXTRACT(MONTH FROM d)::int, to_char(d,'FMMonth'),
       EXTRACT(QUARTER FROM d)::int, EXTRACT(YEAR FROM d)::int,
       to_char(d,'FMDay'), EXTRACT(ISODOW FROM d) IN (6,7)
FROM generate_series('2016-01-01'::timestamp, '2019-12-31'::timestamp,
                     interval '1 day') AS d;

INSERT INTO dw.dim_customer (customer_id, customer_unique_id, city, state)
SELECT customer_id, customer_unique_id,
       INITCAP(customer_city), UPPER(customer_state)
FROM stg.customers;

INSERT INTO dw.dim_product
  (product_id, category_pt, category_en, weight_g, length_cm, height_cm,
   width_cm, photos_qty)
SELECT p.product_id,
       COALESCE(NULLIF(p.product_category_name,''), 'unknown'),
       COALESCE(t.product_category_name_english,
                NULLIF(p.product_category_name,''), 'unknown'),
       NULLIF(p.product_weight_g,'')::numeric,
       NULLIF(p.product_length_cm,'')::numeric,
       NULLIF(p.product_height_cm,'')::numeric,
       NULLIF(p.product_width_cm,'')::numeric,
       NULLIF(p.product_photos_qty,'')::numeric::int
FROM stg.products p
LEFT JOIN stg.category_translation t
       ON t.product_category_name = p.product_category_name;

INSERT INTO dw.dim_seller (seller_id, city, state)
SELECT seller_id, INITCAP(seller_city), UPPER(seller_state)
FROM stg.sellers;
