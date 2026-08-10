# Bloomcrest Revenue Intelligence - Case Study

## From fragmented revenue data to a decision-support system

### Context

Bloomcrest is a fictional case-study company modeled as a Lagos-based home and lifestyle brand operating two revenue engines:

1. Direct-to-consumer e-commerce
2. Wholesale B2B sales

The case study was designed to answer three management questions:

Are we on track to hit the number?

Where is revenue leaking?

What should management act on next?

---

## The Problem

The two revenue engines have different operating characteristics.

DTC generates high transaction volume and provides the behavioral data required for:

- CAC analysis
- repeat purchasing
- retention
- churn-risk analysis
- cohort analysis

Wholesale depends on:

- named accounts
- sales representatives
- pipeline stages
- activities
- expected close dates
- loss reasons
- reorders

Treating both channels as one simple sales table would destroy important business context.

The solution therefore uses a two-engine revenue model connected through shared dimensions such as date, region, product, and acquisition source.

---

## Solution

I designed a normalized PostgreSQL data model containing 15 operational tables and generated a synthetic dataset containing:

- 18,000 customers
- 143,540 orders
- 216,747 order items
- 123,569 payments
- 140 wholesale companies
- 203 contacts
- 360 deals
- 1,977 deal activities
- 1,515 wholesale reorders

The database uses primary keys, foreign keys, checks, indexes, and analytical views.

The wholesale CRM layer is represented through HubSpot migration datasets and a Python synchronization script.

The automation layer is represented through Python ETL logic and documented Make.com workflows for:

- lead routing
- high-value deal alerts
- stalled-deal detection
- recurring pipeline reporting

The analytics layer combines SQL and Python for revenue, pipeline, customer economics, retention, RFM segmentation, and forecasting.

---

## What the data shows

### Revenue

Successful DTC orders plus wholesale reorders represent approximately:

NGN 7.353B

of modeled revenue over the analysis period.

The mix is approximately:

- 43.6% DTC
- 56.4% wholesale

---

### Pipeline

Closed deals produce a:

48.6% win rate

Won deals average approximately:

41.5 days

from creation to close.

The open pipeline is:

NGN 129.44M

and its stage-weighted value is:

NGN 55.09M

The weighted value is a probability-based planning measure rather than a revenue guarantee.

---

### Customer inactivity

As of July 20, 2026:

6,129 customers

had no successful order within the previous 90 days.

That represents approximately:

34.1% of the 18,000-customer base.

This is treated as a 90-day inactivity indicator, not confirmed contractual churn.

RFM segmentation identifies:

3,884 high-priority customers

in the At risk and Can't lose segments, representing approximately:

NGN 819M

in historical successful-order revenue.

---

## What did not work

The project also tested a logistic-regression lead-scoring model using historical closed deals.

The five-fold ROC-AUC was:

0.42

That is not strong enough to justify shipping the model as a production decision engine.

Instead of hiding that result, the system documents it and keeps the operational ranking interpretable through stage probability and expected deal value.

This is an important analytical principle:

A model is not valuable merely because it is machine learning. It is valuable only if it performs better than a credible baseline and improves a business decision.

---

## Business Decisions Enabled

The system supports:

- Revenue forecasting
- Pipeline prioritization
- Sales-rep performance analysis
- Closed-lost analysis
- Acquisition-channel economics
- Customer retention prioritization
- Revenue and cash reconciliation
- CRM-to-warehouse synchronization

---

## Outcome

The project converts a fragmented set of business processes into a connected analytical architecture:

Business Questions -> Requirements -> Relational Data Model -> CRM Process -> Automation -> Analytics -> Decision Support

The important deliverable is therefore not a dashboard.

It is a revenue operating and intelligence system.

---

## Case-study boundary

Bloomcrest is fictional and all operational data is synthetic.

Financial values, customer behavior, pipeline outcomes, and recommendations are therefore case-study outputs, not claims of measured performance at a real organization.
