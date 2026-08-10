# Bloomcrest Revenue Intelligence & Revenue Operations System

> A revenue intelligence case study built on PostgreSQL, CRM design, automation, and Python/SQL analytics, covering pipeline forecasting, customer economics, and retention for a two-channel retail business.

**Client:** Bloomcrest, fictional case-study company
**Data:** Synthetic, generated for this project
**Analysis period:** July 2024 - July 2026
**Stack:** PostgreSQL, SQL, HubSpot, Make.com, Python, pandas, scikit-learn

---

## 1. Why I built this

Bloomcrest is a fictional Lagos-based home and lifestyle brand I modeled around two revenue engines:

- DTC e-commerce - high-volume consumer orders and repeat-purchase behavior.
- Wholesale B2B - account-based selling through a structured sales pipeline.

I built the case study around one question I kept running into in real revenue-ops work:

> How does a business move from fragmented operational data and reactive follow-up to one system for revenue visibility, pipeline control, customer economics, and action?

Here's how the pieces connect:

```text
Operational Data
      v
PostgreSQL Data Foundation
      v
CRM / Pipeline Layer
      v
Automation
      v
SQL Analytics
      v
Customer & Pipeline Intelligence
      v
Management Decisions
```

I didn't set out to build a dashboard. The dashboard is one output of a wider operating system. The data model, the CRM process, and the automation matter just as much as what ends up on screen.

---

## 2. The business problem

In the case study, DTC and wholesale run as separate operational processes, which raises a set of decisions management can't answer with the data as it stands:

- Can the business realistically hit its revenue target?
- Which open deals deserve attention first?
- Where is pipeline value leaking?
- Which acquisition channels generate economically valuable customers?
- Which customers are showing signs of disengagement?
- What revenue is booked versus collected?
- Can CRM activity and warehouse analytics stay in sync?

Answering these needs data architecture, CRM process design, automation, and analytics working together, not another one-off report.

---

## 3. How it's built

### Layer 1 - Data foundation

A normalized PostgreSQL schema stores DTC customers, orders, order items, payments, and products alongside wholesale companies, contacts, deals, deal activities, reorders, sales reps, regions, lead sources, deal stages, and loss reasons. Primary and foreign keys enforce referential integrity throughout.

### Layer 2 - CRM

The wholesale pipeline is modeled in HubSpot around companies, contacts, deals, deal stages, sales ownership, lead source, region, expected close date, and loss reason. This repo includes the prepared CRM migration datasets and a Python sync script.

### Layer 3 - Automation

The automation layer covers regional lead assignment, high-value deal alerts, stalled-deal detection, weekly pipeline reporting, and CRM-to-PostgreSQL synchronization. What's in this repo is the automation logic in code and documentation. Any Make.com scenario hosted outside this repo isn't something I'm claiming is live unless I can show it.

### Layer 4 - Analytics

SQL and Python cover revenue, pipeline, weighted forecast, win rate, sales-cycle duration, loss reasons, CAC, LTV, LTV:CAC, churn risk, cohort retention, RFM segmentation, and revenue trend forecasting.

---

## 4. The dataset

| Entity | Records |
|---|---:|
| Customers | 18,000 |
| Orders | 143,540 |
| Order items | 216,747 |
| Payments | 123,569 |
| Products | 46 |
| Companies | 140 |
| Contacts | 203 |
| Deals | 360 |
| Activities | 1,977 |
| Wholesale reorders | 1,515 |
| Sales reps | 6 |
| Regions | 8 |
| Lead sources | 8 |

All of it is synthetic. None of it describes a real company's operations.

---

## 5. Data quality and reconciliation

I wrote a 23-check SQL test suite covering referential integrity, primary-key uniqueness, value ranges, deal business rules, cross-table rules, order reconciliation, and CRM deal-count reconciliation. Run tests/Bloomcrest_tests.sql yourself, every row should read PASS, and if one doesn't, the query tells you exactly which rule broke.

What it checks for:

- No orphaned foreign keys
- No duplicate primary keys on the tested entities
- No invalid deal amounts
- No invalid stage probabilities
- No non-positive order-item quantities
- No inconsistent deal status/stage combinations
- No payments attached to cancelled or returned orders
- No orders dated before a customer's first-order date
- Order totals reconcile to line items within NGN 0.50
- 360 deals in the source dataset, matching the HubSpot import

---

## 6. What the data shows

### Revenue scale

Counting successful DTC orders (Delivered, Shipped, Processing) plus wholesale reorders, the model produces:

**NGN 7.353B modeled revenue** over the analysis period.

Split roughly:

