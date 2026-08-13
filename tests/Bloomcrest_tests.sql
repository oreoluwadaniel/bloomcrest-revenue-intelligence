-- =====================================================================
-- Bloomcrest Revenue Intelligence | Data validation test

-- =====================================================================
SELECT check, violations,
       CASE WHEN violations = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM (
  -- Referential integrity: no orphan child rows
  SELECT 'contacts -> companies' AS check,
         (SELECT COUNT(*) FROM contacts c LEFT JOIN companies p ON c.company_id=p.company_id WHERE p.company_id IS NULL) AS violations
  UNION ALL SELECT 'deals -> companies',
         (SELECT COUNT(*) FROM deals d LEFT JOIN companies p ON d.company_id=p.company_id WHERE p.company_id IS NULL)
  UNION ALL SELECT 'order_items -> orders',
         (SELECT COUNT(*) FROM order_items i LEFT JOIN orders o ON i.order_id=o.order_id WHERE o.order_id IS NULL)
  UNION ALL SELECT 'order_items -> products',
         (SELECT COUNT(*) FROM order_items i LEFT JOIN products p ON i.product_id=p.product_id WHERE p.product_id IS NULL)
  UNION ALL SELECT 'orders -> customers',
         (SELECT COUNT(*) FROM orders o LEFT JOIN customers c ON o.customer_id=c.customer_id WHERE c.customer_id IS NULL)
  UNION ALL SELECT 'activities -> deals',
         (SELECT COUNT(*) FROM activities a LEFT JOIN deals d ON a.deal_id=d.deal_id WHERE d.deal_id IS NULL)

  -- Uniqueness of primary keys
  UNION ALL SELECT 'unique deal_id',     (SELECT COUNT(*)-COUNT(DISTINCT deal_id) FROM deals)
  UNION ALL SELECT 'unique order_id',    (SELECT COUNT(*)-COUNT(DISTINCT order_id) FROM orders)
  UNION ALL SELECT 'unique customer_id', (SELECT COUNT(*)-COUNT(DISTINCT customer_id) FROM customers)

  -- Value ranges
  UNION ALL SELECT 'deal amount >= 0',       (SELECT COUNT(*) FROM deals WHERE amount < 0 OR amount IS NULL)
  UNION ALL SELECT 'win_probability in 0..1',(SELECT COUNT(*) FROM deal_stages WHERE win_probability < 0 OR win_probability > 1)
  UNION ALL SELECT 'order_item quantity > 0',(SELECT COUNT(*) FROM order_items WHERE quantity <= 0)

  -- Business rules on deals
  UNION ALL SELECT 'Won deals have no loss reason',  (SELECT COUNT(*) FROM deals WHERE status='Won'  AND reason_id IS NOT NULL)
  UNION ALL SELECT 'Lost deals have a loss reason',  (SELECT COUNT(*) FROM deals WHERE status='Lost' AND reason_id IS NULL)
  UNION ALL SELECT 'Open deals have no loss reason', (SELECT COUNT(*) FROM deals WHERE status='Open' AND reason_id IS NOT NULL)
  UNION ALL SELECT 'closed deals have a close date', (SELECT COUNT(*) FROM deals WHERE status IN ('Won','Lost') AND actual_close IS NULL)
  UNION ALL SELECT 'open deals have no close date',  (SELECT COUNT(*) FROM deals WHERE status='Open' AND actual_close IS NOT NULL)
  UNION ALL SELECT 'stage matches status (Won)',     (SELECT COUNT(*) FROM deals WHERE status='Won'  AND stage_id <> 'STG-06')
  UNION ALL SELECT 'stage matches status (Lost)',    (SELECT COUNT(*) FROM deals WHERE status='Lost' AND stage_id <> 'STG-07')

  -- Cross-table business rules
  UNION ALL SELECT 'no payments on cancelled/returned orders',
         (SELECT COUNT(*) FROM payments p JOIN orders o ON p.order_id=o.order_id WHERE o.status IN ('Cancelled','Returned'))
  UNION ALL SELECT 'order_date not before customer first order',
         (SELECT COUNT(*) FROM orders o JOIN customers c ON o.customer_id=c.customer_id WHERE o.order_date < c.first_order_date)

  -- Reconciliation
  UNION ALL SELECT 'order total = sum of line items',
         (SELECT COUNT(*) FROM (SELECT o.order_id, o.total_amount, SUM(i.line_total) s
                                FROM orders o JOIN order_items i ON o.order_id=i.order_id
                                GROUP BY o.order_id, o.total_amount) t WHERE ABS(total_amount - s) > 0.5)
  UNION ALL SELECT 'deal count equals HubSpot import (360)',
         (SELECT CASE WHEN COUNT(*)=360 THEN 0 ELSE 1 END FROM deals)
) t
ORDER BY violations DESC, check;
