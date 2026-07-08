# 🚀 Telehealth Compliance & Marketing ROI Audit 📊
*A portfolio case study utilizing synthetically generated business data to demonstrate advanced Google BigQuery SQL, data pipeline engineering, and compliance auditing.*

## 📌 Project Overview
A fast-growing telehealth startup was preparing for an executive board meeting to finalize next quarter's marketing budget. However, the Finance department flagged a serious concern: were network crashes causing the automated system to mistakenly bill patients for virtual sessions that never successfully connected? 

To solve this, basic SQL wasn't enough. I built a robust Google BigQuery data pipeline to process messy, real-world application data. By flattening nested JSON telemetry payloads, standardizing corrupted dates via defensive casting, converting epoch timestamps, and resolving Slowly Changing Dimensions (SCD Type 2), I established a clean dimensional model. I then executed a rigorous compliance audit using defensive anti-joins to verify billing integrity before calculating True Marketing ROI.

**⚙️ Core Stack & Heavy Hitters:** Google BigQuery (SQL), JSON/Array Parsing (`JSON_VALUE`), Defensive Casting (`COALESCE`, `SAFE.PARSE_DATE`), Epoch Conversion (`TIMESTAMP_SECONDS`), Set-Based Conditional Aggregation (`COUNTIF`), and Anti-Joins.

---

## 🎯 Executive Summary: My Key Discoveries
If you only have a minute, here are the major business insights I uncovered during this audit:
* 🛡️ **Compliance Audit:** I audited the billing records against backend telemetry to check for disconnected sessions. In the dataset tested, I found no evidence of bills being generated without a successful video connection.
* 💰 **Attention vs. Intent:** Social media channels (TikTok/Meta) drive high traffic (~3,400 patients each) but yield a lower return (**~$647 Net Revenue per user**). Email drives slightly less traffic (~3,000 patients) but yields a significantly higher return (**~$3,462 Net Revenue per user**).
* 🌍 **Demographic Drivers:** The high lifetime value (LTV) from the Email channel is driven by an older demographic (average age 71) who generally have higher medical needs compared to the younger audience captured on TikTok.
* 📉 **Session Abandonments:** By mapping behavioral telemetry, I isolated a specific network latency issue causing session timeouts and tracked users who abandoned the virtual waiting room before a doctor connected.

---

## 🧠 SQL Skills Demonstrated
Here are the core technical and analytical skills I applied throughout this project:
* **JSON & Semi-Structured Data Parsing:** Flattened nested telemetry payloads using BigQuery's `JSON_VALUE()` to extract hardware specs and array-based metrics (e.g., `$.net[0].ping`).
* **Defensive Engineering & Date Handling:** Standardized corrupted, multi-format dates using `COALESCE()` and `SAFE.PARSE_DATE()`, and converted epoch timestamps into human-readable strings using `DATETIME(TIMESTAMP_SECONDS())`.
* **Set-Based Thinking & Conditional Aggregation:** Pivoted away from procedural row-by-row logic, transforming event logs into set-based analytical states using `COUNTIF()` and `CASE WHEN`.
* **Slowly Changing Dimensions (SCD Type 2):** Managed historical patient profile updates using active flags (`is_current = 1`) to prevent data duplication and ensure accurate CAC math.
* **Defensive Auditing (Anti-Joins):** Executed strategic `LEFT JOIN`s and hunted for `NULL` states to audit disconnected databases and prove the absence of ghost claims.

---

## 🛠️ My 6 Audit Steps (Problems, Solutions, & Findings)

### 🏗️ 01_staging_layer (Data Engineering)
* **The Problem:** Raw healthcare data across campaigns, patients, telemetry, and billing contained messy strings, mixed date formats, and deeply nested JSON payloads, requiring repeatable cleaning before analysis.
* **What I Did:** I built 6 automated staging views to sanitize the raw inputs. This involved flattening JSON telemetry payloads, defensively parsing multi-format strings, and safely casting data types (`SAFE_CAST`) to establish a clean, production-ready foundation.

graph TD
    %% Define Raw Data Layer
    subgraph "Raw Source Layer (Messy CSVs / Inconsistent Formats)"
        A1[raw.dim_campaigns]
        A2[raw.dim_patients_scd]
        A3[raw.fact_billing]
        A4[raw.fact_sessions]
        A5[raw.fact_support_tickets]
        A6[raw.fact_telemetry]
    end

    %% Define Engineering Transforms
    subgraph "BigQuery Staging Views (Heavy-Hitter Transformations)"
        B1("UPPER / TRIM Standardization")
        B2("COALESCE / SAFE.PARSE_DATE Timeline Anchoring")
        B3("Currency Stripping & Numeric CAST")
        B4("SAFE.PARSE_DATETIME Standardization")
        B5("Datetime Transformation & Backup Flags")
        B6("JSON_VALUE Payload Flattening & Epoch Conversion")
    end

    %% Define Staging Layer Output
    subgraph "Cleared Production Staging Layer (Optimized for Analytics)"
        C1[raw.clean_campaigns]
        C2[raw.clean_patients_scd]
        C3[raw.clean_billing]
        C4[raw.clean_sessions]
        C5[raw.clean_support_tickets]
        C6[raw.clean_telemetry]
    end

    %% Connect Flow
    A1 --> B1 --> C1
    A2 --> B2 --> C2
    A3 --> B3 --> C3
    A4 --> B4 --> C4
    A5 --> B5 --> C5
    A6 --> B6 --> C6

    %% Styling
    classDef raw fill:#ffdde1,stroke:#333,stroke-width:1px;
    classDef transform fill:#ffeaa7,stroke:#333,stroke-width:1px;
    classDef clean fill:#d4edda,stroke:#333,stroke-width:1px;
    
    class A1,A2,A3,A4,A5,A6 raw;
    class B1,B2,B3,B4,B5,B6 transform;
    class C1,C2,C3,C4,C5,C6 clean;

