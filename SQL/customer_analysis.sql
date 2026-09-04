-- ============================================================
-- RETENTIONIQ
-- Customer & Churn Analysis
-- ============================================================


-- ============================================================
-- QUERY 1: Overall Customer Churn
-- Business Question:
-- What percentage of customers have churned?
-- ============================================================

SELECT
    COUNT(*) AS total_customers,

    SUM(
        CASE
            WHEN churn_flag = 1 THEN 1
            ELSE 0
        END
    ) AS churned_customers,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN churn_flag = 1 THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS churn_rate_pct

FROM accounts;


-- ============================================================
-- QUERY 2: Customer Distribution by Industry
-- ============================================================

SELECT
    industry,
    COUNT(*) AS total_customers,

    SUM(
        CASE
            WHEN churn_flag = 1 THEN 1
            ELSE 0
        END
    ) AS churned_customers,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN churn_flag = 1 THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS churn_rate_pct

FROM accounts

GROUP BY industry

ORDER BY churn_rate_pct DESC;


-- ============================================================
-- QUERY 3: Churn by Plan Tier
-- ============================================================

SELECT
    plan_tier,
    COUNT(*) AS total_customers,

    SUM(
        CASE
            WHEN churn_flag = 1 THEN 1
            ELSE 0
        END
    ) AS churned_customers,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN churn_flag = 1 THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS churn_rate_pct

FROM accounts

GROUP BY plan_tier

ORDER BY churn_rate_pct DESC;


-- ============================================================
-- QUERY 4: Churn by Trial Status
-- ============================================================

SELECT
    is_trial,
    COUNT(*) AS total_customers,

    SUM(
        CASE
            WHEN churn_flag = 1 THEN 1
            ELSE 0
        END
    ) AS churned_customers,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN churn_flag = 1 THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS churn_rate_pct

FROM accounts

GROUP BY is_trial

ORDER BY churn_rate_pct DESC;


-- ============================================================
-- QUERY 5: Churn by Referral Source
-- ============================================================

SELECT
    referral_source,
    COUNT(*) AS total_customers,

    SUM(
        CASE
            WHEN churn_flag = 1 THEN 1
            ELSE 0
        END
    ) AS churned_customers,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN churn_flag = 1 THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS churn_rate_pct

FROM accounts

GROUP BY referral_source

ORDER BY churn_rate_pct DESC;


-- ============================================================
-- QUERY 6: Customer Revenue Ranking
-- Business Question:
-- Which customers generate the most MRR?
-- ============================================================

SELECT
    account_id,
    account_name,
    industry,
    plan_tier,
    seats,
    total_mrr,
    total_arr,
    customer_status,
    retention_priority

FROM customer_analytics

ORDER BY total_mrr DESC

LIMIT 20;


-- ============================================================
-- QUERY 7: High-Value Active Customers
-- Business Question:
-- Which active customers have high revenue exposure?
-- ============================================================

SELECT
    account_id,
    account_name,
    industry,
    plan_tier,
    seats,
    total_mrr,
    total_arr,
    tenure_months,
    retention_priority,
    priority_reason

FROM customer_analytics

WHERE customer_status = 'Active'

ORDER BY total_mrr DESC

LIMIT 20;