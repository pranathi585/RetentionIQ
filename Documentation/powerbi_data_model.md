# RetentionIQ — Power BI Data Model & Dashboard Architecture

**Project Title**: RetentionIQ — Customer Retention & Revenue Intelligence  
**Dataset**: Simulated SaaS Account, Subscription, Usage, Support, and Churn Event Data  
**Author**: Data Analyst  
**Document Version**: 1.1 (Reconciled Metrics Edition)  
**Relative Path**: `Documentation/powerbi_data_model.md`

---

## 1. Project Purpose

RetentionIQ is an end-to-end Data Analytics portfolio project designed to analyze customer retention, subscription churn, revenue health, and support friction for a simulated B2B SaaS platform (RavenStack). 

The primary goals of the Power BI data model and dashboard are:
* **Quantify Customer vs. Subscription Churn**: Provide executive visibility into overall account churn rate (22.00%) versus subscription contract churn rate (9.72%).
* **Analyze Revenue Concentration & Exposure**: Evaluate Monthly Recurring Revenue (MRR) and Annual Recurring Revenue (ARR) at both customer-level ($11.34M total / $8.98M active) and subscription-level ($10.16M active / $1.18M churned lost revenue).
* **Implement the Retention Priority Framework**: Provide an explainable, business-driven prioritization framework (*Monitor*, *Priority*, *Critical*) to highlight active high-value accounts exposed to churn risk.
* **Guide Operational Customer Success Decisions**: Supply actionable recommendations based on customer tenure, support escalation history, and churn events.

> [!NOTE]  
> The **Retention Priority Framework** is an explainable business prioritization rule based on revenue, tenure, and support escalation. It is **NOT** a predictive machine learning churn model. All dataset records are simulated.

---

## 2. Data Model Tables & Architecture

### Imported Tables (5 Tables)

1. **`customer_analytics`** (`Cleaned_Data/customer_analytics.csv`)
   * **Role**: Primary Customer Dimension Table (`DimCustomer`).
   * **Physical Data Rows**: 500 rows.
   * **Grain**: 1 row per unique customer account (`account_id`).
   * **Key Attributes**: Account demographics (`account_name`, `industry`, `country`, `signup_date`, `plan_tier`, `seats`, `is_trial`), customer status (`customer_status`), tenure (`tenure_months`), aggregated financial metrics (`total_mrr`, `total_arr`), support metrics (`escalation_rate`), and Retention Priority classification (`retention_priority`, `priority_reason`).

2. **`subscriptions_cleaned`** (`Cleaned_Data/subscriptions_cleaned.csv`)
   * **Role**: Subscription & Revenue Fact Table (`FactSubscriptions`).
   * **Physical Data Rows**: 5,000 rows.
   * **Grain**: 1 row per subscription contract (`subscription_id`).
   * **Key Attributes**: `account_id`, `start_date`, `end_date`, `plan_tier`, `seats`, `mrr_amount`, `arr_amount`, `is_trial`, `upgrade_flag`, `downgrade_flag`, `churn_flag`, `billing_frequency`, `auto_renew_flag`.

3. **`support_tickets_cleaned`** (`Cleaned_Data/support_tickets_cleaned.csv`)
   * **Role**: Support Operations Fact Table (`FactSupportTickets`).
   * **Physical Data Rows**: 2,000 rows.
   * **Grain**: 1 row per support ticket (`ticket_id`).
   * **Key Attributes**: `account_id`, `submitted_at`, `closed_at`, `resolution_time_hours`, `priority`, `first_response_time_minutes`, `satisfaction_score`, `escalation_flag`.

4. **`churn_events_cleaned`** (`Cleaned_Data/churn_events_cleaned.csv`)
   * **Role**: Lifecycle Event Fact Table (`FactChurnEvents`).
   * **Physical Data Rows**: 600 rows.
   * **Grain**: 1 row per churn or reactivation event (`churn_event_id`).
   * **Key Attributes**: `account_id`, `churn_date`, `reason_code`, `refund_amount_usd`, `preceding_upgrade_flag`, `preceding_downgrade_flag`, `is_reactivation`, `feedback_text`.

5. **`feature_usage_cleaned`** (`Cleaned_Data/feature_usage_cleaned.csv`)
   * **Role**: Product Usage Fact Log Table (`FactFeatureUsage`).
   * **Physical Data Rows**: 25,000 rows.
   * **Grain**: 1 row per usage log entry (`usage_id`).
   * **Key Attributes**: `subscription_id`, `usage_date`, `feature_name`, `usage_count`, `usage_duration_secs`, `error_count`, `is_beta_feature`.

6. **`DimDate`** (Generated via DAX)
   * **Role**: Central Date Dimension Table.
   * **Grain**: 1 row per calendar day.

