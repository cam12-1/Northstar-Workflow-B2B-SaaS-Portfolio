# Northstar SaaS | Business Performance Analysis

A SQL and Power BI portfolio project investigating customer growth, revenue collection, subscription churn, product engagement, sales performance and customer support for a fictional B2B SaaS business.

## Dashboard Preview

<img width="1446" height="810" alt="image" src="https://github.com/user-attachments/assets/e6721764-5508-446e-8dc4-dedb8eb1b34c" />

Example: Northstar Executive Dashboard

<img width="1443" height="807" alt="image" src="https://github.com/user-attachments/assets/9fa401d0-2c85-4cd6-adfd-45f229790beb" />

**Tools:** MySQL · Power BI

## Project Overview

Northstar is a fictional B2B SaaS company providing workflow automation software through four subscription plans: Starter, Growth, Professional and Enterprise.

In this simulated business case, the Head of Operations and Finance Director need a clearer view of business performance, potential operational risks and areas requiring further investigation.

I used SQL to validate and analyse relational business data, then developed Power BI dashboards to communicate key metrics and findings. The objective was not simply to report numbers, but to understand what they could mean for the business and identify practical next steps.

## Business Questions

The analysis covers six areas:

1. **Customer growth and acquisition:** How is the customer base growing, and what patterns appear across acquisition channels?
2. **Revenue and collections:** How much invoice value is overdue, and where should collection follow-up be prioritised?
3. **Retention and churn:** What patterns are visible in subscription cancellations?
4. **Product engagement:** Do average usage patterns differ between active and churned customers?
5. **Sales pipeline:** How are opportunities progressing through the sales process?
6. **Customer support:** What do ticket volumes and resolution times reveal about support operations?

## Key Findings

### 1. Overdue invoices represent a significant collection concern

The analysis identified approximately **$2.85 million in overdue invoice value**.

**Business implication:** Management could use an invoice-level review to prioritise collection follow-up, investigate older outstanding balances and assess whether overdue amounts are concentrated among particular customers.

### 2. Churn rates are similar across acquisition channels

Observed churn rates across acquisition channels ranged from approximately **30.3% to 32.7%**.

**Business implication:** The relatively narrow range does not identify a clearly distinct channel-level churn problem. Further investigation of customer tenure, subscription plans and cancellation patterns would help determine where retention efforts may be most useful.

### 3. Average usage alone does not distinguish churned customers

Average usage-event counts were approximately **20.01 per active customer and 19.98 per churned customer** in the analysis.

**Business implication:** Overall event volume alone does not provide a clear separation between the two groups. Further analysis of usage recency, engagement trends and specific event types may be more informative.

### 4. A December 2025 churn anomaly requires validation

Of 2,430 subscriptions recorded as churned in December 2025, **2,178 had an end date of 31 December 2025**.

**Business implication:** This concentration should be investigated before drawing conclusions about the underlying churn trend. Possible explanations to examine include bulk cancellations, common contract end dates or data-processing issues.

*These findings describe patterns in a fictional portfolio dataset. They do not establish causation, and the December 2025 anomaly limits interpretation of that period.*

## Tools and Techniques

**MySQL**
- Data quality checks, including missing values, duplicates and unusual records
- Joins and aggregations across relational tables
- Subqueries, common table expressions (CTEs) and window functions
- KPI calculations and exploratory analysis
- Investigation of anomalous results and validation of findings

**Power BI**
- KPI cards and business performance dashboards
- Trend analysis and comparisons across business segments
- Visual communication of findings for non-technical stakeholders

## Analytical Approach

1. **Validate:** Check data completeness, uniqueness, relationships and unusual values.
2. **Investigate:** Use SQL to answer defined business questions and calculate relevant metrics.
3. **Verify:** Cross-check important findings and investigate results that may be affected by data quality or query logic.
4. **Communicate:** Present key metrics and patterns in Power BI.
5. **Recommend:** Identify practical next steps while distinguishing evidence from assumptions.

## Project Deliverables

- **SQL analysis:** [View SQL scripts](SQL/)
- **Power BI dashboard:** [View Power BI report](Power%20BI/)
- **Dashboard screenshots:** [View report previews](Screenshots/)
- **Business analysis brief:** [View business brief](Northstar_Business_Brief.pdf)

## Data Quality and Limitations

Northstar is a fictional business created for portfolio purposes; this project was not commissioned by a real client.

- **Payment discrepancy:** A negative payment of $25 was linked to an invoice marked Paid with a value of $97, creating a $122 discrepancy. The reason could not be established from the available data.
  
- **December churn anomaly:** Of 2,430 subscriptions marked as churned in December 2025, 2,178 had an end date of 31 December 2025. This requires validation before conclusions are drawn about that month's churn trend.
  
- **Usage analysis:** Average usage-event counts were almost identical for active and churned customers. Further analysis of specific product activities and engagement patterns may help identify more informative indicators of churn risk.
  
- **Dataset limitations:** Northstar is a fictional portfolio dataset. The findings identify patterns and areas for further investigation; they do not establish causation.

## About This Project

This project demonstrates my approach to using SQL and Power BI to investigate business questions, validate data, communicate findings and identify evidence-based next steps.

**Analyst:** Cameron Moore
