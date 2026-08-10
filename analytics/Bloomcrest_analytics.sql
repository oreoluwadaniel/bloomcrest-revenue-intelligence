-- Bloomcrest Revenue Intelligence | PostgreSQL Analytics
-- Analysis as-of date: 2026-07-20
-- All revenue definitions are documented below.

-- ================================================================
-- 1. CAC BY ACQUISITION CHANNEL
-- ================================================================
SELECT
    ls.name AS channel,
    COUNT(*) AS customers,
    ROUND(AVG(c.acquisition_cost)) AS avg_cac
FROM customers c
JOIN lead_sources ls ON c.source_id = ls.source_id
GROUP BY ls.name
ORDER BY customers DESC;


-- ================================================================
-- 2. LTV / CAC BY CHANNEL
-- LTV here means successful-order revenue per customer.
-- This is a descriptive customer-economics ratio, not contribution-margin LTV.
-- ================================================================
WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE status IN ('Delivered','Shipped','Processing')
    GROUP BY customer_id
)
SELECT
    ls.name AS channel,
    COUNT(*) AS customers,
    ROUND(AVG(COALESCE(cr.revenue,0))) AS avg_revenue,
    ROUND(AVG(c.acquisition_cost)) AS avg_cac,
    ROUND(
        AVG(COALESCE(cr.revenue,0))
        / NULLIF(AVG(c.acquisition_cost),0),
        1
    ) AS revenue_cac_ratio
FROM customers c
JOIN lead_sources ls ON c.source_id = ls.source_id
LEFT JOIN customer_revenue cr ON cr.customer_id = c.customer_id
GROUP BY ls.name
ORDER BY revenue_cac_ratio DESC;


-- ================================================================
-- 3. 90-DAY CUSTOMER INACTIVITY
-- Includes all customers so customers with no successful order
-- are not silently excluded from the denominator.
-- ================================================================
WITH last_order AS (
    SELECT
        customer_id,
        MAX(order_date) AS last_order_date
    FROM orders
    WHERE status IN ('Delivered','Shipped','Processing')
    GROUP BY customer_id
)
SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (
        WHERE last_order_date IS NULL
           OR last_order_date < DATE '2026-07-20' - INTERVAL '90 days'
    ) AS inactive_90d,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE last_order_date IS NULL
               OR last_order_date < DATE '2026-07-20' - INTERVAL '90 days'
        ) / COUNT(*),
        1
    ) AS inactive_pct
FROM customers c
LEFT JOIN last_order lo ON lo.customer_id = c.customer_id;


-- ================================================================
-- 4. MONTHLY COHORT RETENTION
-- Month 1 means the first month after the customer's first-order month.
-- ================================================================
WITH cohort AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', first_order_date) AS cohort_month
    FROM customers
),
cohort_size AS (
    SELECT cohort_month, COUNT(*) AS cohort_size
    FROM cohort
    GROUP BY cohort_month
),
order_months AS (
    SELECT DISTINCT
        customer_id,
        DATE_TRUNC('month', order_date) AS order_month
    FROM orders
    WHERE status IN ('Delivered','Shipped','Processing')
),
activity AS (
    SELECT
        c.cohort_month,
        (
            (EXTRACT(YEAR FROM om.order_month) - EXTRACT(YEAR FROM c.cohort_month)) * 12
            + EXTRACT(MONTH FROM om.order_month) - EXTRACT(MONTH FROM c.cohort_month)
        )::int AS month_index,
        om.customer_id
    FROM cohort c
    JOIN order_months om ON om.customer_id = c.customer_id
)
SELECT
    cs.cohort_month,
    cs.cohort_size,
    ROUND(
        100.0 * COUNT(DISTINCT a.customer_id)
        FILTER (WHERE a.month_index = 1) / cs.cohort_size,
        1
    ) AS m1_pct,
    ROUND(
        100.0 * COUNT(DISTINCT a.customer_id)
        FILTER (WHERE a.month_index = 3) / cs.cohort_size,
        1
    ) AS m3_pct,
    ROUND(
        100.0 * COUNT(DISTINCT a.customer_id)
        FILTER (WHERE a.month_index = 6) / cs.cohort_size,
        1
    ) AS m6_pct
FROM cohort_size cs
LEFT JOIN activity a ON a.cohort_month = cs.cohort_month
GROUP BY cs.cohort_month, cs.cohort_size
ORDER BY cs.cohort_month
LIMIT 8;


-- ================================================================
-- 5. WHOLESALE WIN RATE AND SALES CYCLE
-- PostgreSQL date subtraction returns an integer number of days.
-- ================================================================
SELECT
    COUNT(*) FILTER (WHERE status='Won') AS won,
    COUNT(*) FILTER (WHERE status='Lost') AS lost,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE status='Won')
        / NULLIF(COUNT(*) FILTER (WHERE status IN ('Won','Lost')),0),
        1
    ) AS win_rate_pct,
    ROUND(
        AVG(actual_close - created_date)
        FILTER (WHERE status='Won')
    ) AS avg_cycle_days
FROM deals;


-- ================================================================
-- 6. OPEN PIPELINE AND WEIGHTED FORECAST
-- ================================================================
SELECT
    ds.name AS stage,
    COUNT(*) AS deals,
    SUM(d.amount) AS pipeline_value,
    ROUND(SUM(d.amount * ds.win_probability)) AS weighted_value
FROM deals d
JOIN deal_stages ds ON d.stage_id = ds.stage_id
WHERE d.status='Open'
GROUP BY ds.name, ds.sort_order
ORDER BY ds.sort_order;


-- ================================================================
-- 7. CLOSED-LOST REASONS
-- ================================================================
SELECT
    lr.reason,
    COUNT(*) AS deals,
    ROUND(SUM(d.amount)) AS value_lost
FROM deals d
JOIN lost_reasons lr ON d.reason_id = lr.reason_id
WHERE d.status='Lost'
GROUP BY lr.reason
ORDER BY deals DESC;
