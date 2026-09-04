# RetentionIQ — Power BI Dashboard Implementation & Assembly Guide

**Project Title**: RetentionIQ — Customer Retention & Revenue Intelligence  
**Dataset**: Simulated SaaS Account, Subscription, Usage, Support, and Churn Event Data  
**Author**: Data Analyst  
**Document Version**: 1.1 (Reconciled Metrics Edition)  
**Relative Path**: `PowerBI/powerbi_dashboard_guide.md`

---

## 1. Executive Implementation Overview

This guide provides the exact step-by-step assembly instructions for constructing the 5-page portfolio-ready Power BI dashboard for **RetentionIQ**.

### Authoritative Validated Baseline Metrics

Before building visuals, ensure your calculations match these validated baseline figures:

* **Total Customers**: 500
* **Active Customers**: 390
* **Churned Customers**: 110
* **Customer Churn Rate**: **22.00%**
* **Total Subscriptions**: 5,000
* **Churned Subscriptions**: 486
* **Subscription Churn Rate**: **9.72%**

#### Customer-Level Revenue Metrics (`customer_analytics`)
* **Customer Total MRR**: **$11,338,747**
* **Customer Total ARR**: **$136,064,964**
* **Active Customer MRR**: **$8,983,502**
* **Churned Customer MRR**: **$2,355,245**
* **Average Customer MRR**: **$22,677.49**

#### Subscription-Level Revenue Metrics (`subscriptions_cleaned`)
* **Subscription Total MRR**: **$11,338,747**
* **Active Subscription MRR**: **$10,159,608**
* **Churned Subscription MRR**: **$1,179,139** *(Genuinely lost revenue from terminated subscription contracts)*

#### Retention Priority Breakdown & Active Revenue Exposure (`customer_analytics`)
* **Monitor**: 152 accounts (123 Active, 29 Churned)
* **Priority**: 239 accounts (187 Active, 52 Churned)
* **Critical**: 109 accounts (80 Active, 29 Churned)
* **Critical Active Customers**: **80**
* **Critical Active MRR Exposure**: **$2,857,641**
* **Priority Active MRR Exposure**: **$4,307,073**
* **Retention Exposure Total (Active MRR at Risk)**: **$7,164,714**

#### Lifecycle Events & Support Metrics
* **Total Churn Event Logs**: 600
* **Reactivation Events**: 61 (10.17% reactivation rate)
* **Genuine Churn Events**: **539** (`is_reactivation = FALSE`)
* **Tenure Cohort Churn Rates**:
  - 0–6 Months: **16.56%**
  - 6–12 Months: **22.31%**
  - 12–18 Months: **24.58%**
  - 18+ Months: **26.36%**

---

## 2. Step-by-Step Power BI Desktop Setup

### Step 1: Import Data Tables via Power Query
1. Open Power BI Desktop and select **Get Data → Text/CSV** or open **Power Query Editor → Advanced Editor**.
2. Copy and paste the M scripts provided in `PowerBI/power_query_setup.m`.
3. Import the **5 cleaned tables**:
   - `customer_analytics.csv` (500 rows)
   - `subscriptions_cleaned.csv` (5,000 rows)
   - `support_tickets_cleaned.csv` (2,000 rows)
   - `churn_events_cleaned.csv` (600 rows)
   - `feature_usage_cleaned.csv` (25,000 rows)
   
> [!IMPORTANT]  
> **Do NOT import `accounts_cleaned.csv`**. `customer_analytics` already contains all 9 account demographic columns plus calculated metrics and retention priority attributes.

### Step 2: Establish Model Relationships
Navigate to the **Model View** and verify the following 1-to-Many (`1:*`) single-direction relationships:

1. `customer_analytics[account_id]` `1 ── *` `subscriptions_cleaned[account_id]` (Active)
2. `customer_analytics[account_id]` `1 ── *` `support_tickets_cleaned[account_id]` (Active)
3. `customer_analytics[account_id]` `1 ── *` `churn_events_cleaned[account_id]` (Active)
4. `subscriptions_cleaned[subscription_id]` `1 ── *` `feature_usage_cleaned[subscription_id]` (Active)

