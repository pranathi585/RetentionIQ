// ============================================================================
// RETENTIONIQ — POWER QUERY M IMPORT SCRIPTS
// ============================================================================
// Project: RetentionIQ — Customer Retention & Revenue Intelligence
// Description: M code for loading and formatting cleaned CSV files in Power BI Desktop.
// Instructions: In Power BI Desktop, open Power Query Editor -> Advanced Editor,
// and paste the corresponding M query block for each table. Replace #"BASE_PATH"
// with your local workspace directory path (e.g., "E:\Pranathi\DA\RetentionIQ\Cleaned_Data\").
// ============================================================================


// ============================================================================
// 1. customer_analytics (Main Customer Dimension Table)
// File: Cleaned_Data/customer_analytics.csv (500 rows)
// Note: Do NOT import accounts_cleaned.csv as customer_analytics contains all
// customer attributes plus aggregated KPIs and Retention Priority classifications.
// ============================================================================
let
    Source = Csv.Document(
        File.Contents(BASE_PATH & "customer_analytics.csv"),
        [Delimiter=",", Columns=41, Encoding=65001, QuoteStyle=QuoteStyle.None]
    ),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{
        {"account_id", type text},
        {"account_name", type text},
        {"industry", type text},
        {"country", type text},
        {"signup_date", type date},
        {"referral_source", type text},
        {"plan_tier", type text},
        {"seats", Int64.Type},
        {"is_trial", type logical},
        {"customer_status", type text},
        {"tenure_days", Int64.Type},
        {"tenure_months", type number},
        {"total_subscriptions", Int64.Type},
        {"active_subscriptions", Int64.Type},
        {"churned_subscriptions", Int64.Type},
        {"total_mrr", type number},
        {"total_arr", type number},
        {"mrr_per_seat", type number},
        {"total_upgrades", Int64.Type},
        {"total_downgrades", Int64.Type},
        {"upgrade_rate", type number},
        {"downgrade_rate", type number},
        {"auto_renew_subscriptions", Int64.Type},
        {"auto_renew_rate", type number},
        {"usage_events", Int64.Type},
        {"total_usage", Int64.Type},
        {"total_duration_secs", Int64.Type},
        {"total_errors", Int64.Type},
        {"features_used", Int64.Type},
        {"total_tickets", Int64.Type},
        {"avg_resolution_hours", type number},
        {"avg_first_response_minutes", type number},
        {"avg_satisfaction", type number},
        {"escalated_tickets", Int64.Type},
        {"escalation_rate", type number},
        {"total_churn_events", Int64.Type},
        {"total_refund", type number},
        {"reactivation_events", Int64.Type},
        {"retention_priority_score", Int64.Type},
        {"retention_priority", type text},
        {"priority_reason", type text}
    })
in
    #"Changed Type"


// ============================================================================
// 2. subscriptions_cleaned (Fact Table — Subscriptions & Revenue)
// File: Cleaned_Data/subscriptions_cleaned.csv (5,000 rows)
// ============================================================================
let
    Source = Csv.Document(
        File.Contents(BASE_PATH & "subscriptions_cleaned.csv"),
        [Delimiter=",", Columns=14, Encoding=65001, QuoteStyle=QuoteStyle.None]
    ),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{
        {"subscription_id", type text},
        {"account_id", type text},
        {"start_date", type date},
        {"end_date", type date},
        {"plan_tier", type text},
        {"seats", Int64.Type},
        {"mrr_amount", type number},
        {"arr_amount", type number},
        {"is_trial", type logical},
        {"upgrade_flag", type logical},
        {"downgrade_flag", type logical},
        {"churn_flag", type logical},
        {"billing_frequency", type text},
        {"auto_renew_flag", type logical}
    })
in
    #"Changed Type"


// ============================================================================
// 3. support_tickets_cleaned (Fact Table — Support Logs)
// File: Cleaned_Data/support_tickets_cleaned.csv (2,000 rows)
// Note: satisfaction_score contains missing values (NULL). Do NOT replace
// missing values with zero; leave as null so DAX AVERAGE operates accurately.
// ============================================================================
let
    Source = Csv.Document(
        File.Contents(BASE_PATH & "support_tickets_cleaned.csv"),
        [Delimiter=",", Columns=9, Encoding=65001, QuoteStyle=QuoteStyle.None]
    ),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{
        {"ticket_id", type text},
        {"account_id", type text},
        {"submitted_at", type datetime},
        {"closed_at", type datetime},
        {"resolution_time_hours", type number},
        {"priority", type text},
        {"first_response_time_minutes", Int64.Type},
        {"satisfaction_score", type number},
        {"escalation_flag", type logical}
    })
in
    #"Changed Type"


// ============================================================================
// 4. churn_events_cleaned (Fact Table — Lifecycle Churn & Reactivations)
// File: Cleaned_Data/churn_events_cleaned.csv (600 rows)
// Note: 61 rows have is_reactivation = true (10.17%). Filter in DAX measures.
// ============================================================================
let
    Source = Csv.Document(
        File.Contents(BASE_PATH & "churn_events_cleaned.csv"),
        [Delimiter=",", Columns=9, Encoding=65001, QuoteStyle=QuoteStyle.None]
    ),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{
        {"churn_event_id", type text},
        {"account_id", type text},
        {"churn_date", type date},
        {"reason_code", type text},
        {"refund_amount_usd", type number},
        {"preceding_upgrade_flag", type logical},
        {"preceding_downgrade_flag", type logical},
        {"is_reactivation", type logical},
        {"feedback_text", type text}
    })
in
    #"Changed Type"


// ============================================================================
// 5. feature_usage_cleaned (Fact Table — Feature Usage Logs)
// File: Cleaned_Data/feature_usage_cleaned.csv (25,000 rows)
// ============================================================================
let
    Source = Csv.Document(
        File.Contents(BASE_PATH & "feature_usage_cleaned.csv"),
        [Delimiter=",", Columns=8, Encoding=65001, QuoteStyle=QuoteStyle.None]
    ),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{
        {"usage_id", type text},
        {"subscription_id", type text},
        {"usage_date", type date},
        {"feature_name", type text},
        {"usage_count", Int64.Type},
        {"usage_duration_secs", Int64.Type},
        {"error_count", Int64.Type},
        {"is_beta_feature", type logical}
    })
in
    #"Changed Type"
