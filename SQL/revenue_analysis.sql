-- ============================================================
-- RETENTIONIQ
-- Revenue Analysis
-- ============================================================


-- ============================================================
-- QUERY 1: Overall Revenue
-- ============================================================

SELECT
    COUNT(*) AS total_subscriptions,
    ROUND(SUM(mrr_amount), 2) AS total_mrr,
    ROUND(SUM(arr_amount), 2) AS total_arr,
    ROUND(AVG(mrr_amount), 2) AS average_mrr,
    ROUND(AVG(arr_amount), 2) AS average_arr

FROM subscriptions;


-- ============================================================
-- QUERY 2: Revenue by Plan Tier
-- ============================================================

SELECT
    plan_tier,

    COUNT(*) AS subscriptions,

    ROUND(SUM(mrr_amount), 2) AS total_mrr,

    ROUND(SUM(arr_amount), 2) AS total_arr,

    ROUND(AVG(mrr_amount), 2) AS average_mrr

FROM subscriptions

GROUP BY plan_tier

ORDER BY total_mrr DESC;


-- ============================================================
-- QUERY 3: Revenue by Billing Frequency
-- ============================================================

SELECT
    billing_frequency,

    COUNT(*) AS subscriptions,

    ROUND(SUM(mrr_amount), 2) AS total_mrr,

    ROUND(SUM(arr_amount), 2) AS total_arr,

    ROUND(AVG(mrr_amount), 2) AS average_mrr

FROM subscriptions

GROUP BY billing_frequency

ORDER BY total_mrr DESC;


-- ============================================================
-- QUERY 4: Active vs Churned Subscription Revenue
-- ============================================================

SELECT
    CASE
        WHEN churn_flag = 1 THEN 'Churned'
        ELSE 'Active'
    END AS subscription_status,

    COUNT(*) AS subscriptions,

    ROUND(SUM(mrr_amount), 2) AS total_mrr,

    ROUND(SUM(arr_amount), 2) AS total_arr

FROM subscriptions

GROUP BY churn_flag

ORDER BY total_mrr DESC;


-- ============================================================
-- QUERY 5: Revenue by Industry
-- ============================================================

SELECT
    a.industry,

    COUNT(DISTINCT a.account_id) AS customers,

    ROUND(SUM(c.total_mrr), 2) AS total_mrr,

    ROUND(SUM(c.total_arr), 2) AS total_arr,

    ROUND(AVG(c.total_mrr), 2) AS average_customer_mrr

FROM accounts a

JOIN customer_analytics c
    ON a.account_id = c.account_id

GROUP BY a.industry

ORDER BY total_mrr DESC;


-- ============================================================
-- QUERY 6: Top 20 Customers by MRR
-- ============================================================

SELECT
    account_id,
    account_name,
    industry,
    plan_tier,
    customer_status,
    ROUND(total_mrr, 2) AS total_mrr,
    ROUND(total_arr, 2) AS total_arr

FROM customer_analytics

ORDER BY total_mrr DESC

LIMIT 20;


-- ============================================================
-- QUERY 7: High-Value Active Customers
-- ============================================================

SELECT
    account_id,
    account_name,
    industry,
    plan_tier,
    seats,

    ROUND(total_mrr, 2) AS total_mrr,
    ROUND(total_arr, 2) AS total_arr,

    ROUND(tenure_months, 1) AS tenure_months,

    retention_priority,
    priority_reason

FROM customer_analytics

WHERE customer_status = 'Active'

ORDER BY total_mrr DESC

LIMIT 20;


-- ============================================================
-- QUERY 8: Revenue Exposure by Retention Priority
-- ============================================================

SELECT
    retention_priority,

    COUNT(*) AS customers,

    ROUND(SUM(total_mrr), 2) AS total_mrr,

    ROUND(SUM(total_arr), 2) AS total_arr,

    ROUND(AVG(total_mrr), 2) AS average_mrr

FROM customer_analytics

GROUP BY retention_priority

ORDER BY total_mrr DESC;


-- ============================================================
-- QUERY 9: Critical Active Customers
-- ============================================================

SELECT
    account_id,
    account_name,
    industry,
    plan_tier,

    ROUND(total_mrr, 2) AS total_mrr,

    ROUND(total_arr, 2) AS total_arr,

    ROUND(tenure_months, 1) AS tenure_months,

    escalation_rate,

    retention_priority,
    priority_reason

FROM customer_analytics

WHERE customer_status = 'Active'
  AND retention_priority = 'Critical'

ORDER BY total_mrr DESC;


-- ============================================================
-- QUERY 10: Revenue Concentration
-- ============================================================

SELECT
    plan_tier,

    ROUND(
        100.0 * SUM(mrr_amount) /
        (SELECT SUM(mrr_amount) FROM subscriptions),
        2
    ) AS mrr_share_pct

FROM subscriptions

GROUP BY plan_tier

ORDER BY mrr_share_pct DESC;