### Step 3: Create `DimDate` Table & Set Date Relationships
1. Select **Modeling → New Table** and paste:
   ```dax
   DimDate = 
   VAR MinYear = YEAR(MIN(subscriptions_cleaned[start_date]))
   VAR MaxYear = YEAR(MAX(subscriptions_cleaned[start_date]))
   RETURN
   ADDCOLUMNS(
       CALENDAR(DATE(MinYear, 1, 1), DATE(MaxYear, 12, 31)),
       "Year", YEAR([Date]),
       "MonthNo", MONTH([Date]),
       "MonthName", FORMAT([Date], "MMM"),
       "MonthYear", FORMAT([Date], "MMM YYYY"),
       "Quarter", "Q" & FORMAT([Date], "Q"),
       "YearQuarter", YEAR([Date]) & "-Q" & FORMAT([Date], "Q"),
       "DayOfWeek", FORMAT([Date], "ddd"),
       "DayOfWeekNo", WEEKDAY([Date], 2),
       "YearMonthNo", YEAR([Date]) * 100 + MONTH([Date])
   )
   ```
2. Mark `DimDate` as a Date Table (Right-click `DimDate` → **Mark as date table** → select `Date`).
3. Connect `DimDate` to fact tables:
   - `DimDate[Date]` `1 ── *` `subscriptions_cleaned[start_date]` (**Active**)
   - `DimDate[Date]` `1 ── *` `customer_analytics[signup_date]` (**Inactive**)
   - `DimDate[Date]` `1 ── *` `churn_events_cleaned[churn_date]` (**Inactive**)
   - `DimDate[Date]` `1 ── *` `support_tickets_cleaned[submitted_at]` (**Inactive**)
   - `DimDate[Date]` `1 ── *` `feature_usage_cleaned[usage_date]` (**Inactive**)

### Step 4: Import DAX Measures
Create a new measure table `_Measures` and load all measures from `PowerBI/dax_measures.dax`. Organize them into display folders:
* `1. Customer KPIs`
* `2. Subscription KPIs`
* `3. Customer Revenue`
* `4. Subscription Revenue`
* `5. Retention Exposure`
* `6. Churn Event Metrics`
* `7. Support Metrics`
* `8. Customer Behavior`
* `9. Date Measures`

---

## 3. Page-by-Page Visual Construction Guide

### Common Page Header System
Every page must feature a clean top header banner:
* **Header Title**: `RetentionIQ`
* **Header Subtitle**: `Customer Retention & Revenue Intelligence`
* **Page Specific Title**: Displayed on top-left of visual canvas.
* **Global Canvas Settings**: 16:9 ratio (1280 x 720 px), light slate background (`#F8F9FA`).

---

### PAGE 1 — EXECUTIVE OVERVIEW

* **Page Subtitle**: *Executive summary of customer health, churn rates, MRR, and retention priority revenue exposure.*

#### 1. Top KPI Card Container (6 Cards across top)
* **Card 1 — Total Customers**: Measure `[Total Customers]` | Format: Whole Number (`500`)
* **Card 2 — Active Customers**: Measure `[Active Customers]` | Format: Whole Number (`390`)
* **Card 3 — Customer Churn Rate**: Measure `[Customer Churn Rate]` | Format: Percentage (`22.00%`)
* **Card 4 — Active Customer MRR**: Measure `[Active Customer MRR]` | Format: Currency (`$8,983,502`)
* **Card 5 — Customer Total ARR**: Measure `[Customer Total ARR]` | Format: Currency (`$136,064,964`)
* **Card 6 — Retention Exposure**: Measure `[Retention Exposure Total]` | Format: Currency (`$7,164,714`)

#### 2. Main Visual Canvas
* **Visual 1 — Monthly Churn Event Trend (Line Chart)**:
  * *X-Axis*: `DimDate[MonthYear]` (Sorted by `DimDate[YearMonthNo]`)
  * *Y-Axis*: `[Churn Event Trend]` (Measure using `USERELATIONSHIP` on `churn_date`)
  * *Title*: `Monthly Churn Event Trend`
