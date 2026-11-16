
WITH first_purchase AS (
    SELECT 
        id_client,
        DATE_TRUNC('month', MIN(tran_time)) AS cohort_month
    FROM transact
    GROUP BY id_client
),
client_activity AS (
    SELECT DISTINCT
        id_client,
        DATE_TRUNC('month', tran_time) AS activity_month
    FROM transact
),
cohort_data AS (
	SELECT 
        fp.cohort_month,
        ca.id_client,
        (EXTRACT(YEAR FROM ca.activity_month) - EXTRACT(YEAR FROM fp.cohort_month)) * 12 +
        (EXTRACT(MONTH FROM ca.activity_month) - EXTRACT(MONTH FROM fp.cohort_month)) AS month_number
    FROM first_purchase fp
    JOIN client_activity ca ON fp.id_client = ca.id_client
),
cohort_size AS (
     SELECT 
        cohort_month,
        COUNT(DISTINCT id_client) AS total_users
    FROM first_purchase
    GROUP BY cohort_month
),
retention_counts AS (
    SELECT 
        cohort_month,
        month_number,
        COUNT(DISTINCT id_client) AS retained_users
    FROM cohort_data
    GROUP BY cohort_month, month_number
)

SELECT 
    rc.cohort_month,
    rc.month_number,
    rc.retained_users,
    cs.total_users,
    ROUND((rc.retained_users::numeric / cs.total_users) * 100, 2) AS retention_percent
FROM retention_counts rc
JOIN cohort_size cs ON rc.cohort_month = cs.cohort_month
ORDER BY rc.cohort_month, rc.month_number;