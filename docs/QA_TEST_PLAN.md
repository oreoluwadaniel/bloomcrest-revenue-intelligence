# Bloomcrest Quality Assurance Test Plan & Results

## Purpose

This document defines the validation framework for the Bloomcrest portfolio case study.

The executable database test suite is:

Bloomcrest_tests.sql

The SQL contains 23 automated checks.

---

# 1. Automated Database Validation

The 23 checks cover:

| Group | Checks | Purpose |
|---|---:|---|
| Referential integrity | 6 | Detect orphan child records |
| Primary-key uniqueness | 3 | Detect duplicate IDs |
| Value ranges | 3 | Validate amounts, probabilities, quantities |
| Deal business rules | 7 | Validate status, stages, dates, loss reasons |
| Cross-table rules | 2 | Validate payment/order and customer/order relationships |
| Reconciliation | 2 | Validate order totals and CRM deal count |
| Total | 23 | |

The supplied synthetic data was independently checked against these rules during portfolio review and the structural checks reconcile to zero violations.

---

# 2. Key Validation Results

- No orphaned foreign keys in the tested relationships.
- No duplicate deal_id, order_id, or customer_id.
- No negative/null deal amounts.
- All stage win probabilities fall within 0-1.
- All order-item quantities are positive.
- Won deals do not contain loss reasons.
- Lost deals contain loss reasons.
- Open deals do not contain loss reasons.
- Closed deals have close dates.
- Open deals do not have close dates.
- Won/Lost stage assignments match the documented stage IDs.
- No payments are attached to cancelled or returned orders.
- No order predates its customer's first-order date.
- Order totals reconcile to order-item totals within the documented NGN 0.50 tolerance.
- The dataset contains 360 deals.

---

# 3. CRM / Migration Validation

The repository contains prepared HubSpot migration datasets:

- 140 companies
- 203 contacts
- 360 deals

The CSV counts reconcile with the modeled source data.

### Important evidence boundary

The repository demonstrates the migration dataset and synchronization implementation.

Claims about an externally hosted HubSpot portal or Make.com scenario should only be presented as deployed/live when corresponding external evidence or screenshots are included.

---

# 4. Automation Validation

The intended automation paths are:

1. High-value deal alert
2. Region-based assignment
3. Stalled-deal detection
4. Weekly pipeline digest
5. CRM-to-PostgreSQL synchronization

The Python synchronization implementation uses an idempotent PostgreSQL upsert pattern.

For public portfolio presentation, externally hosted Make.com automations should be described as implemented workflows only when the actual scenario exists and can be demonstrated.

---

# 5. Analytics Validation

## Pipeline

Closed-deal win rate:

48.6%

Average cycle for won deals:

41.5 days

Open pipeline:

NGN 129.44M

Weighted open pipeline:

NGN 55.09M

---

## Customer inactivity

As of July 20, 2026:

6,129 of 18,000 customers

had no successful order in the prior 90 days.

That equals approximately:

34.1%

This is a defined inactivity metric, not confirmed contractual churn.

---

## RFM

The RFM implementation identifies:

3,884 customers

in the At risk and Can't lose segments.

Their historical successful-order revenue is approximately:

NGN 819M

These are prioritization outputs, not guarantees that all accounts will churn.

---

# 6. Machine Learning Validation

A logistic regression experiment was evaluated using five-fold cross-validation.

Result:

ROC-AUC = 0.42

Interpretation:

- 0.50 is approximately random discrimination
- 0.42 is weak / below random performance

Decision:

Do not deploy the ML model as a production lead score.

The project retains the experiment because documenting an unsuccessful model is more rigorous than hiding it.

The operational ranking uses interpretable stage probability and expected deal value.

---

# 7. Cohort Analysis Defect

The first cohort-retention implementation produced impossible values above 100%.

The defect was identified as a denominator problem and corrected.

The corrected analysis is retained as the current analytical approach.

This is included intentionally because the testing record demonstrates:

detect - diagnose - correct - retest

rather than implying that the first analytical query was perfect.

---

# 8. Revenue Reconciliation

Using successful DTC orders and wholesale reorders:

NGN 7.353B

of modeled revenue is represented in the analysis period.

Channel mix:

- DTC: 43.6%
- Wholesale: 56.4%

The test suite separately verifies the underlying order-level reconciliation.

---

# 9. Test Status

### Database integrity

PASS

### Key business rules

PASS

### Order reconciliation

PASS

### CRM migration counts

PASS

### ML production-readiness

NOT APPROVED

### External automation deployment

Evidence-dependent

The final distinction prevents the portfolio from treating a tested local implementation and an externally deployed automation as the same thing.
