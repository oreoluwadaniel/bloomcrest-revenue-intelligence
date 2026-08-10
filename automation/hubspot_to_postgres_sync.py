"""
HubSpot -> Postgres deal sync (local ETL).

Setup (run once in a terminal):
  pip install requests psycopg2-binary

Fill in the four values in CONFIG below, then run:
  python hubspot_to_postgres_sync.py

Schedule it to run daily:
  - Mac / Linux: add a line to `crontab -e`, for example run 07:00 daily:
        0 7 * * * /usr/bin/python3 /path/to/hubspot_to_postgres_sync.py
  - Windows: Task Scheduler > Create Basic Task > Daily > Start a program >
        program: python    arguments: C:\\path\\to\\hubspot_to_postgres_sync.py
"""

import requests
import psycopg2
from psycopg2.extras import execute_values

# ------------------------------ CONFIG --------------------------------------
HUBSPOT_TOKEN = "PASTE_YOUR_PRIVATE_APP_TOKEN_HERE"   # the token from your Make Integration private app
PG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "bloomcrest",
    "user": "postgres",
    "password": "PASTE_YOUR_POSTGRES_PASSWORD_HERE",
}

# HubSpot property internal names to pull. The standard ones are below.
# For your custom properties (Lead Source, Sales Rep, Closed Lost Reason),
# confirm the internal name in HubSpot: Settings > Properties > click the
# property > it shows the internal name under the label. Then add them here.
PROPERTIES = [
    "dealname", "amount", "dealstage", "pipeline",
    "closedate", "createdate",
    # "lead_source", "sales_rep", "closed_lost_reason",   # <- uncomment once you confirm the internal names
]
# ----------------------------------------------------------------------------


def fetch_all_deals():
    """Page through every deal in HubSpot and return them as a list of dicts."""
    url = "https://api.hubapi.com/crm/v3/objects/deals"
    headers = {"Authorization": f"Bearer {HUBSPOT_TOKEN}"}
    params = {"limit": 100, "properties": ",".join(PROPERTIES)}
    deals, after = [], None
    while True:
        if after:
            params["after"] = after
        resp = requests.get(url, headers=headers, params=params, timeout=30)
        resp.raise_for_status()
        data = resp.json()
        deals.extend(data.get("results", []))
        paging = data.get("paging", {}).get("next")
        if not paging:
            break
        after = paging["after"]
    return deals


def upsert_deals(deals):
    """Create the target table if needed and upsert every deal into it."""
    conn = psycopg2.connect(**PG)
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS hubspot_deals (
            deal_id     VARCHAR(30) PRIMARY KEY,
            deal_name   TEXT,
            amount      NUMERIC(14,2),
            deal_stage  TEXT,
            pipeline    TEXT,
            close_date  DATE,
            create_date DATE,
            synced_at   TIMESTAMP DEFAULT now()
        );
    """)

    rows = []
    for d in deals:
        p = d.get("properties", {})
        amount = p.get("amount")
        rows.append((
            d.get("id"),
            p.get("dealname"),
            float(amount) if amount not in (None, "") else None,
            p.get("dealstage"),
            p.get("pipeline"),
            (p.get("closedate") or None) and p["closedate"][:10],
            (p.get("createdate") or None) and p["createdate"][:10],
        ))

    execute_values(cur, """
        INSERT INTO hubspot_deals
            (deal_id, deal_name, amount, deal_stage, pipeline, close_date, create_date)
        VALUES %s
        ON CONFLICT (deal_id) DO UPDATE SET
            deal_name   = EXCLUDED.deal_name,
            amount      = EXCLUDED.amount,
            deal_stage  = EXCLUDED.deal_stage,
            pipeline    = EXCLUDED.pipeline,
            close_date  = EXCLUDED.close_date,
            create_date = EXCLUDED.create_date,
            synced_at   = now();
    """, rows)

    conn.commit()
    count = len(rows)
    cur.close()
    conn.close()
    return count


if __name__ == "__main__":
    print("Fetching deals from HubSpot...")
    deals = fetch_all_deals()
    print(f"  pulled {len(deals)} deals")
    print("Writing to Postgres...")
    n = upsert_deals(deals)
    print(f"  upserted {n} rows into hubspot_deals. Sync complete.")
