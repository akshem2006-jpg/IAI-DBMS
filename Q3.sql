-- Q3(a)

SELECT
    issue_category,
    ROUND(AVG(resolution_time_hours),2) AS resolution_time_hours,
    ROUND(AVG(customer_satisfaction_score),2) AS customer_satisfaction_score
FROM support_tickets
WHERE priority='High'
AND resolution_status='Closed'
GROUP BY issue_category
HAVING COUNT(ticket_id)>5;

----------------------------------------------------------

-- Q3(b)

WITH interaction_summary AS
(
    SELECT
        customer_id,
        COUNT(*) AS add_to_cart_count
    FROM interactions
    WHERE interaction_type='Add to Cart'
    GROUP BY customer_id
),

transaction_summary AS
(
    SELECT
        customer_id,
        SUM(quantity*price) AS total_revenue
    FROM transactions
    GROUP BY customer_id
),

ticket_summary AS
(
    SELECT
        customer_id,
        COUNT(*) AS total_tickets
    FROM support_tickets
    GROUP BY customer_id
)

SELECT
    c.preferred_channel,
    COUNT(DISTINCT c.customer_id) AS total_registered_customers,
    COALESCE(SUM(i.add_to_cart_count),0) AS total_add_to_cart,
    COALESCE(SUM(t.total_revenue),0) AS total_revenue_generated,
    COALESCE(SUM(s.total_tickets),0) AS total_support_tickets
FROM customers c
LEFT JOIN interaction_summary i
ON c.customer_id=i.customer_id
LEFT JOIN transaction_summary t
ON c.customer_id=t.customer_id
LEFT JOIN ticket_summary s
ON c.customer_id=s.customer_id
GROUP BY c.preferred_channel
ORDER BY total_revenue_generated DESC;