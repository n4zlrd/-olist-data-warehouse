-- 02_dw_tables.sql
-- The warehouse itself: 4 dimension tables + 2 fact tables (a "star" shape).

CREATE TABLE dw.dim_date (
  date_key INT PRIMARY KEY,          -- looks like 20170930
  full_date DATE NOT NULL,
  day_of_month INT, month_number INT, month_name TEXT,
  quarter_number INT, year_number INT,
  day_name TEXT, is_weekend BOOLEAN);

CREATE TABLE dw.dim_customer (
  customer_key SERIAL PRIMARY KEY,
  customer_id TEXT UNIQUE NOT NULL,
  customer_unique_id TEXT,
  city TEXT, state TEXT);

CREATE TABLE dw.dim_product (
  product_key SERIAL PRIMARY KEY,
  product_id TEXT UNIQUE NOT NULL,
  category_pt TEXT, category_en TEXT,
  weight_g NUMERIC, length_cm NUMERIC, height_cm NUMERIC, width_cm NUMERIC,
  photos_qty INT);

CREATE TABLE dw.dim_seller (
  seller_key SERIAL PRIMARY KEY,
  seller_id TEXT UNIQUE NOT NULL,
  city TEXT, state TEXT);

-- Fact 1: one row = one item inside one order
CREATE TABLE dw.fact_sales (
  order_id TEXT NOT NULL,
  order_item_id INT NOT NULL,
  purchase_date_key INT NOT NULL REFERENCES dw.dim_date(date_key),
  customer_key INT NOT NULL REFERENCES dw.dim_customer(customer_key),
  product_key INT NOT NULL REFERENCES dw.dim_product(product_key),
  seller_key INT NOT NULL REFERENCES dw.dim_seller(seller_key),
  price NUMERIC(12,2),
  freight_value NUMERIC(12,2),
  PRIMARY KEY (order_id, order_item_id));

-- Fact 2: one row = one order
CREATE TABLE dw.fact_orders (
  order_id TEXT PRIMARY KEY,
  purchase_date_key INT NOT NULL REFERENCES dw.dim_date(date_key),
  customer_key INT NOT NULL REFERENCES dw.dim_customer(customer_key),
  items_count INT,
  items_value NUMERIC(12,2),
  freight_total NUMERIC(12,2),
  payment_total NUMERIC(12,2),
  review_score NUMERIC(3,2),
  delivery_days INT,       -- purchase day -> delivered day
  delay_days INT,          -- delivered minus promised (positive = late)
  is_late BOOLEAN);
