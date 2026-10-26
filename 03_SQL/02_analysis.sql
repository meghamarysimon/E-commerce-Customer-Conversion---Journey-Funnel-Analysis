-- ============================================================
-- E-COMMERCE CUSTOMER CONVERSION & JOURNEY FUNNEL ANALYSIS
-- SQL ANALYSIS
-- Database: ecommerce_funnel
-- ============================================================

USE ecommerce_funnel;


-- ============================================================
-- 1. OVERALL FUNNEL
-- ============================================================

SELECT
    event_type AS funnel_stage,
    COUNT(DISTINCT session_id) AS sessions
FROM events
WHERE event_type IN (
    'visit',
    'product_view',
    'add_to_cart',
    'checkout',
    'payment',
    'purchase'
)
GROUP BY event_type
ORDER BY FIELD(
    event_type,
    'visit',
    'product_view',
    'add_to_cart',
    'checkout',
    'payment',
    'purchase'
);


-- ============================================================
-- 2. FUNNEL CONVERSION & DROP-OFF
-- ============================================================

WITH funnel AS (
    SELECT
        event_type AS funnel_stage,
        COUNT(DISTINCT session_id) AS sessions,
        CASE event_type
            WHEN 'visit' THEN 1
            WHEN 'product_view' THEN 2
            WHEN 'add_to_cart' THEN 3
            WHEN 'checkout' THEN 4
            WHEN 'payment' THEN 5
            WHEN 'purchase' THEN 6
        END AS stage_order
    FROM events
    WHERE event_type IN (
        'visit',
        'product_view',
        'add_to_cart',
        'checkout',
        'payment',
        'purchase'
    )
    GROUP BY event_type
),
funnel_with_previous AS (
    SELECT
        funnel_stage,
        sessions,
        stage_order,
        LAG(sessions) OVER (ORDER BY stage_order) AS previous_sessions
    FROM funnel
)
SELECT
    funnel_stage,
    sessions,
    ROUND(
        CASE
            WHEN previous_sessions IS NULL THEN 100
            ELSE sessions / previous_sessions * 100
        END,
        2
    ) AS conversion_rate_pct,
    ROUND(
        CASE
            WHEN previous_sessions IS NULL THEN 0
            ELSE (previous_sessions - sessions) / previous_sessions * 100
        END,
        2
    ) AS drop_off_rate_pct
FROM funnel_with_previous
ORDER BY stage_order;


-- ============================================================
-- 3. OVERALL CONVERSION RATE
-- ============================================================

SELECT
    COUNT(DISTINCT CASE
        WHEN event_type = 'visit' THEN session_id
    END) AS total_sessions,

    COUNT(DISTINCT CASE
        WHEN event_type = 'purchase' THEN session_id
    END) AS purchase_sessions,

    ROUND(
        COUNT(DISTINCT CASE
            WHEN event_type = 'purchase' THEN session_id
        END)
        /
        COUNT(DISTINCT CASE
            WHEN event_type = 'visit' THEN session_id
        END)
        * 100,
        2
    ) AS overall_conversion_pct
FROM events;


-- ============================================================
-- 4. CONVERSION BY TRAFFIC SOURCE
-- ============================================================

SELECT
    s.traffic_source,
    COUNT(DISTINCT s.session_id) AS total_sessions,
    COUNT(DISTINCT CASE
        WHEN e.event_type = 'purchase' THEN s.session_id
    END) AS purchase_sessions,
    ROUND(
        COUNT(DISTINCT CASE
            WHEN e.event_type = 'purchase' THEN s.session_id
        END)
        / COUNT(DISTINCT s.session_id) * 100,
        2
    ) AS conversion_rate_pct
FROM sessions s
LEFT JOIN events e
    ON s.session_id = e.session_id
GROUP BY s.traffic_source
ORDER BY conversion_rate_pct DESC;


-- ============================================================
-- 5. CONVERSION BY DEVICE
-- ============================================================

