WITH ab_test AS (
    SELECT 'A' as variant, 2574 as visitors, 350 as clicks
    UNION ALL
    SELECT 'B', 2855, 375
),
stats AS (
    SELECT 
        variant,
        visitors,
        clicks,
        clicks::numeric / visitors as conversion_rate,
        SQRT(
            (clicks::numeric / visitors) * (1 - clicks::numeric / visitors) / visitors
        ) as se
    FROM ab_test
),
combined AS (
    SELECT 
        SUM(clicks)::numeric / SUM(visitors) as p_pooled
    FROM ab_test
),
z_calc AS (
    SELECT 
        a.variant,
        a.conversion_rate,
        (a.conversion_rate - b.conversion_rate) / 
        SQRT(
            c.p_pooled * (1 - c.p_pooled) * (1.0/a.visitors + 1.0/b.visitors)
        ) as z_score
    FROM stats a
    CROSS JOIN stats b
    CROSS JOIN combined c
    WHERE a.variant = 'A' AND b.variant = 'B'
)
SELECT 
    variant,
    ROUND(conversion_rate * 100, 2) as conversion_percent,
    ROUND(z_score, 4) as z_score,
    CASE 
        WHEN ABS(z_score) > 1.96 THEN 'Разница значима (p < 0.05)'
        ELSE 'Разница НЕ значима (p >= 0.05)'
    END as conclusion
FROM z_calc;