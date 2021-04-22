CREATE OR REPLACE TABLE dwh.net_sale_by_invoice AS

WITH order_metric AS (
SELECT 
    i.branch
    , i.transaction_id
    , DATE(i.created_at) created_at
    , STRING_AGG(DISTINCT rd.return_id, ',')  return_id
    , i.customer_id
    , i.customer_name
    , i.staff_name
    , IFNULL(r.buy_transaction_id,i.transaction_id) transaction_id_relink
    , IFNULL(r.buy_staff_name,i.staff_name) staff_name_relink
    , IFNULL(r.buy_date,i.created_at) created_at_relink
    , SUM(i.qty) sell_qty
    , SUM(i.amount) sell_amount
    , SUM(IF(is_pk = 1, 0, i.amount)) sell_exc_pk
    , SUM(rd.qty) return_qty
    , SUM(rd.return_price * rd.qty) return_amount
    , SUM(IFNULL(i.qty,0) - IFNULL(rd.qty,0)) qty_edit
    , SUM(IFNULL(i.amount,0) - IFNULL(rd.return_price * rd.qty,0)) amount_edit
    , SUM(dp.is_pk) order_pk
    , SUM(dp.is_bh) order_bh
    , SUM(dp.is_delivery) order_delivery
FROM dwh.invoice_detail i
LEFT JOIN dwh.return_detail rd ON i.transaction_id = rd.transaction_id
                             AND i.sku = rd.sku
LEFT JOIN dwh.rma r ON i.transaction_id = r.return_transaction_id
                   AND i.sku = r.sku
LEFT JOIN dwh.dim_product dp ON i.sku = dp.sku
GROUP BY 1,2,3,5,6,7,8,9,10
)

SELECT
      branch
    , transaction_id
    , created_at
    , return_id
    , customer_id
    , customer_name
    , staff_name
    , transaction_id_relink
    , staff_name_relink
    , created_at_relink
    , sell_qty
    , sell_amount
    , return_qty
    , return_amount
    , qty_edit
    , amount_edit
    , IF(order_pk > 0, 1, 0) is_order_include_pk
    , IF(sell_exc_pk > 3000000, 1, 0) is_over_3m_exc_pk
    , IF(sell_amount > 3000000, 1, 0) is_over_3m_inc_pk
    , order_pk
    , order_bh
    , order_delivery
FROM order_metric
WHERE 1 = 1