SELECT
    s.device_type,
    COUNT(DISTINCT s.session_id) AS total_sessions,
    COUNT(DISTINCT CASE
        WHEN e.event_type = 'purchase' THEN s.session_id
    END) AS purchase_sessions,
    ROUND(
        COUNT(DISTINCT CASE
            WHEN e.event_type = 'purchase' THEN s.session_id
        END)
        / COUNT(DISTINCT s.session_id) * 100,
        2
    ) AS conversion_rate_pct
FROM sessions s
LEFT JOIN events e
    ON s.session_id = e.session_id
GROUP BY s.device_type
ORDER BY conversion_rate_pct DESC;


-- ============================================================
-- 6. PAYMENT METHOD PERFORMANCE
-- ============================================================

SELECT
    payment_method,
    COUNT(*) AS total_orders,

    SUM(
        CASE
            WHEN order_status = 'Completed' THEN 1
            ELSE 0
        END
    ) AS completed_orders,

    ROUND(
        SUM(
            CASE
                WHEN order_status = 'Completed' THEN 1
                ELSE 0
            END
        ) / COUNT(*) * 100,
        2
    ) AS completion_rate_pct,

    ROUND(SUM(net_revenue), 2) AS net_revenue

FROM orders
GROUP BY payment_method
ORDER BY net_revenue DESC;


-- ============================================================
-- 7. NEW VS RETURNING VISITORS
-- ============================================================

SELECT
    s.visitor_type,
    COUNT(DISTINCT s.session_id) AS total_sessions,
    COUNT(DISTINCT CASE
        WHEN e.event_type = 'purchase' THEN s.session_id
    END) AS purchase_sessions,
    ROUND(
        COUNT(DISTINCT CASE
            WHEN e.event_type = 'purchase' THEN s.session_id
        END)
        / COUNT(DISTINCT s.session_id) * 100,
        2
    ) AS conversion_rate_pct
FROM sessions s
LEFT JOIN events e
    ON s.session_id = e.session_id
GROUP BY s.visitor_type
ORDER BY conversion_rate_pct DESC;


-- ============================================================
-- 8. PRODUCT CATEGORY PERFORMANCE
-- ============================================================

SELECT
    p.product_category,
    SUM(oi.quantity) AS units_sold,

    COUNT(DISTINCT CASE
        WHEN o.order_status = 'Completed' THEN o.order_id
    END) AS completed_orders,

    ROUND(SUM(oi.line_total), 2) AS gross_sales,

    ROUND(
        SUM(
            CASE
                WHEN o.order_status = 'Completed'
                THEN oi.line_total
                ELSE 0
            END
        ),
        2
    ) AS completed_order_sales

FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category
ORDER BY completed_order_sales DESC;


-- ============================================================
-- 9. LAST STAGE REACHED IN CUSTOMER JOURNEY
-- ============================================================

SELECT
    event_type AS last_stage,
    COUNT(DISTINCT session_id) AS sessions
FROM events e
WHERE event_ts = (
    SELECT MAX(e2.event_ts)
    FROM events e2
    WHERE e2.session_id = e.session_id
)
GROUP BY event_type
ORDER BY sessions DESC;


-- ============================================================
-- 10. ABANDONED JOURNEYS BY LAST STAGE
-- ============================================================

SELECT
    event_type AS last_stage,
    COUNT(DISTINCT session_id) AS abandoned_sessions
FROM events e
WHERE event_type <> 'purchase'
  AND event_ts = (
      SELECT MAX(e2.event_ts)
      FROM events e2
      WHERE e2.session_id = e.session_id
  )
GROUP BY event_type
ORDER BY abandoned_sessions DESC;


-- ============================================================
-- 11. COMPLETE CUSTOMER JOURNEY
-- ============================================================

SELECT
    COUNT(*) AS complete_journey_sessions
