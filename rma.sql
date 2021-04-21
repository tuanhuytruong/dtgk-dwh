CREATE OR REPLACE TABLE dwh.rma AS
SELECT 
 r.transaction_id buy_transaction_id
, i.transaction_id return_transaction_id
, r.return_id
, i2.staff_name buy_staff_name
, r.staff_name return_staff_name
, DATE(i2.created_at) buy_date
, DATE(i.created_at) return_date
, DATE_DIFF(DATE(i.created_at), DATE(i2.created_at), DAY ) num_return_day
, i2.branch buy_branch
, r.branch return_branch

, i.note 
FROM dwh.invoice_detail i
JOIN dwh.return_detail r ON i.note = r.note AND i.sku = r.sku
LEFT JOIN dwh.invoice_detail i2 ON r.transaction_id = i2.transaction_id AND r.sku = i2.sku
