CREATE OR REPLACE TABLE dwh.inventory_doc AS
WITH 
inventory_by_location AS (
    SELECT
    i.location_id
    , sku
    , SPLIT(cat_tree,'>>')[SAFE_OFFSET(0)] cat1
    , SPLIT(cat_tree,'>>')[SAFE_OFFSET(1)] cat2
    , SPLIT(cat_tree,'>>')[SAFE_OFFSET(2)] cat3
    , d.location
    , d.inventory_level2
    , d.inventory_level3
    , SUM(stock_qty) stock_qty
    , SUM(stock_value) stock_value
    FROM `dwh.inventory_by_location` i
    LEFT JOIN dwh.dim_location d ON i.location_id = d.id
    WHERE 1 = 1
    AND date = DATE_SUB(CURRENT_DATE('+7'), INTERVAL 0 DAY)
    GROUP BY 1,2,3,4,5,6,7,8
)
,

gross_profit_30day AS (
    SELECT
    location_id
    , sku
    , SUM(qty) qty
    , SUM(total_profit) total_profit
    FROM `dtgk-262108.dwh.gross_profit`
    WHERE 1 = 1
    AND date >= DATE_SUB(CURRENT_DATE('+7'), INTERVAL 30 DAY)
    GROUP BY 1,2
)
,

gross_profit_14day AS (
    SELECT
    location_id
    , sku
    , SUM(qty) qty
    , SUM(total_profit) total_profit
    FROM `dtgk-262108.dwh.gross_profit`
    WHERE 1 = 1
    AND date >= DATE_SUB(CURRENT_DATE('+7'), INTERVAL 14 DAY)
    GROUP BY 1,2   
)



    SELECT
    i.location_id
    , i.location
    , i.inventory_level2
    , i.inventory_level3
    , cat1
    , cat2
    , cat3
    , i.sku
    , stock_qty
    , stock_value
    , p.qty item_sold_14day
    , SAFE_DIVIDE(stock_qty, p.qty/14) doc_qty_14day
    , SAFE_DIVIDE(stock_value, p.total_profit/14) doc_profit_14day
    , p2.qty item_sold_30day
    , SAFE_DIVIDE(stock_qty, p2.qty/30) doc_qty_30day
    , SAFE_DIVIDE(stock_value, p2.total_profit/30) doc_profit_30day
    FROM inventory_by_location i
    LEFT JOIN gross_profit_14day p ON i.location_id = p.location_id
                                  AND i.sku = p.sku
    LEFT JOIN gross_profit_30day p2 ON i.location_id = p2.location_id
                                   AND i.sku = p2.sku

                           
                            
    WHERE 1 = 1 
    AND i.location_id IS NOT NULL
  