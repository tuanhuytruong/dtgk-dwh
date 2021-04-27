CREATE OR REPLACE TABLE dwh.net_sale_by_invoice_item AS

WITH 
return_detail AS (
SELECT 
  i.branch
, i.transaction_id
, DATE(i.created_at) created_at
, rd.return_id
, i.customer_id
, i.customer_name
, i.staff_name
, i.sku
, i.product_name
, i.qty sell_qty
, i.amount sell_amount
, IFNULL(rd.qty,0) return_qty
, IFNULL(rd.return_price * rd.qty,0) return_amount
, IFNULL(i.qty,0) - IFNULL(rd.qty,0) qty_edit
, IFNULL(i.amount,0) - IFNULL(rd.return_price * rd.qty,0) amount_edit
, i.note
, IFNULL(r.buy_transaction_id,i.transaction_id) transaction_id_relink
, IFNULL(r.buy_staff_name,i.staff_name) staff_name_relink
, IFNULL(DATE(r.buy_date),DATE(i.created_at)) created_at_relink
, dp.is_pk
, dp.is_bh
, dp.is_delivery
, IF(i.amount > 3000000, 1, 0) is_over_3m_line
, dp.cat1
, dp.cat2
, dp.cat3
, dp.brand
, hd.department
, dp.cat1_pk_id
FROM dwh.invoice_detail i
LEFT JOIN dwh.return_detail rd ON i.transaction_id = rd.transaction_id
                             AND i.sku = rd.sku
LEFT JOIN dwh.rma r ON i.transaction_id = r.return_transaction_id
                   AND i.sku = r.sku
LEFT JOIN dwh.dim_product dp ON i.sku = dp.sku
LEFT JOIN dwh.hr_department hd ON IFNULL(r.buy_staff_name,i.staff_name) = hd.staff_name
                              AND IFNULL(DATE(r.buy_date),DATE(i.created_at)) >= hd.from_date
                              AND IFNULL(DATE(r.buy_date),DATE(i.created_at)) < hd.to_date
)
,

pk_raw AS (
SELECT 
    r.* EXCEPT(is_pk, is_delivery)
    ,IF(r.is_pk = 0, 0, IF(amount_edit > 0,1,0)) is_pk
    ,IF(SUM(IF(r.is_pk  = 0, amount_edit, 0)) OVER (PARTITION BY transaction_id_relink) >3000000,1,0) is_amount_edit_exc_pk_over_3mil
    , l.location
    , l.id location_id
FROM return_detail r
LEFT JOIN dwh.dim_location l ON r.branch = l.branch

)
,

order_w_pk AS (
SELECT
transaction_id_relink,
CASE WHEN COUNTIF(is_pk = 1) = COUNT(sku) THEN 1 ELSE 0 END order_w_pk
FROM pk_raw p
GROUP BY 1
)

SELECT 
p.*
, CASE WHEN o.order_w_pk = 1 THEN p.is_pk ELSE 0 END pk_in_order
, CASE WHEN p.is_pk = 1 AND p.cat1_pk_id IS NULL THEN 'others' ELSE dp.cat1 END cat1_pk
FROM pk_raw p
LEFT JOIN order_w_pk o ON p.transaction_id_relink = o.transaction_id_relink
LEFT JOIN dwh.dim_product dp ON p.cat1_pk_id = dp.cat1_pk_id 
                            AND p.sku = dp.sku

