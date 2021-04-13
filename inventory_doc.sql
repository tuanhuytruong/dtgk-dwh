CREATE OR REPLACE TABLE dwh.inventory_doc AS
WITH 
inventory_by_location_pre AS (
    SELECT
    sku
    ,'all_location' inventory_level0
    , i.location
    , d.inventory_level2
    , d.inventory_level3
    , SUM(stock_qty) stock_qty
    , SUM(stock_value) stock_value
    FROM `dwh.inventory_by_location` i
    LEFT JOIN dwh.dim_location d ON i.location_id = d.id
    WHERE 1 = 1
    AND date = DATE_SUB(CURRENT_DATE('+7'), INTERVAL 0 DAY)
    GROUP BY ROLLUP (1,2,3,4,5) 
)
,

inventory_by_location AS (
    SELECT
    0 level
    , inventory_level0 inventory_level
    , sku
    , stock_qty
    , stock_value
    FROM inventory_by_location_pre i
    WHERE 1 = 1
    AND location IS NULL
    AND inventory_level2 IS NULL
    AND inventory_level3 IS NULL

    UNION ALL
    SELECT
    1
    , location
    , sku
    , stock_qty
    , stock_value
    FROM inventory_by_location_pre i
    WHERE 1 = 1
    AND inventory_level2 IS NULL
    AND inventory_level3 IS NULL

    UNION ALL
    SELECT
    2
    , inventory_level2
    , sku
    , stock_qty
    , stock_value
    FROM inventory_by_location_pre i
    WHERE 1 = 1
    AND inventory_level3 IS NULL

    UNION ALL
    SELECT
    3
    , inventory_level3
    , sku
    , stock_qty
    , stock_value
    FROM inventory_by_location_pre i
    WHERE 1 = 1
  
)
,

gross_profit_pre AS (
    SELECT
    sku
    , 'all_location' inventory_level0
    , location
    , inventory_level2
    , inventory_level3
    , SUM(qty) qty
    , SUM(total_profit) total_profit
    FROM `dtgk-262108.dwh.gross_profit`
    WHERE 1 = 1
    AND date >= DATE_SUB(CURRENT_DATE('+7'), INTERVAL 30 DAY)
    GROUP BY ROLLUP (1,2,3,4,5)
)
,

gross_profit AS (
    SELECT
    0 level
    , inventory_level0 inventory_level
    , sku
    , qty
    , total_profit
    FROM gross_profit_pre g
    WHERE 1 = 1
    AND location IS NULL
    AND inventory_level2 IS NULL
    AND inventory_level3 IS NULL

    UNION ALL
    SELECT
    1
    , location
    , sku
    , qty
    , total_profit
    FROM gross_profit_pre g
    WHERE 1 = 1
    AND inventory_level2 IS NULL
    AND inventory_level3 IS NULL

    UNION ALL
    SELECT
    2
    , inventory_level2
    , sku
    , qty
    , total_profit
    FROM gross_profit_pre g
    WHERE 1 = 1
    AND inventory_level3 IS NULL

    UNION ALL
    SELECT
    3
    , inventory_level3
    , sku
    , qty
    , total_profit
    FROM gross_profit_pre g
    WHERE 1 = 1
    # AND inventory_level3 IS NULL
)

    SELECT
    i.level
    , i.inventory_level
    , i.sku
    , stock_qty
    , stock_value
    , SAFE_DIVIDE(stock_qty, qty) doc_qty
    , SAFE_DIVIDE(stock_value, total_profit) doc_profit
    FROM inventory_by_location i
    LEFT JOIN gross_profit p ON i.level = p.level
                            AND i.sku = p.sku
                            AND i.inventory_level = p.inventory_level
                            
    WHERE 1 = 1 
    AND i.sku IS NOT NULL
    AND i.level IS NOT NULL
    AND i.inventory_level  IS NOT NULL
    