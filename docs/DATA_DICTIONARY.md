# Bloomcrest Revenue Intelligence - Data Dictionary

## Revenue Intelligence and Sales Pipeline Management System

This document describes every table and column in the Bloomcrest dataset, what each field holds, and why it exists. The data covers a 24-month window and totals approximately NGN 7.353B in modeled revenue across the analysis period, split approximately 43.6% DTC and 56.4% wholesale. All foreign keys reference valid primary keys, and the tables follow the approved entity relationship diagram.

Key: PK = primary key (unique row identifier). FK = foreign key (points to a primary key in another table).

---

## Shared reference tables

### regions (8 rows)
Where Bloomcrest sells. Exists so every revenue and performance number can be sliced by market.

| Column | Type | Key | Description |
|---|---|---|---|
| region_id | string | PK | Unique region code (REG-001) |
| name | string | | Market name, for example Lagos or Accra |
| country | string | | Country the region sits in, for cross-border reporting |

### lead_sources (8 rows)
How a lead or customer first reached Bloomcrest. Exists so the business can prove which channels actually produce revenue, which drives CAC and marketing spend decisions.

| Column | Type | Key | Description |
|---|---|---|---|
| source_id | string | PK | Unique source code (SRC-001) |
| name | string | | Channel name, for example Instagram or Trade Show |

### products (46 rows)
The catalogue both channels sell. Exists to anchor product-level revenue, margin, and mix analysis.

| Column | Type | Key | Description |
|---|---|---|---|
| product_id | string | PK | Unique product code (PRD-0001) |
| name | string | | Product name, for example Vanilla Amber Soy Candle |
| sku | string | | Stock keeping unit, the internal code warehouses and finance use |
| category | string | | Product line: Candles, Home Fragrance, Bedding, Decor, Gift Sets |
| unit_price | integer | | Selling price in Naira, the basis for revenue |
| unit_cost | integer | | Cost to make or buy the item, the basis for gross margin |

### sales_reps (6 rows)
The wholesale sales team. Exists so deals have an owner and so rep performance can be measured.

| Column | Type | Key | Description |
|---|---|---|---|
| rep_id | string | PK | Unique rep code (REP-001) |
| name | string | | Rep's full name |
| region_id | string | FK | Region the rep is based in, links to regions |
| role | string | | Wholesale Lead or Sales Rep |
| hire_date | date | | When the rep joined, useful for tenure and ramp analysis |

### deal_stages (7 rows)
The pipeline stages a deal moves through. Exists to standardise the sales process and to power the weighted forecast through the win probability on each stage.

| Column | Type | Key | Description |
|---|---|---|---|
| stage_id | string | PK | Unique stage code (STG-01) |
| name | string | | Stage name, for example Sample Sent or Negotiation |
| sort_order | integer | | The order stages run in, so the pipeline sorts correctly |
| win_probability | decimal | | Likelihood a deal at this stage closes, used to weight the forecast |

### lost_reasons (7 rows)
A controlled list of why deals die. Exists so that "we lose deals" becomes "we lose 30 percent on price," which is something the business can act on.

| Column | Type | Key | Description |
|---|---|---|---|
| reason_id | string | PK | Unique reason code (LR-01) |
| reason | string | | The loss reason, for example Price too high or Chose competitor |

---

## Wholesale engine

### companies (140 rows)
The stockist accounts Bloomcrest sells into. Exists as the account record at the centre of the B2B relationship.

| Column | Type | Key | Description |
|---|---|---|---|
| company_id | string | PK | Unique account code (CMP-0001) |
| name | string | | Business name, for example Luxe Boutique |
| type | string | | Boutique, Hotel, Gift Shop, or Corporate |
| region_id | string | FK | Where the account is located, links to regions |
| created_date | date | | When the account first entered the system |

### contacts (203 rows)
The people at each stockist account. Exists because you sell to people, not to buildings, and follow-up needs a named human.

| Column | Type | Key | Description |
|---|---|---|---|
| contact_id | string | PK | Unique contact code (CON-0001) |
| company_id | string | FK | The account this person works for, links to companies |
| full_name | string | | Contact's full name |
| email | string | | Contact email, the main follow-up channel |
| role | string | | Their job, for example Owner or Procurement Manager |

### deals (360 rows)
The heart of the pipeline. One row per opportunity to win or grow a stockist account. Exists so the business can see, value, and forecast its future revenue.

