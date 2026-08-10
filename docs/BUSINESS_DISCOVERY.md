# Bloomcrest Business Discovery & Solution Scope

> Portfolio case-study discovery document for a fictional company using synthetic data.

---

## 1. Business Context

Bloomcrest is modeled as a Lagos-based home and lifestyle company selling:

- Candles
- Home fragrance
- Bedding
- Decor
- Gift sets

The operating model contains two revenue engines:

### DTC

A high-volume direct-to-consumer channel driven by online orders and repeat purchases.

### Wholesale

A B2B channel selling to boutiques, hotels, gift shops, and corporate customers through a sales pipeline.

---

## 2. Discovery Questions

The solution is designed around three management questions:

1. Are we likely to hit the revenue target?
2. Where is revenue leaking?
3. Which customers and deals require action?

These questions determine the data model and analytical requirements.

---

## 3. Business Pain Points

The case study models the following operational problems:

- DTC and wholesale data are separated.
- Pipeline visibility is limited.
- Forecasting relies too heavily on raw pipeline value.
- Stalled deals may not receive timely intervention.
- Customer acquisition cost is not consistently compared with downstream value.
- Customer inactivity is difficult to prioritize.
- Booked revenue and collected cash need to be distinguishable.
- Loss reasons need structured analysis.

---

## 4. Business Objectives

The solution should:

- Create a trusted revenue data foundation.
- Make wholesale pipeline stages and ownership explicit.
- Produce a probability-weighted pipeline forecast.
- Detect pipeline risks.
- Quantify acquisition-channel economics.
- Identify retention and win-back priorities.
- Reconcile revenue across analytical layers.

---

## 5. Scope

### In scope

- PostgreSQL data model
- Synthetic operational dataset
- HubSpot CRM data model/migration package
- CRM-to-PostgreSQL synchronization logic
- Automation design
- Revenue analytics
- Customer economics
- RFM segmentation
- Cohort analysis
- Pipeline forecasting
- Data validation

### Out of scope

- Live Shopify integration
- Live payment-gateway integration
- Production customer communications
- Production deployment
- Guaranteed revenue uplift
- Production ML scoring
- Real-time BI infrastructure

---

## 6. Solution Principles

### Principle 1 - Model the business before modeling the data

The data model follows the two revenue engines rather than forcing them into one generic sales table.

### Principle 2 - Keep probability and prediction separate

Stage probabilities are transparent business assumptions.

The experimental ML model is evaluated independently.

### Principle 3 - Reconcile before reporting

Revenue figures should reconcile across source tables and analytical views.

### Principle 4 - Do not automate weak decisions

The lead-scoring experiment produced an AUC of 0.42 and was therefore not promoted to production logic.

---

## 7. Success Criteria

A production implementation would be considered successful when it can:

- reconcile revenue consistently
- provide trustworthy pipeline visibility
- reduce missed follow-up
- identify actionable retention segments
- make customer economics measurable
- provide traceable forecast assumptions

Because this is a portfolio case study, these are target success criteria, not measured client outcomes.
