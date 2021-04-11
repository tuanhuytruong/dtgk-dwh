CREATE OR REPLACE TABLE dwh.tracking_stock_servicewh AS (
WITH 
lastest_transfer_date AS (
SELECT
 i.cat_tree
, t.transfer_id
, i.product_name
, i.sku
, i.imei stock_imei
, t.receive_imei
, DATE(transfer_date) transfer_date
, lower(transfer_note) transfer_note
, transfer_qty
, ROW_NUMBER() OVER(PARTITION BY t.sku, t.receive_imei ORDER BY transfer_date DESC) rn
FROM  dwh.inventory_servicewh i
left JOIN dwh.stock_transfer t ON t.receive_imei = i.imei
WHERE 1 = 1
)

SELECT 
distinct 
cat_tree,
SPLIT(cat_tree,'>>')[SAFE_OFFSET(0)] cat1,
SPLIT(cat_tree,'>>')[SAFE_OFFSET(1)] cat2,
IFNULL(SPLIT(cat_tree,'>>')[SAFE_OFFSET(2)],SPLIT(cat_tree,'>>')[SAFE_OFFSET(1)]) cat3,
transfer_id,
product_name,
sku,
stock_imei,
receive_imei,
transfer_date,
transfer_note,
transfer_qty
FROM lastest_transfer_date
WHERE 1 = 1
AND rn = 1 
OR receive_imei IS NULL
)
