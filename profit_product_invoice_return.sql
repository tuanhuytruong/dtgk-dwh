# Return
CREATE OR REPLACE EXTERNAL TABLE staging.return
(
return_id  STRING
, transaction_id  STRING
, staff_name  STRING
, created_at  STRING
, customer_name  STRING
, branch  STRING
, grand_amount  STRING
, discount  STRING
, net_amount  STRING
, return_fee  STRING
, other_fee  STRING
, refund_amount  STRING
, actual_refund_amount  STRING
, status  STRING

)
OPTIONS (
FORMAT = 'CSV',
uris = ['gs://data_kiot/dwh/return/DanhSachTraHang_*.csv'],
allow_quoted_newlines = TRUE,
skip_leading_rows = 1
)
;

CREATE OR REPLACE TABLE dwh.return AS 
SELECT 
transaction_id
, return_id
, PARSE_DATETIME('%d/%m/%Y %H:%M:%S', SUBSTR(created_at,2,19)) created_at
, staff_name
, customer_name
, branch
, status
, SUM(IFNULL(SAFE_CAST(REPLACE(grand_amount,',','') AS FLOAT64),0)) grand_amount
, SUM(IFNULL(SAFE_CAST(REPLACE(discount,',','') AS FLOAT64),0)) discount
, SUM(IFNULL(SAFE_CAST(REPLACE(net_amount,',','') AS FLOAT64),0)) net_amount
, SUM(IFNULL(SAFE_CAST(REPLACE(return_fee,',','') AS FLOAT64),0)) return_fee
, SUM(IFNULL(SAFE_CAST(REPLACE(other_fee,',','') AS FLOAT64),0)) other_fee
, SUM(IFNULL(SAFE_CAST(REPLACE(refund_amount,',','') AS FLOAT64),0)) refund_amount
, SUM(IFNULL(SAFE_CAST(REPLACE(actual_refund_amount,',','') AS FLOAT64),0)) actual_refund_amount


FROM staging.return
GROUP BY 1,2,3,4,5,6,7
;

# Invoice
CREATE OR REPLACE EXTERNAL TABLE staging.invoice
(
transaction_id  STRING
, created_at  STRING
, return_id  STRING
, customer_name  STRING
, branch  STRING
, grand_amount  STRING
, discount  STRING
, net_amount  STRING
, received_amount  STRING
, status  STRING


)
OPTIONS (
FORMAT = 'CSV',
uris = ['gs://data_kiot/dwh/invoice/DanhSachHoaDon_*.csv'],
allow_quoted_newlines = TRUE,
skip_leading_rows = 1
)
;

CREATE OR REPLACE TABLE dwh.invoice AS 
SELECT 
transaction_id
, PARSE_DATETIME('%d/%m/%Y %H:%M:%S', SUBSTR(created_at,2,19)) created_at
, return_id
, customer_name
, branch
, status
, SUM(IFNULL(SAFE_CAST(REPLACE(grand_amount,',','') AS FLOAT64),0)) grand_amount
, SUM(IFNULL(SAFE_CAST(REPLACE(discount,',','') AS FLOAT64),0)) discount
, SUM(IFNULL(SAFE_CAST(REPLACE(net_amount,',','') AS FLOAT64),0)) net_amount
, SUM(IFNULL(SAFE_CAST(REPLACE(received_amount,',','') AS FLOAT64),0)) received_amount



FROM staging.invoice
GROUP BY 1,2,3,4,5,6
;

# Profit
CREATE OR REPLACE EXTERNAL TABLE staging.profit
(
date  STRING
, col2  STRING
, col3  STRING
, col4  STRING
, col5  STRING
, col6  STRING
, transaction_id  STRING
, created_at  STRING
, col9  STRING
, col10  STRING
, col11  STRING
, col12  STRING
, col13  STRING
, sku  STRING
, barcode  STRING
, product_name  STRING
, brand  STRING
, qty  STRING
, selling_price  STRING
, sku_cogs  STRING
, sku_profit  STRING
, total_profit  STRING

)
OPTIONS (
FORMAT = 'CSV',
uris = ['gs://data_kiot/dwh/profit/BaoCaoBanHangTheoLoiNhuan_*.csv'],
allow_quoted_newlines = TRUE,
skip_leading_rows = 1
)
;

CREATE OR REPLACE TABLE dwh.profit AS 
SELECT 
PARSE_DATETIME('%d/%m/%Y %H:%M:%S', SUBSTR(created_at,2,19)) created_at
, transaction_id
, SUBSTR(sku,2,length(sku)-1) sku
, barcode
, product_name
, brand
, SUM(IFNULL(SAFE_CAST(REPLACE(qty,',','') AS FLOAT64),0)) qty
, SUM(IFNULL(SAFE_CAST(REPLACE(selling_price,',','') AS FLOAT64),0)) selling_price
, SUM(IFNULL(SAFE_CAST(REPLACE(sku_cogs,',','') AS FLOAT64),0)) sku_cogs
, SUM(IFNULL(SAFE_CAST(REPLACE(sku_profit,',','') AS FLOAT64),0)) sku_profit
, SUM(IFNULL(SAFE_CAST(REPLACE(total_profit,',','') AS FLOAT64),0)) total_profit

FROM staging.profit
GROUP BY 1,2,3,4,5,6
;

# Product
CREATE OR REPLACE EXTERNAL TABLE staging.product 
(
sku STRING
, product_name STRING
, brand STRING
, cat_tree STRING
, type STRING

)
OPTIONS (
FORMAT = 'CSV',
uris = ['gs://data_kiot/dwh/product/product.csv'],
allow_quoted_newlines = TRUE,
skip_leading_rows = 1
)
;

CREATE OR REPLACE TABLE dwh.product AS 
SELECT 
*
FROM staging.product

;