* **Visual 2 — Customer Churn Rate by Industry (Horizontal Bar Chart)**:
  * *Y-Axis*: `customer_analytics[industry]`
  * *X-Axis*: `[Customer Churn Rate]`
  * *Formatting*: Bar color `#3B82F6`; highlight DevTools bar in `#DC2626` (30.97%).
  * *Title*: `Customer Churn Rate by Industry`
* **Visual 3 — Revenue by Plan Tier (Donut Chart)**:
  * *Legend*: `customer_analytics[plan_tier]`
  * *Values*: `[Customer Total MRR]`
  * *Title*: `Customer MRR Share by Plan Tier` (Enterprise concentration)
* **Visual 4 — Retention Priority Distribution (Stacked Bar Chart)**:
  * *Y-Axis*: `customer_analytics[retention_priority]` (Order: Critical, Priority, Monitor)
  * *X-Axis*: `[Total Customers]`
  * *Data Colors*: Critical (`#DC2626`), Priority (`#D97706`), Monitor (`#2563EB`)
  * *Title*: `Customer Base by Retention Priority Tier` (109 Critical / 239 Priority / 152 Monitor)
* **Visual 5 — MRR Exposure by Retention Priority (Clustered Bar Chart)**:
  * *Y-Axis*: `customer_analytics[retention_priority]`
  * *X-Axis*: `[Retention Exposure Total]`
  * *Title*: `Active Customer MRR at Risk by Retention Priority` ($2.86M Critical / $4.31M Priority)

---

### PAGE 2 — CUSTOMER INTELLIGENCE

* **Page Subtitle**: *Analysis of customer demographics, acquisition channels, plan tiers, and trial conversions.*

#### 1. Slicer Panel (Left Sidebar / Top Header Controls)
* Slicer 1: `customer_analytics[industry]` (Dropdown)
* Slicer 2: `customer_analytics[plan_tier]` (Dropdown)
* Slicer 3: `customer_analytics[country]` (Dropdown)
* Slicer 4: `customer_analytics[referral_source]` (Dropdown)
* Slicer 5: `customer_analytics[is_trial]` (Buttons / Dropdown)
* Slicer 6: `customer_analytics[customer_status]` (Buttons: Active / Churned)
* Slicer 7: `customer_analytics[retention_priority]` (Dropdown: Monitor / Priority / Critical)

#### 2. Visual Layout
* **Visual 1 — Customer Distribution by Industry (Column Chart)**:
  * *X-Axis*: `customer_analytics[industry]`
  * *Y-Axis*: `[Total Customers]`
  * *Title*: `Customer Count by Industry`
* **Visual 2 — Customers by Plan Tier & Country (Stacked Bar Chart)**:
  * *Y-Axis*: `customer_analytics[country]`
  * *X-Axis*: `[Total Customers]`
  * *Legend*: `customer_analytics[plan_tier]`
  * *Title*: `Geographic Distribution by Plan Tier`
* **Visual 3 — Trial vs. Non-Trial Churn Rate (Clustered Column Chart)**:
  * *X-Axis*: `customer_analytics[is_trial]` (Formatted: Trial / Non-Trial)
  * *Y-Axis*: `[Customer Churn Rate]`
  * *Data Labels*: On (Trial: 25.77% vs Non-Trial: 21.09%)
  * *Title*: `Churn Rate Impact: Trial vs Non-Trial Accounts`
* **Visual 4 — Referral Source Performance (Horizontal Bar Chart)**:
  * *Y-Axis*: `customer_analytics[referral_source]`
  * *X-Axis*: `[Total Customers]`
  * *Tooltip*: `[Customer Churn Rate]`
  * *Title*: `Customer Acquisition by Referral Source`

---

### PAGE 3 — CHURN INTELLIGENCE

* **Page Subtitle**: *Investigation of churn factors across tenure groups, plan tiers, support escalation, and reactivations.*

