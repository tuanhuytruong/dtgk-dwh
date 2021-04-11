CREATE OR REPLACE TABLE dwh.aging_121online AS
SELECT
i.cat_tree
, i.sku
, i.product_name
, i.brand
, i.imei
, i.selling_price
, i.cogs
, i.instock
, p.supplier_id
, p.note
, p.inbound_price
, p.qty inbound_qty
, p.amount inbound_amount
, CASE 
  WHEN DATE_DIFF(CURRENT_DATE('+7'), DATE(created_at), DAY) > 60 THEN '> 60'
  WHEN DATE_DIFF(CURRENT_DATE('+7'), DATE(created_at), DAY) > 45 THEN '> 45'
  WHEN DATE_DIFF(CURRENT_DATE('+7'), DATE(created_at), DAY) > 30 THEN '> 30'
  WHEN DATE_DIFF(CURRENT_DATE('+7'), DATE(created_at), DAY) > 15 THEN '> 15'
  WHEN DATE_DIFF(CURRENT_DATE('+7'), DATE(created_at), DAY) > 7 THEN '> 7'
  ELSE '<= 7'
  END aging_day

FROM dwh.inventory_121online i
LEFT JOIN dwh.purchased p ON i.sku = p.sku