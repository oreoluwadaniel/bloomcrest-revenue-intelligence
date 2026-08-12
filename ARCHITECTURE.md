# System Architecture

```text
Operational source data
        |
        v
PostgreSQL warehouse
        |
        +--> customers
        +--> orders
        +--> order items
        +--> payments
        +--> subscriptions / deals
        |
        v
Validation layer
        |
        +--> key integrity
        +--> range checks
        +--> business rules
        +--> reconciliation
        |
        v
CRM and revenue views
        |
        +--> customer value
        +--> RFM
        +--> CAC / LTV
        +--> deal routing
        +--> revenue monitoring
        |
        v
Decision outputs
```

## Controls

The repository separates observed values, calculated metrics, modeled outputs, and recommendations. SQL validation checks cover keys, ranges, business rules, cross-table relationships, order reconciliation, and CRM reconciliation.

## Scope

The transactional data is synthetic. CRM integration and automation are documented with a clear distinction between what is implemented and what is designed.
