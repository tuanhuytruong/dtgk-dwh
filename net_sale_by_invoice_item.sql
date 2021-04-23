CREATE OR REPLACE TABLE dwh.net_sale_by_invoice_item AS

WITH final AS (
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

SELECT 
    f.* EXCEPT(is_pk, is_delivery)
    ,IF(is_pk = 0, 0, IF(amount_edit > 0,1,0)) is_pk
    ,IF(SUM(IF(is_pk  =0, amount_edit, 0)) OVER (PARTITION BY transaction_id_relink) >3000000,1,0) is_amount_edit_exc_pk_over_3mil
    , l.location
    , l.id location_id
FROM final f
LEFT JOIN dwh.dim_location l ON f.branch = l.branch
