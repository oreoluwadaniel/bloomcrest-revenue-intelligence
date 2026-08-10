"""
Bloomcrest Revenue Intelligence | Phase 8 Part 2 | Machine learning.

Runs three analyses against your Postgres warehouse:
  A. Lead scoring      - rank open deals by expected value, with a trained
                         logistic model reported honestly alongside.
  B. Churn risk (RFM)  - segment customers by Recency, Frequency, Monetary
                         and surface high-value accounts about to lapse.
  C. Revenue forecast  - a simple trend forecast of the next three months.

Setup:
  pip install pandas scikit-learn sqlalchemy psycopg2-binary
Fill in the connection string below, then run:
  python bloomcrest_ml.py
"""

import warnings; warnings.filterwarnings("ignore")
import numpy as np, pandas as pd
from sqlalchemy import create_engine
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.model_selection import cross_val_score

# ------------------------------ CONFIG --------------------------------------
# postgresql://USER:PASSWORD@HOST:PORT/DATABASE
ENGINE = create_engine("postgresql+psycopg2://postgres:YOUR_PASSWORD@localhost:5432/bloomcrest")
AS_OF  = pd.Timestamp("2026-07-20")   # the last date in the data
# ----------------------------------------------------------------------------

def load(sql):
    return pd.read_sql(sql, ENGINE)

deals            = load("SELECT * FROM deals")
companies        = load("SELECT company_id, name, type, region_id FROM companies")
lead_sources     = load("SELECT source_id, name FROM lead_sources")
deal_stages      = load("SELECT stage_id, name, win_probability FROM deal_stages")
orders           = load("SELECT order_id, customer_id, order_date, total_amount, status FROM orders")
wholesale_orders = load("SELECT company_id, order_date, amount FROM wholesale_orders")
for df, cols in [(deals, ["created_date","actual_close"]), (orders, ["order_date"]), (wholesale_orders, ["order_date"])]:
    for c in cols:
        if c in df: df[c] = pd.to_datetime(df[c])

# ============================================================ A. LEAD SCORING
print("="*70, "\nA. LEAD SCORING\n", "="*70)
d = (deals
     .merge(companies[["company_id","region_id","type","name"]].rename(columns={"name":"company"}), on="company_id", how="left")
     .merge(lead_sources.rename(columns={"name":"source"}), on="source_id", how="left"))
closed = d[d.status.isin(["Won","Lost"])].copy()
closed["won"] = (closed.status == "Won").astype(int)
cat, num = ["source","rep_id","region_id","type"], ["amount"]
pipe = Pipeline([
    ("pre", ColumnTransformer([("c", OneHotEncoder(handle_unknown="ignore"), cat)], remainder="passthrough")),
    ("clf", LogisticRegression(max_iter=1000)),
])
auc = cross_val_score(pipe, closed[num+cat], closed["won"], cv=5, scoring="roc_auc").mean()
print(f"Trained logistic model, 5-fold ROC-AUC = {auc:.3f}  (0.5 means no learnable signal)")

pipe.fit(closed[num+cat], closed["won"])
opn = d[d.status == "Open"].copy()
opn["model_prob"] = pipe.predict_proba(opn[num+cat])[:,1]
opn = opn.merge(deal_stages.rename(columns={"name":"stage"}), on="stage_id")
opn["lead_score"]     = (0.6*opn.win_probability + 0.4*opn.model_prob).round(2)
opn["expected_value"] = (opn.amount * opn.win_probability).astype(int)
print("\nTop 10 open deals to prioritise (expected value = amount x stage win probability):")
print(opn.sort_values("expected_value", ascending=False)
        .head(10)[["company","stage","amount","win_probability","lead_score","expected_value"]]
        .to_string(index=False))

# ==================================================== B. CHURN RISK VIA RFM
print("\n", "="*70, "\nB. CHURN RISK (RFM segmentation)\n", "="*70)
succ = orders[orders.status.isin(["Delivered","Shipped","Processing"])]
rfm = succ.groupby("customer_id").agg(
        recency=("order_date", lambda s: (AS_OF - s.max()).days),
        frequency=("order_id", "count"),
        monetary=("total_amount", "sum")).reset_index()
rfm["R"] = pd.qcut(rfm.recency.rank(method="first"),   5, labels=[5,4,3,2,1]).astype(int)
rfm["F"] = pd.qcut(rfm.frequency.rank(method="first"), 5, labels=[1,2,3,4,5]).astype(int)
rfm["M"] = pd.qcut(rfm.monetary.rank(method="first"),  5, labels=[1,2,3,4,5]).astype(int)
def seg(r):
    if r.R >= 4 and r.F >= 4: return "Champions"
    if r.R >= 3 and r.F >= 3: return "Loyal"
    if r.R <= 2 and r.F >= 4: return "Can't lose (lapsing high value)"
    if r.R <= 2 and r.F >= 3: return "At risk"
    if r.R <= 2:              return "Lost / dormant"
    return "Needs nurturing"
rfm["segment"] = rfm.apply(seg, axis=1)
summ = (rfm.groupby("segment").agg(customers=("customer_id","count"), revenue=("monetary","sum"))
          .sort_values("revenue", ascending=False))
summ["revenue"] = summ["revenue"].astype(int)
print(summ.to_string())
atrisk = rfm[rfm.segment.str.startswith(("At risk","Can't"))].sort_values("monetary", ascending=False)
print(f"\nHigh-value customers to win back now: {len(atrisk):,}  (export this list for a campaign)")

# ==================================================== C. REVENUE FORECAST
print("\n", "="*70, "\nC. REVENUE FORECAST (next 3 months)\n", "="*70)
dtc = succ.assign(m=succ.order_date.values.astype("datetime64[M]")).groupby("m").total_amount.sum()
ws  = wholesale_orders.assign(m=wholesale_orders.order_date.values.astype("datetime64[M]")).groupby("m").amount.sum()
monthly = dtc.add(ws, fill_value=0).sort_index().iloc[:-1]   # drop partial current month
y_, x_ = monthly.values.astype(float), np.arange(len(monthly))
b1, b0 = np.polyfit(x_, y_, 1)
fc = np.polyval([b1, b0], np.arange(len(monthly), len(monthly)+3))
idx = pd.period_range(monthly.index[-1].to_period("M")+1, periods=3, freq="M")
print("Last 6 actual months (NGN millions):")
print((monthly.tail(6)/1e6).round(1).to_string())
print("\n3-month trend forecast (NGN millions):")
for p, v in zip(idx, fc): print(f"  {p}   {v/1e6:5.1f}")
print(f"\nTrend: revenue is {'growing' if b1>0 else 'declining'} about {abs(b1)/1e6:.1f}M NGN/month.")
print("Note: a simple linear trend underweights recent acceleration; Holt's")
print("exponential smoothing, ARIMA, or Prophet would capture it better.")
