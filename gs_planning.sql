WITH 
gs_planning AS (
    SELECT
    metric
    , level1 cat_level
    , level2 category
    , time_type
    , time_value 
    , unit
    , value
    FROM staging.gs_planning
)
,

gross_profit_pre AS (
    SELECT
    FORMAT_DATE('%Y%m', date) month
    , cat1
    , cat2
    , cat3
    , SUM(qty) qty
    , SUM(total_revenue) revenue
    , SAFE_DIVIDE(SUM(total_profit),SUM(total_revenue)) * 100 gm
    , SAFE_DIVIDE(SUM(total_revenue),SUM(qty)) asp
    FROM `dtgk-262108.dwh.gross_profit`
    WHERE 1 = 1
    AND date >= DATE_SUB(DATE_TRUNC(CURRENT_DATE('+7'), MONTH), INTERVAL 1 MONTH)
    GROUP BY ROLLUP (1,2,3,4)
)
,

gross_profit AS (
    SELECT
    month
    , 'cat1' cat_level
    , cat1 category
    , qty
    , revenue
    , gm
    , asp
    FROM gross_profit_pre 
    WHERE 1 = 1
    AND cat2 IS NULL
    AND cat3 IS NULL
    AND cat1 IS NOT NULL

    UNION ALL
    SELECT
    month
    , 'cat2' cat_level
    , cat2 
    , qty
    , revenue
    , gm
    , asp
    FROM gross_profit_pre 
    WHERE 1 = 1
    AND cat3 IS NULL 
    AND cat2 IS NOT NULL

    UNION ALL
    SELECT
    month
    , 'cat3' cat_level
    , cat3
    , qty
    , revenue
    , gm
    , asp
    FROM gross_profit_pre 
    WHERE 1 = 1
    AND cat3 IS NOT NULL 
 )

    SELECT
    p.metric
    , p.time_value
    , p.cat_level
    , p.category
    , SUM(
            CASE 
                WHEN g.month < p.time_value 
                THEN qty
                ELSE NULL 
            END
        ) last_month
    , SUM(
            CASE 
            WHEN g.month = p.time_value 
            THEN p.value
            ELSE NULL 
            END 
        ) plan_this_month
    , SUM(
            CASE 
            WHEN g.month = p.time_value 
            THEN qty 
            ELSE NULL 
            END 
        ) actual
    , SUM(
            CASE 
            WHEN g.month = p.time_value  
            THEN SAFE_DIVIDE(qty,value )
            ELSE NULL 
            END 
        ) target_reach
    , SAFE_DIVIDE(
                    SUM(
                    CASE 
                    WHEN g.month = p.time_value 
                    THEN qty
                    ELSE NULL 
                    END 
                        ),
                    EXTRACT(DAY FROM CURRENT_DATE('+7'))
                ) * EXTRACT(DAY FROM LAST_DAY(CURRENT_DATE('+7'))
        )  by_run_rate
    , SAFE_DIVIDE(
                    SAFE_DIVIDE(
                                    SUM(
                                    CASE 
                                    WHEN g.month = p.time_value 
                                    THEN qty
                                    ELSE NULL 
                                    END 
                                        ),
                                    EXTRACT(DAY FROM CURRENT_DATE('+7'))
                                ) * EXTRACT(DAY FROM LAST_DAY(CURRENT_DATE('+7'))
                )
        , SUM(
            CASE 
            WHEN g.month < p.time_value 
            THEN qty
            ELSE NULL 
            END
            )
    ) mom


    FROM gs_planning p
    LEFT JOIN gross_profit g ON p.category = g.category
                            AND p.time_value >= g.month
    WHERE 1 = 1 
    AND p.metric = 'qty'                       
    GROUP BY 1,2,3,4

    UNION ALL

    SELECT
    p.metric
    , p.time_value
    , p.cat_level
    , p.category
    , SUM(
            CASE 
                WHEN g.month < p.time_value 
                THEN revenue
                ELSE NULL 
            END
        ) last_month
    , SUM(
            CASE 
            WHEN g.month = p.time_value 
            THEN p.value
            ELSE NULL 
            END 
        ) plan_this_month
    , SUM(
            CASE 
            WHEN g.month = p.time_value 
            THEN revenue 
            ELSE NULL 
            END 
        ) actual
    , SUM(
            CASE 
            WHEN g.month = p.time_value  
            THEN SAFE_DIVIDE(revenue,value )
            ELSE NULL 
            END 
        ) target_reach
    , SAFE_DIVIDE(
                    SUM(
                    CASE 
                    WHEN g.month = p.time_value 
                    THEN revenue
                    ELSE NULL 
                    END 
                        ),
                    EXTRACT(DAY FROM CURRENT_DATE('+7'))
                ) * EXTRACT(DAY FROM LAST_DAY(CURRENT_DATE('+7'))
        )  by_run_rate
    , SAFE_DIVIDE(
                    SAFE_DIVIDE(
                                    SUM(
                                    CASE 
                                    WHEN g.month = p.time_value 
                                    THEN revenue
                                    ELSE NULL 
                                    END 
                                        ),
                                    EXTRACT(DAY FROM CURRENT_DATE('+7'))
                                ) * EXTRACT(DAY FROM LAST_DAY(CURRENT_DATE('+7'))
                )
        , SUM(
            CASE 
            WHEN g.month < p.time_value 
            THEN revenue
            ELSE NULL 
            END
            )
    ) mom


    FROM gs_planning p
    LEFT JOIN gross_profit g ON p.category = g.category
                            AND p.time_value >= g.month               
    WHERE 1 = 1 
    AND p.metric = 'revenue' 
    GROUP BY 1,2,3,4

    UNION ALL

    SELECT
    p.metric
    , p.time_value
    , p.cat_level
    , p.category
    , SUM(
            CASE 
                WHEN g.month < p.time_value 
                THEN gm
                ELSE NULL 
            END
        ) last_month
    , SUM(
            CASE 
            WHEN g.month = p.time_value 
            THEN p.value
            ELSE NULL 
            END 
        ) plan_this_month
    , SUM(
            CASE 
            WHEN g.month = p.time_value 
            THEN gm 
            ELSE NULL 
            END 
        ) actual
    , SUM(
            CASE 
            WHEN g.month = p.time_value  
            THEN SAFE_DIVIDE(gm,value )
            ELSE NULL 
            END 
        ) target_reach
    , SAFE_DIVIDE(
                    SUM(
                    CASE 
                    WHEN g.month = p.time_value 
                    THEN gm
                    ELSE NULL 
                    END 
                        ),
                    EXTRACT(DAY FROM CURRENT_DATE('+7'))
                ) * EXTRACT(DAY FROM LAST_DAY(CURRENT_DATE('+7'))
        )  by_run_rate
    , SAFE_DIVIDE(
                    SAFE_DIVIDE(
                                    SUM(
                                    CASE 
                                    WHEN g.month = p.time_value 
                                    THEN gm
                                    ELSE NULL 
                                    END 
                                        ),
                                    EXTRACT(DAY FROM CURRENT_DATE('+7'))
                                ) * EXTRACT(DAY FROM LAST_DAY(CURRENT_DATE('+7'))
                )
        , SUM(
            CASE 
            WHEN g.month < p.time_value 
            THEN gm
            ELSE NULL 
            END
            )
    ) mom


    FROM gs_planning p
    LEFT JOIN gross_profit g ON p.category = g.category
                            AND p.time_value >= g.month
    WHERE 1 = 1
    AND p.metric = 'gm' 
    GROUP BY 1,2,3,4


    UNION ALL 
    SELECT
    p.metric
    , p.time_value
    , p.cat_level
    , p.category
    , SUM(
            CASE 
                WHEN g.month < p.time_value 
                THEN asp
                ELSE NULL 
            END
        ) last_month
    , SUM(
            CASE 
            WHEN g.month = p.time_value 
            THEN p.value
            ELSE NULL 
            END 
        ) plan_this_month
    , SUM(
            CASE 
            WHEN g.month = p.time_value 
            THEN asp 
            ELSE NULL 
            END 
        ) actual
    , SUM(
            CASE 
            WHEN g.month = p.time_value  
            THEN SAFE_DIVIDE(asp,value )
            ELSE NULL 
            END 
        ) target_reach
    , SAFE_DIVIDE(
                    SUM(
                    CASE 
                    WHEN g.month = p.time_value 
                    THEN asp
                    ELSE NULL 
                    END 
                        ),
                    EXTRACT(DAY FROM CURRENT_DATE('+7'))
                ) * EXTRACT(DAY FROM LAST_DAY(CURRENT_DATE('+7'))
        )  by_run_rate
    , SAFE_DIVIDE(
                    SAFE_DIVIDE(
                                    SUM(
                                    CASE 
                                    WHEN g.month = p.time_value 
                                    THEN asp
                                    ELSE NULL 
                                    END 
                                        ),
                                    EXTRACT(DAY FROM CURRENT_DATE('+7'))
                                ) * EXTRACT(DAY FROM LAST_DAY(CURRENT_DATE('+7'))
                )
        , SUM(
            CASE 
            WHEN g.month < p.time_value 
            THEN asp
            ELSE NULL 
            END
            )
    ) mom


    FROM gs_planning p
    LEFT JOIN gross_profit g ON p.category = g.category
                            AND p.time_value >= g.month
    WHERE 1 = 1
    AND p.metric = 'asp'                       
    GROUP BY 1,2,3,4

