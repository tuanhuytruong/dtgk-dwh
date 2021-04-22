CREATE OR REPLACE TABLE dwh.net_sale_by_invoice_item AS
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
, r.buy_date created_at_relink
, dp.is_pk
, dp.is_bh
, dp.is_delivery
, IF(i.amount > 3000000, 1, 0) is_over_3m_line
, dp.cat1
, dp.cat2
, dp.cat3
, dp.brand
FROM dwh.invoice_detail i
LEFT JOIN dwh.return_detail rd ON i.transaction_id = rd.transaction_id
                             AND i.sku = rd.sku
LEFT JOIN dwh.rma r ON i.transaction_id = r.return_transaction_id
                   AND i.sku = r.sku
LEFT JOIN dwh.dim_product dp ON i.sku = dp.sku