---

### Excluded Tables

* **`accounts_cleaned.csv`**: **EXCLUDED** from Power BI.  
  * *Reason*: `customer_analytics.csv` already contains every single column from `accounts_cleaned.csv` (`account_id`, `account_name`, `industry`, `country`, `signup_date`, `referral_source`, `plan_tier`, `seats`, `is_trial`). Excluding `accounts_cleaned.csv` prevents model redundancy, duplicate key relationships, and ambiguous filter paths.

---

## 3. Relationships & Schema Design

The model follows a clean **Star / Snowflake Schema** anchored by `customer_analytics`:

```
                       ┌─────────────────────────┐
                       │       customer_analytics│ (1)
                       └────────────┬────────────┘
                                    │
            ┌───────────────────────┼───────────────────────┐
            │ 1:*                   │ 1:*                   │ 1:*
            ▼                       ▼                       ▼
┌───────────────────────┐ ┌───────────────────┐ ┌───────────────────────┐
│ subscriptions_cleaned │ │support_tickets    │ │ churn_events_cleaned  │
└───────────┬───────────┘ └───────────────────┘ └───────────────────────┘
            │ 1:*
            ▼
┌───────────────────────┐
│ feature_usage_cleaned │
└───────────────────────┘
```

### Table Relationships & Cardinality Summary

| From Table (Child / Fact) | Foreign Key | To Table (Parent / Dimension) | Primary Key | Cardinality | Filter Direction | Relationship Status |
|---|---|---|---|---|---|---|
| `subscriptions_cleaned` | `account_id` | `customer_analytics` | `account_id` | Many-to-One (`*:1`) | Single | Active |
| `support_tickets_cleaned` | `account_id` | `customer_analytics` | `account_id` | Many-to-One (`*:1`) | Single | Active |
| `churn_events_cleaned` | `account_id` | `customer_analytics` | `account_id` | Many-to-One (`*:1`) | Single | Active |
| `feature_usage_cleaned` | `subscription_id` | `subscriptions_cleaned` | `subscription_id` | Many-to-One (`*:1`) | Single | Active |
| `subscriptions_cleaned` | `start_date` | `DimDate` | `Date` | Many-to-One (`*:1`) | Single | **Active** |
| `customer_analytics` | `signup_date` | `DimDate` | `Date` | Many-to-One (`*:1`) | Single | Inactive (`USERELATIONSHIP`) |
| `churn_events_cleaned` | `churn_date` | `DimDate` | `Date` | Many-to-One (`*:1`) | Single | Inactive (`USERELATIONSHIP`) |
| `support_tickets_cleaned` | `submitted_at` | `DimDate` | `Date` | Many-to-One (`*:1`) | Single | Inactive (`USERELATIONSHIP`) |
| `feature_usage_cleaned` | `usage_date` | `DimDate` | `Date` | Many-to-One (`*:1`) | Single | Inactive (`USERELATIONSHIP`) |

---

## 4. Date Model & Time Intelligence Strategy

To ensure model simplicity and avoid ambiguous relationship paths, the data model employs a **Single Central Date Table (`DimDate`)**:

1. **Primary Active Date Relationship**:
   * `DimDate[Date]` ──1:*──> `subscriptions_cleaned[start_date]` (Active)
   * This allows standard DAX time calculations to default to subscription cohort start dates.

2. **Inactive Secondary Date Relationships**:
   * `DimDate[Date]` ──> `customer_analytics[signup_date]` (Inactive)
   * `DimDate[Date]` ──> `churn_events_cleaned[churn_date]` (Inactive)
   * `DimDate[Date]` ──> `support_tickets_cleaned[submitted_at]` (Inactive)
   * `DimDate[Date]` ──> `feature_usage_cleaned[usage_date]` (Inactive)

3. **Execution via `USERELATIONSHIP()`**:
   * Time-based metrics for non-primary events (e.g. `Churn Event Trend`, `Customer Signup Trend`) explicitly invoke DAX `USERELATIONSHIP(DimDate[Date], TargetTable[DateColumn])`.
   * *Interview Advantage*: Demonstrates advanced DAX modeling capability by using controlled inactive relationships instead of cluttering the model with 5 role-playing calendar tables.

---

## 5. Metric Granularity & Double-Counting Safeguards

### Authoritative Metric Definitions

1. **Customer Churn (Customer Grain)**:
   * Evaluated at `customer_analytics[customer_status]` level (500 total accounts).
   * **Validated Customer Churn Rate**: **22.00%** (110 / 500 accounts churned).

2. **Subscription Churn (Contract Grain)**:
   * Evaluated at `subscriptions_cleaned[churn_flag]` level (5,000 total subscriptions).
   * **Validated Subscription Churn Rate**: **9.72%** (486 / 5,000 subscriptions churned).