---

### 📊 07_demographic_acquisition_matrix.sql
* **The Problem:** The marketing team needed to map age groups to acquisition channels, but basic row-counting was double-counting patients due to historical profile updates.
* **What I Did:** I handled Slowly Changing Dimensions (SCD) by filtering for `is_current = 1` and dynamically calculated patient ages using `CURRENT_DATE()` to ensure accurate Customer Acquisition Cost (CAC) and LTV math.
* **My Audit Findings:** CAC is identical across all channels at roughly **$13.50 per acquisition**. However, Email generates an older demographic with a **$1,898 Lifetime Value**, while TikTok yields a younger demographic with only a **$100 LTV**.

![Demographic LTV Matrix Chart](assets/demographic_acquisition_matrix.png)

---

### 📡 08_latency_crash_threshold.sql
* **The Problem:** The telehealth application was experiencing dropped calls, but Engineering lacked data on the exact network threshold causing the crashes.
* **What I Did:** I analyzed the backend telemetry ping logs against successful and failed video sessions to find the breaking point of the software.
* **My Audit Findings:** I identified a consistent `999` ping spike. The data indicated that sessions hitting this latency threshold reliably triggered a backend network timeout.

![Latency Crash Threshold Graph](assets/latency_crash_threshold.png)

---

### 📉 09_patient_abandonments.sql
* **The Problem:** Product managers couldn't track how patients were reacting to wait times using standard clinical logs.
* **What I Did:** I used conditional aggregation (`COUNTIF`) on the raw app telemetry logs to map user behavior states against network performance.
* **My Audit Findings:** I successfully isolated a cohort of session abandonments—patients who dropped out of the virtual waiting room out of frustration after initializing the app, but before the doctor connected.

![Patient Abandonment Funnel](assets/patient_abandonments.png)

---

### 🛡️ 10_ghost_revenue_audit.sql
* **The Problem:** Finance needed to ensure we were not accidentally billing Medicare or insurance providers for dropped sessions and waiting room abandonments. 
* **What I Did:** I ran a financial audit using a defensive `LEFT JOIN` from the billing master table, utilizing a `NULL` filter to catch any orphaned financial records that lacked backend telemetry.
* **My Audit Findings:** The query returned exactly 0 rows. In the dataset tested, every single billed session was tied to a successful `VIDEO_LIVE` handshake, meaning the audit found no evidence of refund-triggering ghost claims.

![Ghost Revenue Audit Table](assets/ghost_revenue_audit.png)

---

### 🏆 11_true_campaign_roi.sql
* **The Problem:** With the compliance audit cleared, leadership needed the final financial numbers to allocate next quarter's budget.
* **What I Did:** I bridged three distinct databases (Patients → Sessions → Billing) and calculated the true net revenue per acquisition channel.
* **My Audit Findings:** The data revealed a massive baseline split between audience attention and intent. Against a flat $13.50 CAC, TikTok and Meta drove high traffic but yielded only **$647 in True Net Revenue per user**. Email drove less traffic but yielded **$3,462 in True Net Revenue per user**. Based on this, I recommended shifting the heavy conversion budget toward Email and Search.

![True Campaign ROI Dashboard](assets/true_campaign_roi.png)

---

## 📂 Repository Structure

* **/assets**: Contains all images, charts, and KPI callout visualizations used throughout this README to present audit findings.
* **/01_staging_layer**: Contains the core `CREATE OR REPLACE VIEW` scripts used to clean, format, and stage the raw data.
  * `01_clean_campaigns.sql`
  * `02_clean_patients_scd.sql`
  * `03_stg_billing.sql`
  * `04_sessions.sql`
  * `05_support_tickets.sql`
  * `06_telemetry.sql`
* **/02_analytics_layer**: Houses the sequential SQL scripts where I performed the behavioral analysis, the compliance audit, and the final ROI calculations.
  * `07_demographic_acquisition_matrix.sql`
  * `08_latency_crash_threshold.sql`
  * `09_patient_abandonments.sql`
  * `10_ghost_revenue_audit.sql`
  * `11_true_campaign_roi.sql`