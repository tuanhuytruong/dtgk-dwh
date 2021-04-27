CREATE OR REPLACE TABLE dwh.dim_product AS 

WITH data AS (

SELECT
sku
, product_name
, brand
, type
, cat_tree
, SPLIT(cat_tree,'>>')[SAFE_OFFSET(0)] cat1
, SPLIT(cat_tree,'>>')[SAFE_OFFSET(1)] cat2
, SPLIT(cat_tree,'>>')[SAFE_OFFSET(2)] cat3
, SPLIT(REGEXP_REPLACE(cat_tree, r'[^\d]+',','),',')[SAFE_OFFSET(0)] cat1_id
, SPLIT(REGEXP_REPLACE(cat_tree, r'[^\d]+',','),',')[SAFE_OFFSET(1)] cat2_id
, SPLIT(REGEXP_REPLACE(cat_tree, r'[^\d]+',','),',')[SAFE_OFFSET(2)] cat3_id
, IF(cat_tree LIKE '600000-Phụ kiện%', 
        CONCAT(SUBSTR(SPLIT(REGEXP_REPLACE(cat_tree, r'[^\d]+',','),',')[SAFE_OFFSET(2)], -3,1), '00000')
        , NULL) cat1_pk_id
, IF(SPLIT(REGEXP_REPLACE(cat_tree, r'[^\d]+',','),',')[SAFE_OFFSET(0)] = '600000',1,0) is_pk
, IF(SUBSTR(sku,0,2) = 'BH', 1, 0) is_bh
, IF(product_name LIKE '%iao hàng%', 1, 0) is_delivery
, IF(SPLIT(REGEXP_REPLACE(cat_tree, r'[^\d]+',','),',')[SAFE_OFFSET(0)] = '800000',1,0) is_amthanh

FROM dwh.product
WHERE 1 = 1
)

SELECT 
d.sku
, d.product_name
, d.brand
, d.type
, d.cat_tree
, d.cat1
, d.cat2
, d.cat3
, d.cat1_id
, d.cat2_id
, d.cat3_id
, CASE WHEN cat1_pk_id < '100000' OR cat1_pk_id >= '600000' THEN NULL ELSE cat1_pk_id END cat1_pk_id
, d.is_pk
, d.is_bh
, d.is_delivery
, d.is_amthanh
FROM data d