#### 1. KPI Cards
* Card 1: `[Customer Churn Rate]` (22.00%)
* Card 2: `[Subscription Churn Rate]` (9.72%)
* Card 3: `[Total Churn Events]` (539 Genuine Events)
* Card 4: `[Churned Subscription MRR]` ($1,179,139 Revenue Lost)
* Card 5: `[Reactivation Rate]` (10.17% / 61 Events)

#### 2. Visual Layout
* **Visual 1 — Churn Rate by Tenure Group (Column Chart)**:
  * *X-Axis*: Calculated Tenure Bins (`0-6 Months`, `6-12 Months`, `12-18 Months`, `18+ Months`)
  * *Y-Axis*: `[Customer Churn Rate]`
  * *Data Labels*: On (0-6m: 16.56%, 6-12m: 22.31%, 12-18m: 24.58%, 18+m: 26.36%)
  * *Title*: `Customer Churn Rate by Tenure Cohort`
* **Visual 2 — Subscription Churn Rate by Plan Tier (Clustered Bar Chart)**:
  * *Y-Axis*: `subscriptions_cleaned[plan_tier]`
  * *X-Axis*: `[Subscription Churn Rate]`
  * *Title*: `Subscription Churn Rate by Plan Tier` (9.72% Overall)
* **Visual 3 — Observed Churn Event Reasons (Horizontal Bar Chart)**:
  * *Y-Axis*: `churn_events_cleaned[reason_code]` (Filtered: `is_reactivation = FALSE`)
  * *X-Axis*: `[Total Churn Events]`
  * *Title*: `Observed Churn Event Reasons` (Features, Support, Budget)
* **Visual 4 — Support Escalation Impact on Churn (Clustered Bar Chart)**:
  * *X-Axis*: Escalation Group (`High Escalation (>=5%)` vs `Low Escalation (<5%)`)
  * *Y-Axis*: `[Customer Churn Rate]`
  * *Data Labels*: High Escalation (25.27%) vs Low Escalation (21.27%)
  * *Title*: `Customer Churn Rate by Support Escalation Level`
* **Visual 5 — Retention Priority vs. Customer Churn (Bar Chart)**:
  * *Y-Axis*: `customer_analytics[retention_priority]`
  * *X-Axis*: `[Customer Churn Rate]`
  * *Title*: `Churn Rate across Retention Priority Tiers` (Critical: 26.61%)

---

### PAGE 4 — REVENUE INTELLIGENCE

* **Page Subtitle**: *Detailed financial analysis of recurring revenue (MRR/ARR), subscription contracts, and top accounts.*

#### 1. Financial KPI Cards
* Card 1: `[Subscription Total MRR]` ($11,338,747)
* Card 2: `[Subscription Total ARR]` ($136,064,964)
* Card 3: `[Active Subscription MRR]` ($10,159,608)
* Card 4: `[Churned Subscription MRR]` ($1,179,139 Revenue Lost)
* Card 5: `[Average Customer MRR]` ($22,677.49)

#### 2. Visual Layout
* **Visual 1 — Revenue Share by Plan Tier (Donut / Treemap Chart)**:
  * *Group*: `subscriptions_cleaned[plan_tier]`
  * *Values*: `[Subscription Total MRR]`
  * *Title*: `Subscription MRR Share by Plan Tier` (Enterprise concentration)
* **Visual 2 — MRR Distribution by Industry (Horizontal Bar Chart)**:
  * *Y-Axis*: `customer_analytics[industry]`
  * *X-Axis*: `[Customer Total MRR]`
  * *Title*: `Customer MRR by Industry`
* **Visual 3 — Active vs. Churned Subscription Revenue (Stacked Bar Chart)**:
  * *Y-Axis*: `subscriptions_cleaned[plan_tier]`
  * *X-Axis*: `[Subscription Total MRR]`
  * *Legend*: `subscriptions_cleaned[churn_flag]` (Active $10.16M / Churned $1.18M)
  * *Title*: `Subscription Revenue: Active vs Churned by Plan`
* **Visual 4 — Revenue by Billing Frequency (Clustered Column Chart)**:
  * *X-Axis*: `subscriptions_cleaned[billing_frequency]` (Monthly vs Annual)
  * *Y-Axis*: `[Subscription Total MRR]`
  * *Title*: `Subscription Revenue by Billing Frequency`
