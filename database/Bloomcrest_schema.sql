-- =====================================================================
-- Bloomcrest Revenue Intelligence System
-- PostgreSQL schema (DDL)  |  Phase 4, Database Design
-- Prepared by: Daniel Olatunji
--
-- Run order:
--   1. Create the tables (this whole file, top section).
--   2. Load the CSV data (see the LOAD section, commented, at the bottom).
--   3. Create the indexes (INDEX section) AFTER the data is loaded.
-- Tables are defined parents-first so every foreign key has something
-- to point to.
-- =====================================================================


-- ---------- SHARED REFERENCE (DIMENSION) TABLES ----------------------

CREATE TABLE regions (
    region_id   VARCHAR(15) PRIMARY KEY,
    name        TEXT NOT NULL,
    country     TEXT NOT NULL
);

CREATE TABLE lead_sources (
    source_id   VARCHAR(15) PRIMARY KEY,
    name        TEXT NOT NULL
);

CREATE TABLE products (
    product_id  VARCHAR(15) PRIMARY KEY,
    name        TEXT NOT NULL,
    sku         TEXT NOT NULL,
    category    TEXT NOT NULL,
    unit_price  NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
    unit_cost   NUMERIC(12,2) NOT NULL CHECK (unit_cost  >= 0)
);

CREATE TABLE sales_reps (
    rep_id      VARCHAR(15) PRIMARY KEY,
    name        TEXT NOT NULL,
    region_id   VARCHAR(15) REFERENCES regions(region_id),
    role        TEXT,
    hire_date   DATE
);

CREATE TABLE deal_stages (
    stage_id        VARCHAR(15) PRIMARY KEY,
    name            TEXT NOT NULL,
    sort_order      INT  NOT NULL,
    win_probability NUMERIC(3,2) NOT NULL CHECK (win_probability BETWEEN 0 AND 1)
);

CREATE TABLE lost_reasons (
    reason_id   VARCHAR(15) PRIMARY KEY,
    reason      TEXT NOT NULL
);


-- ---------- WHOLESALE ENGINE ----------------------------------------

CREATE TABLE companies (
    company_id   VARCHAR(15) PRIMARY KEY,
    name         TEXT NOT NULL,
    type         TEXT NOT NULL,
    region_id    VARCHAR(15) NOT NULL REFERENCES regions(region_id),
    created_date DATE NOT NULL
);

CREATE TABLE contacts (
    contact_id  VARCHAR(15) PRIMARY KEY,
    company_id  VARCHAR(15) NOT NULL REFERENCES companies(company_id),
    full_name   TEXT NOT NULL,
    email       TEXT,
    role        TEXT
);

CREATE TABLE deals (
    deal_id        VARCHAR(15) PRIMARY KEY,
    company_id     VARCHAR(15) NOT NULL REFERENCES companies(company_id),
    contact_id     VARCHAR(15) REFERENCES contacts(contact_id),
    rep_id         VARCHAR(15) REFERENCES sales_reps(rep_id),
    stage_id       VARCHAR(15) NOT NULL REFERENCES deal_stages(stage_id),
    source_id      VARCHAR(15) REFERENCES lead_sources(source_id),
    reason_id      VARCHAR(15) REFERENCES lost_reasons(reason_id),   -- only set when Lost
    amount         NUMERIC(14,2) NOT NULL CHECK (amount >= 0),
    created_date   DATE NOT NULL,
    expected_close DATE,
    actual_close   DATE,
    status         VARCHAR(10) NOT NULL CHECK (status IN ('Open','Won','Lost'))
);

CREATE TABLE activities (
    activity_id   VARCHAR(15) PRIMARY KEY,
    deal_id       VARCHAR(15) NOT NULL REFERENCES deals(deal_id),
    rep_id        VARCHAR(15) REFERENCES sales_reps(rep_id),
    type          VARCHAR(20) NOT NULL,
    activity_date DATE NOT NULL
);

CREATE TABLE wholesale_orders (
    worder_id   VARCHAR(15) PRIMARY KEY,
    company_id  VARCHAR(15) NOT NULL REFERENCES companies(company_id),
    order_date  DATE NOT NULL,
    amount      NUMERIC(14,2) NOT NULL CHECK (amount >= 0)
);


-- ---------- DTC ENGINE ----------------------------------------------

CREATE TABLE customers (
    customer_id      VARCHAR(15) PRIMARY KEY,
    full_name        TEXT NOT NULL,
    email            TEXT,
    region_id        VARCHAR(15) REFERENCES regions(region_id),
    source_id        VARCHAR(15) REFERENCES lead_sources(source_id),
    first_order_date DATE NOT NULL,
    acquisition_cost NUMERIC(12,2)
);

