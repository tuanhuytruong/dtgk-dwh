CREATE OR REPLACE TABLE dwh.gross_profit AS
SELECT
DATE(p.created_at) date
, FORMAT_DATE('%G%V', DATE(p.created_at)) week_num
, p.transaction_id
, p.barcode
, p.sku
, p.product_name
, p.brand
, p.qty
, p.selling_price
, p.sku_cogs
, p.sku_profit
, p.total_profit
, p.selling_price * p.qty total_product_value
, p.sku_cogs * p.qty total_cogs
, p.selling_price * p.qty - p.sku_cogs * p.qty - p.total_profit total_discount
, p.sku_cogs * p.qty + p.total_profit total_revenue
, l.business_type
, l.location
, l.inventory_level2
, l.inventory_level3

, CASE WHEN SUBSTRING(p.transaction_id,1,3) = 'HDD' THEN 2
       WHEN SUBSTRING(p.transaction_id,1,2) = 'HD' THEN 1
ELSE 3 END transaction_type
, pr.cat_tree
, SPLIT(cat_tree,'>>')[SAFE_OFFSET(0)] cat1
, SPLIT(cat_tree,'>>')[SAFE_OFFSET(1)] cat2
, SPLIT(cat_tree,'>>')[SAFE_OFFSET(2)] cat3
, SPLIT(REGEXP_REPLACE(cat_tree, r'[^\d]+',','),',')[SAFE_OFFSET(0)] cat1_id
, SPLIT(REGEXP_REPLACE(cat_tree, r'[^\d]+',','),',')[SAFE_OFFSET(1)] cat2_id
, SPLIT(REGEXP_REPLACE(cat_tree, r'[^\d]+',','),',')[SAFE_OFFSET(2)] cat3_id

FROM dwh.profit p
left JOIN dwh.product pr ON p.sku = pr.sku
LEFT JOIN dwh.invoice i ON p.transaction_id = i.transaction_id
LEFT JOIN dwh.return r ON p.transaction_id = r.return_id
LEFT JOIN dwh.dim_location l ON COALESCE(i.branch, r.branch) = l.branch