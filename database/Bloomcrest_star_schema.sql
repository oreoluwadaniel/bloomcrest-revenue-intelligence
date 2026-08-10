-- =====================================================================
-- Bloomcrest Revenue Intelligence System
-- Star schema for BI  |  Phase 7, Reporting
--
-- Run this AFTER the base tables are loaded (Phase 4).
-- It builds a date dimension table plus dimension and fact VIEWS.
-- Views stay in sync with the base tables automatically and store no
-- extra data. Power BI imports the results of these views.
--
-- This is a constellation: several fact tables (sales, deals, reorders)
-- share the same conformed dimensions (date, region, source, product...).
-- =====================================================================


-- ---------- DATE DIMENSION (a real table, generated) ----------------
DROP TABLE IF EXISTS dim_date;
CREATE TABLE dim_date AS
SELECT
    d::date                                   AS date_key,
    EXTRACT(YEAR   FROM d)::int               AS year,
    EXTRACT(QUARTER FROM d)::int              AS quarter,
    'Q' || EXTRACT(QUARTER FROM d)::int       AS quarter_name,
    EXTRACT(MONTH  FROM d)::int               AS month_num,
    TRIM(TO_CHAR(d, 'Month'))                 AS month_name,
    TO_CHAR(d, 'Mon YYYY')                    AS month_year,
    EXTRACT(DAY    FROM d)::int               AS day,
    EXTRACT(ISODOW FROM d)::int               AS day_of_week,
    TRIM(TO_CHAR(d, 'Day'))                   AS day_name,
    (EXTRACT(ISODOW FROM d) >= 6)             AS is_weekend,
    EXTRACT(WEEK   FROM d)::int               AS iso_week
FROM generate_series('2024-01-01'::date, '2026-12-31'::date, interval '1 day') AS d;
ALTER TABLE dim_date ADD PRIMARY KEY (date_key);


-- ---------- DIMENSION VIEWS -----------------------------------------
CREATE OR REPLACE VIEW dim_region AS
SELECT region_id, name AS region_name, country FROM regions;

CREATE OR REPLACE VIEW dim_source AS
SELECT source_id, name AS source_name FROM lead_sources;

CREATE OR REPLACE VIEW dim_product AS
SELECT product_id, name AS product_name, sku, category, unit_price, unit_cost FROM products;

CREATE OR REPLACE VIEW dim_customer AS
SELECT customer_id, full_name, region_id, source_id, first_order_date, acquisition_cost
FROM customers;

CREATE OR REPLACE VIEW dim_company AS
SELECT company_id, name AS company_name, type AS company_type, region_id, created_date
FROM companies;

CREATE OR REPLACE VIEW dim_rep AS
SELECT rep_id, name AS rep_name, region_id, role, hire_date FROM sales_reps;

CREATE OR REPLACE VIEW dim_stage AS
SELECT stage_id, name AS stage_name, sort_order, win_probability FROM deal_stages;

CREATE OR REPLACE VIEW dim_lost_reason AS
SELECT reason_id, reason FROM lost_reasons;


-- ---------- FACT VIEWS ----------------------------------------------

-- fact_sales  |  grain: one order line item (DTC)
CREATE OR REPLACE VIEW fact_sales AS
SELECT
    oi.order_item_id,
    oi.order_id,
    o.order_date,
    o.customer_id,
    c.region_id,
    c.source_id,
    oi.product_id,
    oi.quantity,
    oi.line_total                              AS revenue,
    (oi.quantity * p.unit_cost)                AS cost,
    (oi.line_total - oi.quantity * p.unit_cost) AS gross_profit,
    o.status                                   AS order_status
FROM order_items oi
JOIN orders    o ON oi.order_id   = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
JOIN products  p ON oi.product_id = p.product_id;

-- fact_deals  |  grain: one deal (wholesale pipeline)
CREATE OR REPLACE VIEW fact_deals AS
SELECT
    d.deal_id,
    d.company_id,
    co.region_id,
    d.rep_id,
    d.stage_id,
    d.source_id,
    d.reason_id,
    d.amount,
    s.win_probability,
    (d.amount * s.win_probability)             AS weighted_amount,
    d.created_date,
    d.expected_close,
    d.actual_close,
    d.status,
    CASE WHEN d.status = 'Won'  THEN 1 ELSE 0 END AS is_won,
    CASE WHEN d.status = 'Lost' THEN 1 ELSE 0 END AS is_lost,
    CASE WHEN d.status = 'Open' THEN 1 ELSE 0 END AS is_open,
    CASE WHEN d.actual_close IS NOT NULL
         THEN (d.actual_close - d.created_date) END AS cycle_days
FROM deals d
JOIN companies    co ON d.company_id = co.company_id
JOIN deal_stages  s  ON d.stage_id   = s.stage_id;

-- fact_wholesale_orders  |  grain: one reorder (recurring wholesale revenue)
CREATE OR REPLACE VIEW fact_wholesale_orders AS
SELECT
    w.worder_id,
    w.company_id,
    co.region_id,
    w.order_date,
    w.amount
FROM wholesale_orders w
JOIN companies co ON w.company_id = co.company_id;

-- fact_payments  |  grain: one payment (collected cash, for booked vs collected)
CREATE OR REPLACE VIEW fact_payments AS
SELECT
    pay.payment_id,
    pay.order_id,
    o.customer_id,
    pay.amount,
    pay.payment_date,
    pay.method
FROM payments pay
JOIN orders o ON pay.order_id = o.order_id;


-- ---------- QUICK CHECK ---------------------------------------------
-- SELECT 'fact_sales' t, COUNT(*) FROM fact_sales
-- UNION ALL SELECT 'fact_deals', COUNT(*) FROM fact_deals
-- UNION ALL SELECT 'fact_wholesale_orders', COUNT(*) FROM fact_wholesale_orders
-- UNION ALL SELECT 'dim_date', COUNT(*) FROM dim_date;
