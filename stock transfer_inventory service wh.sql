#Stock_Transfer

CREATE OR REPLACE EXTERNAL TABLE staging.stock_transfer
    (
    transfer_id  STRING
    , receipt_type  STRING
    , from_branch  STRING
    , to_branch  STRING
    , transfer_date  STRING
    , created_at  STRING
    , receive_date  STRING
    , creator  STRING
    , transfer_note STRING
    , receive_note  STRING
    , transfer_qty  STRING
    , transfer_amount  STRING
    , receive_qty  STRING
    , receive_amount  STRING
    , sku_qty  STRING
    , status  STRING
    , sku  STRING
    , barcode  STRING
    , unit  STRING
    , transfer_imei  STRING
    , receive_imei  STRING
    , product_name  STRING
    , brand  STRING
    , product_note  STRING
    , col25  STRING
    , col26  STRING
    , col27  STRING
    , col28  STRING
    , col29  STRING

    )
    OPTIONS (
    FORMAT = 'CSV',
    uris = ['gs://supply_chain_data_gk/dwh/stock_transfer/DanhSachChiTietChuyenHang_*.csv'],
allow_quoted_newlines = TRUE,
    skip_leading_rows = 1
    )
;

CREATE OR REPLACE TABLE dwh.stock_transfer AS 
    SELECT 
    transfer_id
    , receipt_type
    , from_branch
    , to_branch
    , PARSE_DATETIME('%d/%m/%Y %H:%M:%S', created_at) created_at
    , PARSE_DATETIME('%d/%m/%Y %H:%M:%S', transfer_date) transfer_date
    , PARSE_DATETIME('%d/%m/%Y %H:%M:%S', receive_date) receive_date
    , creator
    , transfer_note
    , receive_note
    , status
    , sku
    , barcode
    , unit
    , transfer_imei
    , receive_imei
    , product_name
    , brand
    , SUM(IFNULL(SAFE_CAST(REPLACE(transfer_qty,',','') AS FLOAT64),0)) transfer_qty
    , SUM(IFNULL(SAFE_CAST(REPLACE(transfer_amount,',','') AS FLOAT64),0)) transfer_amount
    , SUM(IFNULL(SAFE_CAST(REPLACE(receive_qty,',','') AS FLOAT64),0)) receive_qty
    , SUM(IFNULL(SAFE_CAST(REPLACE(receive_amount,',','') AS FLOAT64),0)) receive_amount
    , SUM(IFNULL(SAFE_CAST(REPLACE(sku_qty,',','') AS FLOAT64),0)) sku_qty

    FROM staging.stock_transfer t
    LEFT JOIN UNNEST(SPLIT(receive_imei,';')) receive_imei
    WHERE 1 = 1
    AND to_branch = 'Kho Dịch Vụ Sửa Chữa'
    AND status = 'Đã nhận'
    GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
;

#Inventory_servicewh
CREATE OR REPLACE EXTERNAL TABLE staging.inventory_servicewh
    (
    product_type  STRING
    , cat_tree  STRING
    , sku  STRING
    , barcode  STRING
    , product_name  STRING
    , brand  STRING
    , selling_price  STRING
    , cogs  STRING
    , instock  STRING
    , supplier_order  STRING
    , customer_order  STRING
    , out_of_stock_est  STRING
    , min_stock  STRING
    , max_stock  STRING
    , unit  STRING
    , unit_id  STRING
    , col17  STRING
    , col18  STRING
    , col19  STRING
    , col20  STRING
    , col21  STRING
    , col22  STRING
    , imei  STRING
    , col24  STRING
    , col25  STRING
    , col26  STRING
    , col27  STRING
    , col28  STRING
    , col29  STRING
    , col30  STRING
    , col31  STRING


    )
    OPTIONS (
    FORMAT = 'CSV',
    uris = ['gs://supply_chain_data_gk/dwh/inventory_servicewh/DanhSachSanPham_*.csv'],
allow_quoted_newlines = TRUE,
    skip_leading_rows = 1
    )
;

CREATE OR REPLACE TABLE dwh.inventory_servicewh AS 
    SELECT 
    product_type  
    , cat_tree  
    , sku  
    , barcode  
    , product_name  
    , brand  
    , imei
    , SUM(IFNULL(SAFE_CAST(REPLACE(selling_price,',','') AS FLOAT64),0)) selling_price  
    , SUM(IFNULL(SAFE_CAST(REPLACE(cogs,',','') AS FLOAT64),0)) cogs  
    , SUM(IFNULL(SAFE_CAST(REPLACE(instock,',','') AS FLOAT64),0)) instock
    , SUM(IFNULL(SAFE_CAST(REPLACE(supplier_order,',','') AS FLOAT64),0)) supplier_order  
    , SUM(IFNULL(SAFE_CAST(REPLACE(customer_order,',','') AS FLOAT64),0)) customer_order
    , SUM(IFNULL(SAFE_CAST(REPLACE(min_stock,',','') AS FLOAT64),0)) min_stock
    , SUM(IFNULL(SAFE_CAST(REPLACE(max_stock,',','') AS FLOAT64),0)) max_stock

    FROM staging.inventory_servicewh i
    LEFT JOIN UNNEST(SPLIT(imei,'|')) imei
    GROUP BY 1,2,3,4,5,6,7
;
