-- ============================================================
-- RETENTIONIQ - CHURN ANALYSIS
-- ============================================================

-- Query 1: Overall subscription churn
SELECT
    COUNT(*) AS total_subscriptions,
    SUM(CASE WHEN churn_flag = 1 THEN 1 ELSE 0 END) AS churned_subscriptions,
    ROUND(
        100.0 * SUM(CASE WHEN churn_flag = 1 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS subscription_churn_rate_pct
FROM subscriptions;


-- Query 2: Subscription churn by plan
SELECT
    plan_tier,
    COUNT(*) AS total_subscriptions,
    SUM(CASE WHEN churn_flag = 1 THEN 1 ELSE 0 END) AS churned_subscriptions,
    ROUND(
        100.0 * SUM(CASE WHEN churn_flag = 1 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate_pct
FROM subscriptions
GROUP BY plan_tier
ORDER BY churn_rate_pct DESC;


-- Query 3: Customer churn by industry
SELECT
    industry,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN customer_status = 'Churned' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN customer_status = 'Churned' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate_pct
FROM customer_analytics
GROUP BY industry
ORDER BY churn_rate_pct DESC;


-- Query 4: Churn by tenure group
SELECT
    CASE
        WHEN tenure_months < 6 THEN '0-6 Months'
        WHEN tenure_months < 12 THEN '6-12 Months'
        WHEN tenure_months < 18 THEN '12-18 Months'
        ELSE '18+ Months'
    END AS tenure_group,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN customer_status = 'Churned' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN customer_status = 'Churned' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate_pct
FROM customer_analytics
GROUP BY tenure_group
ORDER BY
    CASE tenure_group
        WHEN '0-6 Months' THEN 1
        WHEN '6-12 Months' THEN 2
        WHEN '12-18 Months' THEN 3
        ELSE 4
    END;


-- Query 5: Churn by retention priority
SELECT
    retention_priority,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN customer_status = 'Churned' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN customer_status = 'Churned' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate_pct
FROM customer_analytics
GROUP BY retention_priority
ORDER BY
    CASE retention_priority
        WHEN 'Critical' THEN 1
        WHEN 'Priority' THEN 2
        ELSE 3
    END;


-- Query 6: Churn by support escalation

SELECT
    CASE
        WHEN escalation_rate >= 0.05 THEN 'High Escalation'
        ELSE 'Low Escalation'
    END AS escalation_group,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN customer_status = 'Churned' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN customer_status = 'Churned' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate_pct
FROM customer_analytics
GROUP BY escalation_group
ORDER BY churn_rate_pct DESC;

-- Query 7: Churn by upgrade / downgrade history
SELECT
    CASE
        WHEN total_downgrades > 0 THEN 'Had Downgrade'
        ELSE 'No Downgrade'
    END AS downgrade_group,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN customer_status = 'Churned' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN customer_status = 'Churned' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate_pct
FROM customer_analytics
GROUP BY downgrade_group
ORDER BY churn_rate_pct DESC;


-- Query 8: Churn event reasons
SELECT
    reason_code,
    COUNT(*) AS churn_events,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM churn_events WHERE is_reactivation = 0),
        2
    ) AS percentage_of_churn_events
FROM churn_events
WHERE is_reactivation = 0
GROUP BY reason_code
ORDER BY churn_events DESC;


-- Query 9: Reactivation analysis
SELECT
    COUNT(*) AS total_churn_events,
    SUM(CASE WHEN is_reactivation = 1 THEN 1 ELSE 0 END) AS reactivation_events,
    ROUND(
        100.0 * SUM(CASE WHEN is_reactivation = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS reactivation_rate_pct
FROM churn_events;

-- Query 10: High-value customers with repeated churn events
SELECT
    ca.account_id,
    ca.account_name,
    ca.industry,
    ca.plan_tier,
    ca.customer_status,
    ca.total_mrr,
    ca.total_arr,
    COUNT(ce.churn_event_id) AS churn_event_count,
    ROUND(SUM(ce.refund_amount_usd), 2) AS total_refund_amount
FROM customer_analytics ca
JOIN churn_events ce
    ON ca.account_id = ce.account_id
WHERE ce.is_reactivation = 0
GROUP BY
    ca.account_id,
    ca.account_name,
    ca.industry,
    ca.plan_tier,
    ca.customer_status,
    ca.total_mrr,
    ca.total_arr
HAVING
    COUNT(ce.churn_event_id) > 1
ORDER BY
    ca.total_mrr DESC,
    churn_event_count DESC
LIMIT 20;