-- =========================================
-- Objective:
-- Analyze customer purchase behavior to measure retention rate,
-- identify churned customers, and uncover factors affecting repeat purchases
-- to support data-driven business decisions.
-- =========================================

-- =========================================
-- Customer Retention Analysis Project
-- =========================================

-- 1. First Order per Customer
WITH first_orders AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY customer_id
)
SELECT * FROM first_orders;

-- =========================================
-- 2. Second Order per Customer
-- =========================================
WITH first_orders AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY customer_id
),
second_orders AS (
    SELECT
        f.customer_id,
        MIN(o.order_date) AS second_order_date
    FROM first_orders f
    LEFT JOIN orders o
        ON f.customer_id = o.customer_id
        AND o.order_date > f.first_order_date
    GROUP BY f.customer_id
)
SELECT * FROM second_orders;

-- =========================================
-- 3. Retention Rate
-- =========================================
WITH first_orders AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY customer_id
),
second_orders AS (
    SELECT  
        f.customer_id,
        f.first_order_date,
        MIN(o.order_date) AS second_order_date
    FROM first_orders f
    LEFT JOIN orders o 
        ON f.customer_id = o.customer_id
        AND o.order_date > f.first_order_date
    GROUP BY f.customer_id, f.first_order_date
)
SELECT 
    COUNT(CASE WHEN second_order_date IS NOT NULL THEN 1 END) AS retained_customers,
    COUNT(*) AS total_customers,
    ROUND(
        COUNT(CASE WHEN second_order_date IS NOT NULL THEN 1 END) * 100.0 
        / COUNT(*), 
        2
    ) AS retention_rate
FROM second_orders;

-- =========================================
-- 4. Days Between Orders
-- =========================================
WITH first_orders AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY customer_id
),
second_orders AS (
    SELECT  
        f.customer_id,
        f.first_order_date,
        MIN(o.order_date) AS second_order_date
    FROM first_orders f
    LEFT JOIN orders o 
        ON f.customer_id = o.customer_id
        AND o.order_date > f.first_order_date
    GROUP BY f.customer_id, f.first_order_date
)
SELECT
    customer_id,
    first_order_date,
    second_order_date,
    DATEDIFF(second_order_date, first_order_date) AS days_between_orders
FROM second_orders
WHERE second_order_date IS NOT NULL;

-- =========================================
-- 5. Retention by Category
-- =========================================
WITH first_orders AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY customer_id
),
first_category AS (
    SELECT 
        f.customer_id,
        f.first_order_date,
        o.category
    FROM first_orders f
    JOIN orders o 
        ON f.customer_id = o.customer_id
        AND f.first_order_date = o.order_date
),
second_orders AS (
    SELECT 
        f.customer_id,
        f.first_order_date,
        MIN(o.order_date) AS second_order_date
    FROM first_orders f
    LEFT JOIN orders o
        ON o.customer_id = f.customer_id
        AND o.order_date > f.first_order_date
    GROUP BY f.customer_id, f.first_order_date
),
final_data AS (
    SELECT 
        fc.customer_id,
        fc.category,
        fc.first_order_date,
        s.second_order_date,
        DATEDIFF(s.second_order_date, fc.first_order_date) AS days_between_orders
    FROM first_category fc
    LEFT JOIN second_orders s
        ON fc.customer_id = s.customer_id
)
SELECT 
    category,
    COUNT(CASE WHEN second_order_date IS NOT NULL THEN 1 END) AS retained_customers,
    COUNT(*) AS total_customers,
    ROUND(
        COUNT(CASE WHEN second_order_date IS NOT NULL THEN 1 END) * 100.0 / COUNT(*), 
        2
    ) AS retention_rate
FROM final_data
GROUP BY category;

-- =========================================
-- 6. Lowest Retention Category
-- =========================================
WITH first_orders AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY customer_id
),
first_category AS (
    SELECT 
        f.customer_id,
        f.first_order_date,
        o.category
    FROM first_orders f
    JOIN orders o 
        ON f.customer_id = o.customer_id
        AND f.first_order_date = o.order_date
),
second_orders AS (
    SELECT 
        f.customer_id,
        f.first_order_date,
        MIN(o.order_date) AS second_order_date
    FROM first_orders f
    LEFT JOIN orders o
        ON o.customer_id = f.customer_id
        AND o.order_date > f.first_order_date
    GROUP BY f.customer_id, f.first_order_date
),
final_data AS (
    SELECT 
        fc.customer_id,
        fc.category,
        fc.first_order_date,
        s.second_order_date,
        DATEDIFF(s.second_order_date, fc.first_order_date) AS days_between_orders
    FROM first_category fc
    LEFT JOIN second_orders s
        ON fc.customer_id = s.customer_id
)
SELECT 
    category,
    ROUND(
        COUNT(CASE WHEN second_order_date IS NOT NULL THEN 1 END) * 100.0 / COUNT(*), 
        2
    ) AS retention_rate
FROM final_data
GROUP BY category
ORDER BY retention_rate ASC
LIMIT 1;