3. **Customer-Level Revenue Metrics**:
   * Sourced from `customer_analytics`.
   * **`Customer Total MRR`**: **$11,338,747**
   * **`Customer Total ARR`**: **$136,064,964**
   * **`Active Customer MRR`**: **$8,983,502**
   * **`Churned Customer MRR`**: **$2,355,245**
   * **`Average Customer MRR`**: **$22,677.49**

4. **Subscription-Level Revenue Metrics**:
   * Sourced from `subscriptions_cleaned`.
   * **`Subscription Total MRR`**: **$11,338,747**
   * **`Active Subscription MRR`**: **$10,159,608**
   * **`Churned Subscription MRR`**: **$1,179,139** *(Genuinely lost subscription revenue from terminated contracts)*

5. **Retention Exposure (Active MRR at Risk)**:
   * Sourced from `customer_analytics`.
   * **`Critical Active MRR Exposure`**: **$2,857,641** (80 active Critical accounts)
   * **`Priority Active MRR Exposure`**: **$4,307,073** (187 active Priority accounts)
   * **`Retention Exposure Total`**: **$7,164,714**
   * **Crucial Rule**: Retention exposure represents active recurring revenue that must be protected through proactive customer success. It MUST NOT be described as "Lost Revenue" or "Lost MRR".

6. **Retention Priority Framework**:
   * Authoritative distribution from `customer_analytics[retention_priority]`:
     * **Monitor**: 152 accounts (123 Active, 29 Churned)
     * **Priority**: 239 accounts (187 Active, 52 Churned)
     * **Critical**: 109 accounts (80 Active, 29 Churned)

7. **Lifecycle Churn & Reactivations**:
   * Total churn event records: 600
   * Reactivation events (`is_reactivation = TRUE`): 61 (10.17%)
   * Genuine churn events (`is_reactivation = FALSE`): **539**

8. **Tenure Cohort Churn Rates**:
   * 0–6 Months: **16.56%** (25 / 151)
   * 6–12 Months: **22.31%** (27 / 121)
   * 12–18 Months: **24.58%** (29 / 118)
   * 18+ Months: **26.36%** (29 / 110)

### Double-Counting Safeguards

* **Safeguard 1 (Revenue Summation)**: Explicitly separate measures for `Customer Total MRR` (`customer_analytics`) and `Subscription Total MRR` (`subscriptions_cleaned`). Never combine them in a single DAX measure or visual.
* **Safeguard 2 (Reactivation Churn Filtering)**: `Total Churn Events` explicitly filters `is_reactivation = FALSE` to prevent overcounting churn.
* **Safeguard 3 (Missing Value Handling)**: `Average Satisfaction Score` uses DAX `AVERAGE()`, which naturally ignores missing/NULL values. Satisfaction scores are NOT coerced to 0.

---

## 6. Dashboard Architecture (5-Page Layout)

### Page 1 — Executive Overview
* **Business Purpose**: High-level C-suite summary of revenue health, customer churn rates, and priority retention exposure.
* **KPI Header**: Total Customers (500) | Active Customers (390) | Customer Churn Rate (22.0%) | Active Customer MRR ($8.98M) | Customer Total ARR ($136.06M) | Retention Exposure ($7.16M).
* **Core Visuals**:
  1. Monthly Churn Event Trend (Line chart)
  2. Customer Churn Rate by Industry (Horizontal Bar chart — DevTools highlighted at 30.97%)
  3. Revenue by Plan Tier (Donut chart — Enterprise concentration)
  4. Retention Priority Distribution (Stacked Bar chart: Monitor 152 / Priority 239 / Critical 109)
  5. MRR Exposure by Retention Priority (Clustered Bar chart: Critical $2.86M / Priority $4.31M)

### Page 2 — Customer Intelligence
* **Business Purpose**: Deep-dive into customer demographics, acquisition channels, and plan adoption.
* **Core Visuals**:
  1. Customers by Industry & Country (Matrix / Bar chart)
  2. Plan Tier & Seat Distribution (Column chart)
  3. Trial vs. Non-Trial Churn Rate (Clustered Column chart: Trial 25.77% vs Non-Trial 21.09%)
  4. Referral Source Performance (Horizontal Bar chart)

### Page 3 — Churn Intelligence
* **Business Purpose**: Identify root causes of churn, tenure dynamics, support friction, and reactivations.
* **Core Visuals**:
  1. Churn Rate by Tenure Group (Column chart: 0-6m 16.56%, 6-12m 22.31%, 12-18m 24.58%, 18+m 26.36%)
  2. Subscription Churn Rate by Plan Tier (Bar chart: 9.72% overall)
  3. Observed Churn Event Reasons (Horizontal Bar chart: Features, Support, Budget)
  4. Support Escalation vs. Churn Rate (Clustered Bar chart: High Escalation 25.27% vs Low Escalation 21.27%)
  5. Reactivation Breakdown (Donut chart & KPI Card: 10.17% reactivations)

