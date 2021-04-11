#Purchased
CREATE OR REPLACE EXTERNAL TABLE staging.purchased
(
branch STRING
, inbound_id STRING
, created_at STRING
, col4 STRING
, col5 STRING
, col6 STRING
, supplier_id STRING
, supplier_name STRING
, phone_number STRING
, address STRING
, filler STRING
, creator STRING
, col13 STRING
, col14 STRING
, col15 STRING
, col16 STRING
, col17 STRING
, col18 STRING
, note STRING
, cok20 STRING
, sku_qty STRING
, status STRING
, sku STRING
, barcode STRING
, product_name STRING
, brand STRING
, unit STRING
, imei STRING
, product_note STRING
, unit_price STRING
, discount_percent STRING
, discount STRING
, inbound_price STRING
, amount STRING
, qty STRING
)
    OPTIONS (
    FORMAT = 'CSV',
    uris = ['gs://data_kiot/dwh/purchased/DanhSachChiTietNhapHang_*.csv'],
    allow_quoted_newlines = TRUE,
    skip_leading_rows = 1
    ) 

    ;
CREATE OR REPLACE TABLE dwh.purchased AS
SELECT
branch
, inbound_id
, PARSE_DATETIME('%d/%m/%Y %H:%M:%S', SUBSTRING(created_at,2)) created_at
, supplier_id
, supplier_name
, phone_number
, address
, filler
, creator
, note
, SUM(IFNULL(SAFE_CAST(REPLACE(cok20 ,',','') AS FLOAT64),0)) cok20
, SUM(IFNULL(SAFE_CAST(REPLACE(sku_qty ,',','') AS FLOAT64),0)) sku_qty
, status
, sku
, barcode
, product_name
, brand
, unit
, imei
, product_note
, SUM(IFNULL(SAFE_CAST(REPLACE(unit_price ,',','') AS FLOAT64),0)) unit_price
, SUM(IFNULL(SAFE_CAST(REPLACE(discount_percent ,',','') AS FLOAT64),0)) discount_percent
, SUM(IFNULL(SAFE_CAST(REPLACE(discount ,',','') AS FLOAT64),0)) discount
, SUM(IFNULL(SAFE_CAST(REPLACE(inbound_price ,',','') AS FLOAT64),0)) inbound_price
, SUM(IFNULL(SAFE_CAST(REPLACE(amount ,',','') AS FLOAT64),0)) amount
, SUM(IFNULL(SAFE_CAST(REPLACE(qty ,',','') AS FLOAT64),0)) qty
FROM staging.purchased
LEFT JOIN UNNEST(SPLIT(imei,';')) imei
WHERE 1 = 1
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 13, 14, 15, 16, 17, 18, 19, 20
;