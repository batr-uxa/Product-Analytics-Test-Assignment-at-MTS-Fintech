DROP TABLE IF EXISTS transact;

CREATE TABLE transact (
    id_client INT,
    tran_time TIMESTAMP,
    id_tran INT,
    sum_tran NUMERIC(10, 2)
);

INSERT INTO transact (id_client, tran_time, id_tran, sum_tran) VALUES
-- Клиент 1: много трат за всю историю, есть траты за последние 30 дней
(1, '2021-05-10 10:00:00', 101, 500.00),
(1, '2021-06-15 12:00:00', 102, 1000.00),
(1, CURRENT_DATE - INTERVAL '5 days', 103, 200.00),
(1, CURRENT_DATE - INTERVAL '10 days', 104, 300.00),

-- Клиент 2: очень платежеспособный, траты помесячно
(2, '2021-01-20 14:00:00', 201, 5000.00),
(2, '2021-02-20 15:00:00', 202, 6000.00),
(2, '2021-03-20 16:00:00', 203, 7000.00),

-- Клиент 3: траты только в последние 30 дней
(3, CURRENT_DATE - INTERVAL '2 days', 301, 150.00),

-- Клиент 4: старые траты, нет трат за последние 30 дней
(4, '2021-12-01 09:00:00', 401, 2000.00),
(4, '2022-01-15 10:30:00', 402, 1500.00),

-- Клиент 5: мелочь
(5, '2021-07-07 11:11:11', 501, 50.00);

SELECT 
    id_client,
    SUM(sum_tran) AS total_spent_30d
FROM transact
WHERE tran_time >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY id_client
ORDER BY total_spent_30d DESC;
WITH top_clients AS (
    SELECT 
        id_client
    FROM transact
    GROUP BY id_client
    ORDER BY SUM(sum_tran) DESC
    LIMIT 100
)
SELECT 
    t.id_client,
    DATE_TRUNC('month', t.tran_time)::date AS tran_month,
    SUM(t.sum_tran) AS monthly_spent
FROM transact t
INNER JOIN top_clients tc ON t.id_client = tc.id_client
GROUP BY 
    t.id_client, 
    DATE_TRUNC('month', t.tran_time)
ORDER BY 
    t.id_client, 
    tran_month;
