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
    , IFNULL(DATE(r.buy_date),DATE(i.created_at)) created_at_relink
    , hd.department
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
LEFT JOIN dwh.hr_department hd ON IFNULL(r.buy_staff_name,i.staff_name) = hd.staff_name
                              AND IFNULL(DATE(r.buy_date),DATE(i.created_at)) >= hd.from_date
                              AND IFNULL(DATE(r.buy_date),DATE(i.created_at)) < hd.to_date
GROUP BY 1,2,3,5,6,7,8,9,10,11
)

SELECT
      
      STRING_AGG(DISTINCT transaction_id, ',')  transaction_id
    # , created_at
    , STRING_AGG(DISTINCT return_id, ',')  return_id
    , branch
    , customer_id
    , customer_name
    , staff_name
    , transaction_id_relink
    , staff_name_relink
    , created_at_relink
    , SUM(IF(transaction_id != transaction_id_relink, 0 ,sell_qty)) sell_qty
    , SUM(IF(transaction_id != transaction_id_relink, 0 ,sell_amount)) sell_amount
    , SUM(IF(transaction_id != transaction_id_relink, 0 ,return_qty)) return_qty
    , SUM(IF(transaction_id != transaction_id_relink, 0 ,return_amount)) return_amount
    , SUM(IF(transaction_id != transaction_id_relink, 0 ,qty_edit)) qty_edit
    , SUM(IF(transaction_id != transaction_id_relink, 0 ,amount_edit)) amount_edit
    , SUM(IF(transaction_id != transaction_id_relink, 0, IF(order_pk > 0, 1, 0))) is_order_include_pk
    , SUM(IF(transaction_id != transaction_id_relink, 0, IF(sell_exc_pk > 3000000, 1, 0))) is_over_3m_exc_pk
    , SUM(IF(transaction_id != transaction_id_relink, 0, IF(sell_amount > 3000000, 1, 0))) is_over_3m_inc_pk
    , SUM(IF(transaction_id != transaction_id_relink, 0 ,order_pk))order_pk
    , SUM(IF(transaction_id != transaction_id_relink, 0 ,order_bh))order_bh 
    , SUM(IF(transaction_id != transaction_id_relink, 0 ,order_delivery)) order_delivery
    , department
FROM order_metric
WHERE 1 = 1
GROUP BY 3,4,5,6,7,8,9,22