* **Visual 5 — Top 20 Customers by MRR (Interactive Table)**:
  * *Columns*: `account_name`, `industry`, `plan_tier`, `customer_status`, `total_mrr`, `total_arr`, `retention_priority`
  * *Sorting*: `total_mrr` Descending
  * *Title*: `Top 20 Customers by Monthly Recurring Revenue`

---

### PAGE 5 — RETENTION STRATEGY

* **Page Subtitle**: *Actionable retention prioritization matrix, high-risk account lists, and Customer Success playbooks.*

#### 1. Strategic Priority KPI Cards
* Card 1: `[Critical Customers]` (109 Accounts)
* Card 2: `[Priority Customers]` (239 Accounts)
* Card 3: `[Monitor Customers]` (152 Accounts)
* Card 4: `[Critical Active Customers]` (80 Accounts)
* Card 5: `[Critical Active MRR Exposure]` ($2,857,641)
* Card 6: `[Retention Exposure Total]` ($7,164,714 Active MRR at Risk)

#### 2. Main Customer Retention Action Matrix (Data Table)
* **Table Fields**:
  - `customer_analytics[account_name]`
  - `customer_analytics[industry]`
  - `customer_analytics[plan_tier]`
  - `customer_analytics[customer_status]`
  - `customer_analytics[total_mrr]` (Format: `$#,##0`)
  - `customer_analytics[tenure_months]` (Format: `0.0`)
  - `customer_analytics[escalation_rate]` (Format: `0.0%`)
  - `customer_analytics[retention_priority]`
  - `customer_analytics[priority_reason]`
  - `customer_analytics[total_churn_events]`
* **Conditional Formatting Rules**:
  - Apply Background Color to `retention_priority` column:
    - `Critical` → Light Red / Muted Crimson (`#FEE2E2` text `#991B1B`)
    - `Priority` → Light Amber / Warm Yellow (`#FEF3C7` text `#92400E`)
    - `Monitor` → Light Blue / Slate (`#E0F2FE` text `#075985`)

#### 3. Repeated Historical Churn Visual (Matrix Table)
* **Filters**: `customer_analytics[customer_status] = "Active"` AND `customer_analytics[total_churn_events] > 1`
* **Columns**: `account_name`, `industry`, `plan_tier`, `total_mrr`, `total_churn_events`, `total_refund`
* **Title**: `High-Value Active Accounts with Repeated Historical Churn Events`

#### 4. Actionable Retention Playbook (Text / Card Panel)
Include a clean structured text panel outlining operational CS playbooks:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       ACTIONABLE RETENTION PLAYBOOK                         │
├─────────────────────────────────────────────────────────────────────────────┤
│ 1. HIGH REVENUE (Enterprise Accounts >= $5,000 MRR)                         │
│    -> Protect high-value accounts with dedicated TAMs & Executive Reviews.   │
│                                                                             │
│ 2. LONG TENURE (Accounts >= 12 Months)                                      │
│    -> Conduct proactive contract renewal & product health reviews at 90 days│
│                                                                             │
│ 3. SUPPORT ESCALATION (Escalation Rate >= 5%)                               │
│    -> Trigger automatic CS alerts & fast-track technical resolution.        │
│                                                                             │
│ 4. REPEATED HISTORICAL CHURN                                                │
│    -> Prioritize customized retention offers & executive outreach.          │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Quality Control & Model Verification Checklist

Before publishing or sharing the Power BI dashboard, run these 15 mandatory verification checks:

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
- [x] **Check 14**: Support Escalation Churn: High Escalation (25.27%) vs Low Escalation (21.27%).
- [x] **Check 15**: Trial vs Non-Trial Churn: Trial (25.77%) vs Non-Trial (21.09%).

---

## 5. Next Steps for Portfolio Presentation

1. Complete the assembly in Power BI Desktop following the visual guides above.
2. Export screenshots of all 5 pages into the `Screenshots/` directory (`Screenshots/page1_executive_overview.png`, etc.).
3. Save the final Power BI file as `PowerBI/RetentionIQ.pbix`.
