#Return_detail
CREATE OR REPLACE EXTERNAL TABLE staging.return_detail
(
branch STRING
, return_id STRING
, col3 STRING
, created_at STRING
, transaction_id STRING
, sale_lading_code STRING
, staff_name STRING
, customer_id STRING
, customer_name STRING
, receiver STRING
, sale_channel STRING
, creator STRING
, note STRING
, grand_amount STRING
, discount STRING
, other_fee STRING
, return_fee STRING
, refund_amount STRING
, actual_refund_amount STRING
, col20 STRING
, col21 STRING
, col22 STRING
, col23 STRING
, status STRING
, sku STRING
, barcode STRING
, product_name STRING
, brand STRING
, unit STRING
, imei STRING
, product_note STRING
, qty STRING
, selling_price STRING
, return_price STRING
, col35 STRING
, col36 STRING
, col37 STRING
, col38 STRING
)
OPTIONS (
    FORMAT = 'CSV',
    uris = ['gs://operation_data_gk/return_detail/DanhSachChiTietTraHang_*.csv'],
    allow_quoted_newlines = TRUE,
    skip_leading_rows = 1
)
;
CREATE OR REPLACE TABLE dwh.return_detail AS
SELECT
branch
, return_id
, PARSE_DATETIME('%d/%m/%Y %H:%M:%S', SUBSTR(created_at ,2)) created_at
, transaction_id
, sale_lading_code
, staff_name
, customer_id
, customer_name
, receiver
, sale_channel
, creator
, note
, SUM(IFNULL(SAFE_CAST(REPLACE(grand_amount ,',','') AS FLOAT64),0)) grand_amount
, SUM(IFNULL(SAFE_CAST(REPLACE(discount ,',','') AS FLOAT64),0)) discount
, SUM(IFNULL(SAFE_CAST(REPLACE(other_fee ,',','') AS FLOAT64),0)) other_fee
, SUM(IFNULL(SAFE_CAST(REPLACE(return_fee ,',','') AS FLOAT64),0)) return_fee
, SUM(IFNULL(SAFE_CAST(REPLACE(refund_amount ,',','') AS FLOAT64),0)) refund_amount
, SUM(IFNULL(SAFE_CAST(REPLACE(actual_refund_amount ,',','') AS FLOAT64),0)) actual_refund_amount
, status
, SUBSTR(sku, 2) sku
, barcode
, product_name
, brand
, unit
, imei
, product_note
, SUM(IFNULL(SAFE_CAST(REPLACE(qty ,',','') AS FLOAT64),0)) qty
, SUM(IFNULL(SAFE_CAST(REPLACE(selling_price ,',','') AS FLOAT64),0)) selling_price
, SUM(IFNULL(SAFE_CAST(REPLACE(return_price ,',','') AS FLOAT64),0)) return_price
FROM staging.return_detail
WHERE 1 = 1
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 19, 20, 21, 22, 23, 24, 25, 26
;

#Invoice_detail
CREATE OR REPLACE EXTERNAL TABLE staging.invoice_detail
(
branch STRING
, transaction_id STRING
, lading_code STRING
, pickup_address STRING
, check_code STRING
, col6 STRING
, col7 STRING
, created_at STRING
, col9 STRING
, col10 STRING
, col11 STRING
, return_id STRING
, customer_id STRING
, customer_name STRING
, email STRING
, phone STRING
, address STRING
, col28 STRING
, col29 STRING
, col30 STRING
, staff_name STRING
, sale_channel STRING
, creator STRING
, col31 STRING
, col32 STRING
, col33 STRING
, col34 STRING
, col35 STRING
, col36 STRING
, col37 STRING
, col38 STRING
, col39 STRING
, col40 STRING
, col41 STRING
, col42 STRING
, note STRING
, grand_amount STRING
, invoice_discount STRING
, col49 STRING
, col50 STRING
, received_amount STRING
, col52 STRING
, col53 STRING
, col54 STRING
, col55 STRING
, col56 STRING
, col57 STRING
, col58 STRING
, col59 STRING
, status STRING
, col61 STRING
, sku STRING
, barcode STRING
, product_name STRING
, brand STRING
, unit STRING
, imei STRING
, product_note STRING
, qty STRING
, col70 STRING
, discount_percent STRING
, disocunt STRING
, selling_price STRING
, amount STRING
, col75 STRING
, col76 STRING
)
OPTIONS (
FORMAT = 'CSV',
    uris = ['gs://operation_data_gk/invoice_detail/DanhSachChiTietHoaDon_*.csv'],
allow_quoted_newlines = TRUE,
skip_leading_rows = 1
)
;
CREATE OR REPLACE TABLE dwh.invoice_detail AS
SELECT
branch
, transaction_id
, lading_code
, pickup_address
, check_code
, PARSE_DATETIME('%d/%m/%Y %H:%M:%S', SUBSTR(created_at ,2)) created_at
, return_id
, customer_id
, customer_name
, email
, phone
, address
, staff_name
, sale_channel
, creator
, note
, SUM(IFNULL(SAFE_CAST(REPLACE(grand_amount ,',','') AS FLOAT64),0)) grand_amount
, SUM(IFNULL(SAFE_CAST(REPLACE(invoice_discount ,',','') AS FLOAT64),0)) invoice_discount
, SUM(IFNULL(SAFE_CAST(REPLACE(received_amount ,',','') AS FLOAT64),0)) received_amount
, status
, SUBSTR(sku, 2) sku
, barcode
, product_name
, brand
, unit
, imei
, product_note
, SUM(IFNULL(SAFE_CAST(REPLACE(qty ,',','') AS FLOAT64),0)) qty
, SUM(IFNULL(SAFE_CAST(REPLACE(discount_percent ,',','') AS FLOAT64),0)) discount_percent
, SUM(IFNULL(SAFE_CAST(REPLACE(disocunt ,',','') AS FLOAT64),0)) disocunt
, SUM(IFNULL(SAFE_CAST(REPLACE(selling_price ,',','') AS FLOAT64),0)) selling_price
, SUM(IFNULL(SAFE_CAST(REPLACE(amount ,',','') AS FLOAT64),0)) amount
FROM staging.invoice_detail
WHERE 1 = 1
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 20, 21, 22, 23, 24, 25, 26, 27
;