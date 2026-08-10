# Bloomcrest Revenue Intelligence - System Requirements Specification

## 1. Purpose

This document translates the fictional business discovery into testable system requirements.

---

## 2. Business Requirements

| ID | Requirement |
|---|---|
| BR-1 | Provide a consistent revenue view across DTC and wholesale |
| BR-2 | Make the wholesale pipeline visible by stage, value, owner, and expected close |
| BR-3 | Produce a probability-weighted pipeline forecast |
| BR-4 | Identify stalled or high-priority deals for intervention |
| BR-5 | Quantify acquisition-channel economics |
| BR-6 | Identify customers requiring retention or win-back attention |
| BR-7 | Separate booked revenue from collected cash |
| BR-8 | Reconcile key revenue measures across the analytical model |

---

## 3. Functional Requirements

### Data foundation

| ID | Requirement |
|---|---|
| FR-1 | Store core entities using primary keys |
| FR-2 | Enforce or test foreign-key relationships |
| FR-3 | Validate key business-rule constraints |
| FR-4 | Provide conformed dimensions for analytical views |

### Wholesale pipeline

| ID | Requirement |
|---|---|
| FR-5 | Represent each deal with stage, value, owner, source, and dates |
| FR-6 | Associate activities with deals |
| FR-7 | Capture controlled loss reasons |
| FR-8 | Calculate stage-weighted pipeline value |

### Automation

| ID | Requirement |
|---|---|
| FR-9 | Support region-based lead routing |
| FR-10 | Identify stalled deals |
| FR-11 | Alert on high-value deals |
| FR-12 | Support recurring pipeline reporting |
| FR-13 | Synchronize CRM deal records with the warehouse |

### Analytics

| ID | Requirement |
|---|---|
| FR-14 | Calculate revenue by channel |
| FR-15 | Calculate CAC and customer revenue by source |
| FR-16 | Calculate customer inactivity using a documented as-of date |
| FR-17 | Produce RFM customer segmentation |
| FR-18 | Produce cohort retention measures |
| FR-19 | Produce revenue trend estimates |
| FR-20 | Evaluate ML lead scoring before production use |

---

## 4. Non-Functional Requirements

| ID | Requirement |
|---|---|
| NFR-1 | Data relationships must be testable |
| NFR-2 | Analytical definitions must be documented |
| NFR-3 | Forecasts must expose their assumptions |
| NFR-4 | Automation should fail visibly rather than silently |
| NFR-5 | Another analyst should be able to understand and rerun the workflow |
| NFR-6 | Sensitive credentials must never be committed to the repository |

---

## 5. ML Governance Requirement

The ML lead-scoring experiment must be evaluated against a credible baseline.

Current result:

Five-fold ROC-AUC = 0.42

Therefore:

The ML model is not approved for production use.

The current operational prioritization uses interpretable stage probability and expected deal value.

---

## 6. Acceptance Criteria

A future production implementation should demonstrate:

- zero critical referential-integrity violations
- reconciled revenue totals
- reproducible pipeline calculations
- documented forecast assumptions
- successful CRM synchronization
- tested automation paths
- approved ownership and access controls
- acceptable ML performance before any model is operationalized

---

## 7. Traceability

| Requirement | Primary artifact |
|---|---|
| FR-1-4 | PostgreSQL schema / tests |
| FR-5-8 | CRM schema / analytics |
| FR-9-13 | Automation code / CRM workflow design |
| FR-14-20 | Analytics SQL / Python |