FROM (
    SELECT
        session_id,
        GROUP_CONCAT(
            event_type
            ORDER BY event_ts
            SEPARATOR ' → '
        ) AS journey_path
    FROM events
    GROUP BY session_id
) AS journeys
WHERE journey_path =
    'visit → product_view → add_to_cart → checkout → payment → purchase';


-- ============================================================
-- 12. DEVICE-WISE FUNNEL
-- ============================================================

SELECT
    s.device_type,

    COUNT(DISTINCT s.session_id) AS total_sessions,

    COUNT(DISTINCT CASE
        WHEN e.event_type = 'product_view'
        THEN s.session_id
    END) AS product_views,

    COUNT(DISTINCT CASE
        WHEN e.event_type = 'add_to_cart'
        THEN s.session_id
    END) AS add_to_cart,

    COUNT(DISTINCT CASE
        WHEN e.event_type = 'checkout'
        THEN s.session_id
    END) AS checkout,

    COUNT(DISTINCT CASE
        WHEN e.event_type = 'payment'
        THEN s.session_id
    END) AS payment,

    COUNT(DISTINCT CASE
        WHEN e.event_type = 'purchase'
        THEN s.session_id
    END) AS purchases

FROM sessions s
LEFT JOIN events e
    ON s.session_id = e.session_id
GROUP BY s.device_type
ORDER BY total_sessions DESC;


-- ============================================================
-- 13. TRAFFIC SOURCE FUNNEL
-- ============================================================

SELECT
    s.traffic_source,

    COUNT(DISTINCT s.session_id) AS total_sessions,

    COUNT(DISTINCT CASE
        WHEN e.event_type = 'product_view'
        THEN s.session_id
    END) AS product_views,

    COUNT(DISTINCT CASE
        WHEN e.event_type = 'add_to_cart'
        THEN s.session_id
    END) AS add_to_cart,

    COUNT(DISTINCT CASE
        WHEN e.event_type = 'checkout'
        THEN s.session_id
    END) AS checkout,

    COUNT(DISTINCT CASE
        WHEN e.event_type = 'payment'
        THEN s.session_id
    END) AS payment,

    COUNT(DISTINCT CASE
        WHEN e.event_type = 'purchase'
        THEN s.session_id
    END) AS purchases

FROM sessions s
LEFT JOIN events e
    ON s.session_id = e.session_id
GROUP BY s.traffic_source
ORDER BY total_sessions DESC;


-- ============================================================
-- 14. OVERALL ORDER & REVENUE PERFORMANCE
-- ============================================================

SELECT
    COUNT(*) AS total_orders,

    SUM(
        CASE
            WHEN order_status = 'Completed' THEN 1
            ELSE 0
        END
    ) AS completed_orders,

    SUM(
        CASE
            WHEN order_status = 'Cancelled' THEN 1
            ELSE 0
        END
    ) AS cancelled_orders,

    SUM(
        CASE
            WHEN order_status = 'Refunded' THEN 1
            ELSE 0
        END
    ) AS refunded_orders,

    ROUND(SUM(order_total), 2) AS gross_order_value,

    ROUND(SUM(net_revenue), 2) AS net_revenue,

    ROUND(
        SUM(
            CASE
                WHEN order_status = 'Completed'
                THEN order_total
                ELSE 0
            END
        )
        /
        NULLIF(
            SUM(
                CASE
                    WHEN order_status = 'Completed' THEN 1
                    ELSE 0
                END
            ),
            0
        ),
        2
    ) AS average_order_value

FROM orders;


-- ============================================================
-- 15. MONTHLY REVENUE
-- ============================================================

SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,

    COUNT(
        CASE
            WHEN order_status = 'Completed' THEN 1
        END
    ) AS completed_orders,

    ROUND(SUM(net_revenue), 2) AS net_revenue

FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;


-- ============================================================
-- 16. TOP 10 PRODUCTS BY REVENUE
-- ============================================================