CREATE TABLE orders (
    order_id     VARCHAR(15) PRIMARY KEY,
    customer_id  VARCHAR(15) NOT NULL REFERENCES customers(customer_id),
    order_date   DATE NOT NULL,
    total_amount NUMERIC(14,2) NOT NULL CHECK (total_amount >= 0),
    status       VARCHAR(15) NOT NULL
);

CREATE TABLE order_items (
    order_item_id VARCHAR(15) PRIMARY KEY,
    order_id      VARCHAR(15) NOT NULL REFERENCES orders(order_id),
    product_id    VARCHAR(15) NOT NULL REFERENCES products(product_id),
    quantity      INT NOT NULL CHECK (quantity > 0),
    unit_price    NUMERIC(12,2) NOT NULL,
    line_total    NUMERIC(14,2) NOT NULL
);

CREATE TABLE payments (
    payment_id   VARCHAR(15) PRIMARY KEY,
    order_id     VARCHAR(15) NOT NULL REFERENCES orders(order_id),
    amount       NUMERIC(14,2) NOT NULL,
    payment_date DATE NOT NULL,
    method       VARCHAR(30) NOT NULL
);


-- =====================================================================
-- LOAD  (run these AFTER the tables exist, parents first)
-- In pgAdmin: use the psql tool or the Query Tool with \copy.
-- Replace the path with the folder where you unzipped the CSVs.
-- NULL '' turns empty cells (like a blank actual_close) into real NULLs.
-- =====================================================================
-- \copy regions          FROM '/path/to/bloomcrest_data/regions.csv'          WITH (FORMAT csv, HEADER true, NULL '');
-- \copy lead_sources     FROM '/path/to/bloomcrest_data/lead_sources.csv'     WITH (FORMAT csv, HEADER true, NULL '');
-- \copy products         FROM '/path/to/bloomcrest_data/products.csv'         WITH (FORMAT csv, HEADER true, NULL '');
-- \copy sales_reps       FROM '/path/to/bloomcrest_data/sales_reps.csv'       WITH (FORMAT csv, HEADER true, NULL '');
-- \copy deal_stages      FROM '/path/to/bloomcrest_data/deal_stages.csv'      WITH (FORMAT csv, HEADER true, NULL '');
-- \copy lost_reasons     FROM '/path/to/bloomcrest_data/lost_reasons.csv'     WITH (FORMAT csv, HEADER true, NULL '');
-- \copy companies        FROM '/path/to/bloomcrest_data/companies.csv'        WITH (FORMAT csv, HEADER true, NULL '');
-- \copy contacts         FROM '/path/to/bloomcrest_data/contacts.csv'         WITH (FORMAT csv, HEADER true, NULL '');
-- \copy deals            FROM '/path/to/bloomcrest_data/deals.csv'            WITH (FORMAT csv, HEADER true, NULL '');
-- \copy activities       FROM '/path/to/bloomcrest_data/activities.csv'       WITH (FORMAT csv, HEADER true, NULL '');
-- \copy wholesale_orders FROM '/path/to/bloomcrest_data/wholesale_orders.csv' WITH (FORMAT csv, HEADER true, NULL '');
-- \copy customers        FROM '/path/to/bloomcrest_data/customers.csv'        WITH (FORMAT csv, HEADER true, NULL '');
-- \copy orders           FROM '/path/to/bloomcrest_data/orders.csv'           WITH (FORMAT csv, HEADER true, NULL '');
-- \copy order_items      FROM '/path/to/bloomcrest_data/order_items.csv'      WITH (FORMAT csv, HEADER true, NULL '');
-- \copy payments         FROM '/path/to/bloomcrest_data/payments.csv'         WITH (FORMAT csv, HEADER true, NULL '');


-- =====================================================================
-- INDEXES  (run AFTER the data is loaded, not before)
-- Indexes speed up the joins and filters your dashboards will run most.
-- Building them after the bulk load is faster than before.
-- =====================================================================
CREATE INDEX idx_deals_company   ON deals(company_id);
CREATE INDEX idx_deals_rep       ON deals(rep_id);
CREATE INDEX idx_deals_stage     ON deals(stage_id);
CREATE INDEX idx_deals_status    ON deals(status);
CREATE INDEX idx_activities_deal ON activities(deal_id);
CREATE INDEX idx_worders_company ON wholesale_orders(company_id);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date     ON orders(order_date);
CREATE INDEX idx_items_order     ON order_items(order_id);
CREATE INDEX idx_items_product   ON order_items(product_id);
CREATE INDEX idx_payments_order  ON payments(order_id);
CREATE INDEX idx_customers_region ON customers(region_id);
CREATE INDEX idx_customers_first  ON customers(first_order_date);
