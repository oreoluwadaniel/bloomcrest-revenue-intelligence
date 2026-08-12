# Bloomcrest Revenue Intelligence & Revenue Operations

**A revenue operations system that connects customer data, CRM pipeline, revenue, retention, and forecasting into one decision layer.**

**Stack:** PostgreSQL, SQL, Python, pandas, scikit-learn, HubSpot, Make.com  
**Period:** July 2024 to July 2026  
**Data:** Synthetic  
**Modeled revenue:** NGN 7.353B  
**Customers:** 18,000  
**Wholesale deals:** 360

---

## The business problem

Bloomcrest runs two revenue channels:

- **DTC:** high-volume online sales and repeat purchases
- **Wholesale:** account-based sales managed through a CRM pipeline

When those activities sit in separate systems, management gets an incomplete view of revenue.

The business needs to know:

- Are we on track to hit the revenue target?
- Which deals need attention now?
- How much pipeline is actually likely to close?
- Which acquisition channels produce valuable customers?
- Which customers are going quiet?
- How much revenue has been booked versus collected?
- Where is revenue being lost between acquisition, sales, and retention?

This project connects those questions into one revenue operations system.

---

## The solution

```text
Operational Data
      ↓
PostgreSQL Data Foundation
      ↓
CRM & Pipeline Management
      ↓
Automation & Data Sync
      ↓
SQL + Python Analytics
      ↓
Revenue, Pipeline & Customer Intelligence
      ↓
Management Decisions
