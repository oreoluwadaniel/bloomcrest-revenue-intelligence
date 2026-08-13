# Bloomcrest Business Discovery and Scope

## Business context

Bloomcrest is modeled as a Lagos-based home and lifestyle company selling candles, home fragrance, bedding, decor, and gift sets.

There are two sales channels:

### DTC

Online sales to individual customers, with repeat purchases driving part of the revenue.

### Wholesale

B2B sales to boutiques, hotels, gift shops, and corporate customers through a sales pipeline.

## The questions I wanted the system to answer

1. Are we on track to hit the revenue target?
2. Where is revenue being lost or delayed?
3. Which customers and deals need attention?

Those questions drive the data model and the analysis. I did not start with a dashboard and work backwards.

## Problems modeled in the case study

- DTC and wholesale data are kept separately.
- Pipeline visibility is limited.
- Raw pipeline value can make the forecast look better than it is.
- Stalled deals can sit without follow-up.
- Acquisition cost is not always compared with the value a customer brings later.
- Customer inactivity is difficult to prioritize.
- Booked revenue and collected cash are different numbers.
- Loss reasons need consistent categories before they can be compared.

## What the project needs to do

The build should:

- give revenue data one reliable structure
- make pipeline stages and ownership clear
- calculate a probability-weighted pipeline value
- flag pipeline risks
- compare acquisition cost with customer value
- identify customers worth a retention or win-back review
- reconcile revenue between the source tables and reporting views

## Scope

### Included

- PostgreSQL data model
- Synthetic operational data
- HubSpot CRM migration package
- CRM-to-PostgreSQL sync logic
- Automation design
- Revenue analysis
- Customer economics
- RFM segmentation
- Cohort analysis
- Pipeline forecasting
- Data validation

### Not included

- Live Shopify connection
- Live payment gateway connection
- Production customer messaging
- Production deployment
- Guaranteed revenue increase
- Production machine-learning scoring
- Real-time BI infrastructure

## Decisions behind the build

### Start with the business structure

The database follows the two sales channels because DTC and wholesale behave differently. I did not force both into one generic sales table just to make the model look simpler.

### Keep business probabilities separate from the model test

Deal-stage probabilities are business assumptions. The experimental ML model is evaluated separately so a weak model does not quietly become part of the forecast.

### Check the numbers before reporting them

Revenue should reconcile between the source tables and the analytical views before it is shown in a report.

### Don't automate a decision that has not earned trust

The lead-scoring experiment produced a cross-validated AUC of 0.42. That result was not good enough to use as production scoring, so I did not ship it as one.

## Success criteria

A real implementation would need to show that it can:

- reconcile revenue consistently
- give the sales team a clear view of the pipeline
- reduce missed follow-up
- identify useful retention groups
- make customer economics measurable
- show where forecast assumptions come from

These are target measures for a real implementation. They are not measured client results from this portfolio project.
