CREATE OR REPLACE TABLE dwh.dim_product AS
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
, IF(SPLIT(REGEXP_REPLACE(cat_tree, r'[^\d]+',','),',')[SAFE_OFFSET(0)] = '600000-Phụ kiện',1,0) is_pk
, IF(SUBSTR(sku,0,2) = 'BH', 1, 0) is_bh
FROM dwh.product