- 43.6% DTC
- 56.4% wholesale

A linear trend across the 24 complete months before the partial July 2026 period comes out to:

**NGN 31.7M/month upward trend**

That's a descriptive trend, not a forecast I'd stake a plan on.

### Wholesale pipeline

- 48.6% win rate among closed deals
- 41.5-day average cycle for won deals
- NGN 129.44M open pipeline
- NGN 55.09M weighted open pipeline (deal amount x stage win probability)

The weighted figure is a planning estimate. It is not NGN 55.09M of guaranteed revenue.

### Customer churn and inactivity

Using no successful order in the prior 90 days as of July 20, 2026, I found:

**6,129 of 18,000 customers (about 34.1%)** had gone quiet.

That's a defined inactivity indicator, not confirmed contractual churn.

The RFM segmentation separately flags:

**3,884 high-priority "At risk" / "Can't lose" customers**, representing roughly NGN 819M in historical successful-order revenue.

These are the accounts I'd put at the top of a win-back campaign.

### Lead scoring, and where I stopped

I tested a logistic-regression model on historical closed deals. Five-fold cross-validated ROC-AUC came back at:

**0.42**

That's below what a coin flip would give you. So the model doesn't ship as a production scoring tool. The pipeline still ranks deals by stage win probability and expected value, numbers a sales manager can actually explain to their team without a data science degree.

That's a deliberate call, not an oversight. A model isn't worth shipping just because it exists.

---

## 7. Decisions this supports

**Revenue planning** - weigh the pipeline against historical trends to see if the business is on track.

**Pipeline intervention** - prioritize open deals by stage probability, value, owner, expected close, and activity signals.

**Sales coaching** - compare win rates and cycle length across reps.

**Loss reduction** - dig into closed-lost reasons for patterns management can act on.

**Acquisition allocation** - compare CAC and downstream revenue by channel.

**Retention** - use recency, frequency, and monetary value to prioritize who gets a win-back call.

**Cash planning** - separate booked DTC revenue from what's actually been collected.

---

## 8. What's observed, calculated, modeled, and recommended

I try to keep these four categories separate everywhere in this project:

- Observed - directly in the synthetic dataset.
- Calculated - derived mathematically from it.
- Modeled - produced with assumptions, probabilities, or statistical methods.
- Recommended - a management action the analysis suggests.

For example, NGN 55.09M weighted pipeline is a modeled planning value, not NGN 55.09M guaranteed revenue. Same logic for the 6,129 inactive customers: that's a 90-day inactivity measure, not a churn confirmation.

---

## 9. Repository structure

```text
bloomcrest-revenue-intelligence/
|
|-- README.md
|
|-- docs/
|   |-- BUSINESS_DISCOVERY.md
|   |-- SYSTEM_REQUIREMENTS.md
|   |-- DATA_DICTIONARY.md
|   |-- QA_TEST_PLAN.md
|   |-- CASE_STUDY.md
|
|-- database/
|   |-- Bloomcrest_schema.sql
|   |-- Bloomcrest_star_schema.sql
|
|-- analytics/
|   |-- Bloomcrest_analytics.sql
|
|-- intelligence/
|   |-- bloomcrest_ml.py
|
|-- automation/
|   |-- hubspot_to_postgres_sync.py
|
|-- tests/
|   |-- Bloomcrest_tests.sql
|
|-- crm/
|   |-- hubspot_1_companies.csv
|   |-- hubspot_2_contacts.csv
|   |-- hubspot_3_deals.csv
|
|-- data/
|   |-- bloomcrest_data/
|       |-- *.csv
```

Note on scope: the full transactional CSVs (customers, orders, order_items, payments; about 23MB combined) and the architecture diagram image aren't committed to this repo. They're large binary/flat-file assets better suited to external storage than a git repo, and this portfolio upload was done through a browser session without local git access. The schema, star schema, and analytics SQL fully describe their structure; docs/DATA_DICTIONARY.md documents every column.

---

## 10. What this project is meant to show

I wanted this to prove I can connect business discovery to requirements, to relational data modeling, to CRM design, to automation, to warehouse and SQL analytics, to customer and pipeline intelligence, to something an executive can actually act on.

The strongest part isn't any single SQL query. It's that the whole chain holds together: customer acquisition, CRM pipeline management, revenue, retention, and the decisions they're meant to inform, all connected instead of living in separate spreadsheets.

---

## Case-study status

Fictional client. Synthetic data. Built as a portfolio piece to demonstrate solution design and analytical capability, not a claim of measured results at a real organization named Bloomcrest.

**Built by Daniel Olatunji**