SELECT
    p.product_name,
    p.product_category,
    ROUND(SUM(oi.line_total), 2) AS revenue

FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN products p
    ON oi.product_id = p.product_id

WHERE o.order_status = 'Completed'

GROUP BY
    p.product_id,
    p.product_name,
    p.product_category

ORDER BY revenue DESC
LIMIT 10;


-- ============================================================
-- 17. CAMPAIGN PERFORMANCE
-- ============================================================

SELECT
    COALESCE(
        NULLIF(TRIM(s.campaign), ''),
        'No Campaign'
    ) AS campaign,

    COUNT(DISTINCT s.session_id) AS total_sessions,

    COUNT(DISTINCT CASE
        WHEN e.event_type = 'purchase'
        THEN s.session_id
    END) AS purchase_sessions,

    ROUND(
        COUNT(DISTINCT CASE
            WHEN e.event_type = 'purchase'
            THEN s.session_id
        END)
        / COUNT(DISTINCT s.session_id) * 100,
        2
    ) AS conversion_rate_pct

FROM sessions s
LEFT JOIN events e
    ON s.session_id = e.session_id

GROUP BY
    COALESCE(
        NULLIF(TRIM(s.campaign), ''),
        'No Campaign'
    )

ORDER BY conversion_rate_pct DESC;


-- ============================================================
-- 18. ONE-TIME VS REPEAT CUSTOMERS
-- ============================================================

SELECT
    customer_type,
    COUNT(*) AS customer_count,
    SUM(total_orders) AS completed_orders,
    ROUND(SUM(total_revenue), 2) AS net_revenue,
    ROUND(AVG(total_orders), 2) AS avg_orders_per_customer

FROM (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(net_revenue) AS total_revenue,

        CASE
            WHEN COUNT(DISTINCT order_id) = 1
                THEN 'One-time Customer'
            ELSE 'Repeat Customer'
        END AS customer_type

    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
) AS customer_summary

GROUP BY customer_type
ORDER BY customer_count DESC;


-- ============================================================
-- 19. FINAL KPI SUMMARY
-- ============================================================

SELECT

    (
        SELECT COUNT(DISTINCT session_id)
        FROM events
        WHERE event_type = 'visit'
    ) AS total_sessions,

    (
        SELECT COUNT(DISTINCT session_id)
        FROM events
        WHERE event_type = 'purchase'
    ) AS purchase_sessions,

    (
        SELECT ROUND(
            COUNT(DISTINCT CASE
                WHEN event_type = 'purchase'
                THEN session_id
            END)
            /
            COUNT(DISTINCT CASE
                WHEN event_type = 'visit'
                THEN session_id
            END)
            * 100,
            2
        )
        FROM events
    ) AS overall_conversion_pct,

    (
        SELECT COUNT(*)
        FROM orders
    ) AS total_orders,

    (
        SELECT COUNT(*)
        FROM orders
        WHERE order_status = 'Completed'
    ) AS completed_orders,

    (
        SELECT ROUND(SUM(net_revenue), 2)
        FROM orders
    ) AS net_revenue,

    (
        SELECT ROUND(
            SUM(
                CASE
                    WHEN order_status = 'Completed'
                    THEN order_total
                    ELSE 0
                END
            )
            /
            NULLIF(
                COUNT(
                    CASE
                        WHEN order_status = 'Completed'
                        THEN 1
                    END
                ),
                0
            ),
            2
        )
        FROM orders
    ) AS average_order_value,

    (
        SELECT COUNT(DISTINCT customer_id)
        FROM orders
        WHERE order_status = 'Completed'
    ) AS purchasing_customers,

    (
        SELECT COUNT(*)
        FROM (
            SELECT customer_id
            FROM orders
            WHERE order_status = 'Completed'
            GROUP BY customer_id
            HAVING COUNT(DISTINCT order_id) > 1
        ) AS repeat_customers
    ) AS repeat_customers;