### Page 4 — Revenue Intelligence
* **Business Purpose**: Detailed financial analysis of recurring revenue (MRR/ARR), plan tier concentration, and top accounts.
* **Core Visuals**:
  1. MRR & ARR Overview (KPI Cards: `Subscription Total MRR` $11.34M, `Active Subscription MRR` $10.16M, `Churned Subscription MRR` $1.18M)
  2. Revenue Share by Plan Tier (Donut / Treemap chart — Enterprise concentration)
  3. Active vs. Churned Subscription Revenue (Stacked Bar chart)
  4. Revenue by Billing Frequency (Column chart — Monthly vs Annual)
  5. Top 20 Customers by MRR (Interactive Table)

### Page 5 — Retention Strategy
* **Business Purpose**: Turn data insights into actionable Customer Success interventions and account prioritization.
* **Core Visuals**:
  1. Retention Priority KPI Cards (Critical: 109, Priority: 239, Monitor: 152, Critical Active: 80)
  2. Critical Active Account Exposure (Metric Cards: Critical Active MRR $2.86M, Total Exposure $7.16M)
  3. Customer Retention Action Matrix (Data Table with conditional formatting: Red for Critical, Yellow for Priority, Blue for Monitor)
  4. Repeated Historical Churn Visual (Filtered Matrix Table for active accounts with >1 churn event)

---

## 7. Actionable Business Interpretation & Retention Playbook

| Risk Factor / Segment | Empirical Finding | Strategic CS Interpretation | Actionable Recommendation |
|---|---|---|---|
| **High Revenue (Enterprise)** | Enterprise accounts drive revenue concentration | High financial impact per lost customer | Assign dedicated Technical Account Managers (TAMs) and conduct quarterly executive business reviews (EBRs). |
| **Long Tenure (18+ Months)** | Churn rate rises to 26.36% for 18+ month tenure | Contract fatigue and stale feature adoption | Initiate proactive renewal reviews 90 days prior to contract expiration; offer upgrade incentives. |
| **Support Escalation ($\ge 5\%$)** | High escalation accounts churn at 25.27% vs 21.27% | Friction in customer experience drives churn | Establish an automated CS trigger for accounts with >2 escalated tickets; fast-track support resolution. |
| **Repeated Churn Events** | Active high-value accounts have historical churn events | Product-market fit or pricing instability | Implement custom retention offers, product training, and feature request tracking. |

---

## 8. Pre-Import Verification Checklist

- [x] **Check 1**: Total Customers = **500**.
- [x] **Check 2**: Active Customers = **390**, Churned Customers = **110**.
- [x] **Check 3**: Customer Churn Rate = **22.00%**.
- [x] **Check 4**: Total Subscriptions = **5,000**, Subscription Churn Rate = **9.72%**.
- [x] **Check 5**: Customer Total MRR = **$11,338,747**, Customer Total ARR = **$136,064,964**.
- [x] **Check 6**: Active Customer MRR = **$8,983,502**, Churned Customer MRR = **$2,355,245**.
- [x] **Check 7**: Active Subscription MRR = **$10,159,608**, Churned Subscription MRR = **$1,179,139** (Revenue Lost).
- [x] **Check 8**: Retention Priority Counts: Critical = **109**, Priority = **239**, Monitor = **152**.
- [x] **Check 9**: Critical Active Customers = **80**.
- [x] **Check 10**: Critical Active MRR Exposure = **$2,857,641**, Priority Active MRR Exposure = **$4,307,073**, Retention Exposure Total = **$7,164,714**.
- [x] **Check 11**: Churn Event Logs = **600** total, Reactivation Events = **61** (10.17%), Genuine Churn Events = **539**.
- [x] **Check 12**: DevTools Industry Churn Rate = **30.97%** (Highest customer churn industry).
- [x] **Check 13**: Tenure Group Churn Rates: 0–6m (**16.56%**), 6–12m (**22.31%**), 12–18m (**24.58%**), 18+m (**26.36%**).

---

### Files Updated in This Step

1. `PowerBI/dax_measures.dax` (Relative path: `PowerBI/dax_measures.dax`)
2. `PowerBI/powerbi_dashboard_guide.md` (Relative path: `PowerBI/powerbi_dashboard_guide.md`)
3. `Documentation/powerbi_data_model.md` (Relative path: `Documentation/powerbi_data_model.md`)