| Column | Type | Key | Description |
|---|---|---|---|
| deal_id | string | PK | Unique deal code (DEAL-0001) |
| company_id | string | FK | The account the deal is with, links to companies |
| contact_id | string | FK | The main person on the deal, links to contacts |
| rep_id | string | FK | The rep who owns the deal, links to sales_reps |
| stage_id | string | FK | Current pipeline stage, links to deal_stages |
| source_id | string | FK | Where the deal came from, links to lead_sources |
| reason_id | string | FK | Loss reason, populated only when the deal is Lost, links to lost_reasons |
| amount | integer | | Deal value in Naira, the initial stocking order size |
| created_date | date | | When the deal was opened |
| expected_close | date | | When the rep expects it to close, used for forecasting |
| actual_close | date | | When it actually closed, blank while the deal is open |
| status | string | | Open, Won, or Lost |

### activities (1,977 rows)
Every touch on a deal. Exists so you can see effort against outcome and detect deals that have gone quiet.

| Column | Type | Key | Description |
|---|---|---|---|
| activity_id | string | PK | Unique activity code (ACT-00001) |
| deal_id | string | FK | The deal this touch belongs to, links to deals |
| rep_id | string | FK | The rep who made the touch, links to sales_reps |
| type | string | | Call, Email, WhatsApp, Meeting, or Sample Sent |
| activity_date | date | | When the touch happened |

### wholesale_orders (1,515 rows)
The recurring reorders that follow a won account. Exists to capture the ongoing revenue a stockist generates over time, which is most of wholesale revenue.

| Column | Type | Key | Description |
|---|---|---|---|
| worder_id | string | PK | Unique reorder code (WHO-00001) |
| company_id | string | FK | The account reordering, links to companies |
| order_date | date | | When the reorder was placed |
| amount | integer | | Reorder value in Naira |

---

## DTC engine

### customers (18,000 rows)
Direct consumers who buy from the online store. Exists so customer economics (CAC, LTV, repeat rate, churn) can be measured.

| Column | Type | Key | Description |
|---|---|---|---|
| customer_id | string | PK | Unique customer code (CUS-000001) |
| full_name | string | | Customer's full name |
| email | string | | Customer email |
| region_id | string | FK | Where the customer is, links to regions |
| source_id | string | FK | How they were acquired, links to lead_sources |
| first_order_date | date | | Date of their first purchase, the anchor for retention and cohort analysis |
| acquisition_cost | integer | | What it cost to acquire this customer, the CAC input |

### orders (143,540 rows)
Each direct purchase. Exists as the record of DTC revenue and demand over time.

| Column | Type | Key | Description |
|---|---|---|---|
| order_id | string | PK | Unique order code (ORD-000001) |
| customer_id | string | FK | Who placed the order, links to customers |
| order_date | date | | When the order was placed |
| total_amount | integer | | Order value in Naira, equal to the sum of its line items |
| status | string | | Delivered, Processing, Shipped, Cancelled, Returned, or Pending |

### order_items (216,747 rows)
The individual products inside each order. Exists so revenue can be split by product and category, and so basket size can be analysed.

| Column | Type | Key | Description |
|---|---|---|---|
| order_item_id | string | PK | Unique line code (ITM-0000001) |
| order_id | string | FK | The order this line belongs to, links to orders |
| product_id | string | FK | The product sold, links to products |
| quantity | integer | | Units of the product on this line |
| unit_price | integer | | Price per unit at time of sale |
| line_total | integer | | quantity multiplied by unit_price |

### payments (123,569 rows)
Money actually collected against orders. Exists so booked revenue can be separated from collected cash, which matters for cash planning. Cancelled and returned orders have no payment.

| Column | Type | Key | Description |
|---|---|---|---|
| payment_id | string | PK | Unique payment code (PAY-000001) |
| order_id | string | FK | The order being paid for, links to orders |
| amount | integer | | Amount paid in Naira |
| payment_date | date | | When payment was received |
| method | string | | Card, Bank Transfer, Paystack, Flutterwave, USSD, or Pay on Delivery |

---

## How the tables connect

- A region locates many companies and many customers.
- A lead_source is the origin of many deals and many customers.
- A company employs many contacts, is the source of many deals, and places many wholesale_orders.
- A deal is owned by one sales_rep, sits in one deal_stage, and logs many activities.
- A customer places many orders, each order contains many order_items drawn from products, and each order is settled by one or more payments.
