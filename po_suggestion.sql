DECLARE sale_day INT64 DEFAULT 7;
DECLARE phone_min_stock INT64 DEFAULT 2;
DECLARE airpod_min_stock INT64 DEFAULT 5;
DECLARE phone_priority INT64 DEFAULT 9;
DECLARE airpod_priority INT64 DEFAULT 15;

CREATE OR REPLACE TABLE dwh.po_suggestion AS
WITH 
inventory_by_location AS (
    SELECT
    i.location_id
    , sku
    , SPLIT(cat_tree,'>>')[SAFE_OFFSET(0)] cat1
    , SPLIT(cat_tree,'>>')[SAFE_OFFSET(1)] cat2
    , SPLIT(cat_tree,'>>')[SAFE_OFFSET(2)] cat3
    , d.location
    , inventory_level2
    , inventory_level3
    , CASE WHEN SPLIT(cat_tree,'>>')[SAFE_OFFSET(0)] = '500000-Headphone' 
        THEN airpod_priority ELSE phone_priority 
        END product_priority
    , CASE WHEN SPLIT(cat_tree,'>>')[SAFE_OFFSET(0)] = '500000-Headphone' 
        THEN airpod_min_stock ELSE phone_min_stock
        END min_stock
    , SUM(stock_qty) stock_qty
     FROM `dwh.inventory_by_location` i
    LEFT JOIN dwh.dim_location d ON i.location_id = d.id
    WHERE 1 = 1
    AND date = DATE_SUB(CURRENT_DATE('+7'), INTERVAL 1 DAY)
    GROUP BY 1,2,3,4,5,6,7,8,9,10
)
,

demand AS (
    SELECT
    location_id
    , sku
    , SUM(qty) qty
    FROM `dtgk-262108.dwh.gross_profit`
    WHERE 1 = 1
    AND date >= DATE_SUB(CURRENT_DATE('+7'), INTERVAL sale_day DAY)
    GROUP BY 1,2
)

    SELECT
    i.location_id
    , i.location
    , i.cat1
    , i.cat2
    , i.cat3
    , i.sku
    , i.stock_qty
    , i.min_stock
    , d.qty demand_qty
    , CASE WHEN i.stock_qty < GREATEST(IFNULL(i.min_stock,0), IFNULL(d.qty,0)) THEN 'under_demand'
           WHEN i.stock_qty > GREATEST(IFNULL(i.min_stock,0), IFNULL(d.qty,0)) THEN 'over_demand'
           ELSE 'meet_demand'
           END stock_status
    , GREATEST(IFNULL(i.min_stock,0), IFNULL(d.qty,0)) - i.stock_qty fulfill_qty
    
    FROM inventory_by_location i
    LEFT JOIN demand d ON i.location_id = d.location_id 
    AND i.sku = d.sku
    WHERE 1 = 1
    AND i.location_id IS NOT NULL
 
  