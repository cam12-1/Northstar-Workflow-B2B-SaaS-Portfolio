# Northstar Workflow — Semantic Model Notes

## 1. Purpose

The Power BI semantic model organises customer, subscription, invoice, payment, usage and sales data so that business metrics can be calculated and interpreted consistently.

This document records KPI definitions, SQL validation results, data relationships, filter behaviour and known limitations. Detailed SQL queries are maintained separately in the project’s SQL scripts.

## 2. Financial Measures

### Overdue Invoice Value

- **Definition:** Sum of invoice amounts for invoices marked as overdue.
- **Power BI measure:** `Overdue Invoice Value`
- **SQL result:** $2,846,303.00
- **Validation:** SQL and Power BI returned the same value.
- **Limitation:** Sixty invoices have missing amounts, including two marked as overdue. The measure excludes missing amounts, so the reported value does not necessarily represent the complete outstanding balance.

### Overdue Invoice Count

- **Definition:** Number of distinct invoices marked as overdue.
- **Power BI measure:** `Overdue Invoice Count`
- **SQL result:** 13,043
- **Validation:** SQL and Power BI returned the same count.

### Total Revenue Collected

- **Definition:** Sum of recorded payment amounts.
- **Power BI measure:** `Total Revenue Collected`
- **SQL result:** $44,260,183.10
- **Validation:** The unfiltered Power BI card matched the SQL result.
- **Limitation:** The total includes one unexplained negative payment of $25.00. The associated customer and invoice were investigated, but the available data did not establish a valid business explanation. The record remains an anomaly requiring further investigation.

## 3. Customer and Subscription Measures

### Overall Churn Rate

- **Definition:** Number of subscription records marked as churned divided by the total number of subscription records.
- **SQL result:** Approximately 27%.
- **Validation:** SQL and Power BI results matched.
- **Interpretation:** This is the proportion of subscription records currently marked as churned, not a monthly churn rate.

### Customer Churn by Acquisition Channel

- **Definition:** Distinct customers with at least one churned subscription divided by distinct customers in the relevant acquisition channel.
- **Validation:** SQL and Power BI churn rates matched.
- **Interpretation:** This measures the proportion of customers with churned subscriptions. It does not necessarily represent customers who have permanently left the business, since customers may have multiple subscriptions.

### Early and Late Churn

- **Definition:** Churned subscriptions are classified as early churn when the duration is 30 days or fewer, and late churn when it exceeds 30 days.
- **Calculation:** Difference in days between subscription end date and start date.
- **Exclusions:** Churned subscriptions without a recorded start or end date are excluded.
- **Validation:** SQL and Power BI counts matched.

### Average Events per Customer

- **Definition:** Total recorded usage events divided by distinct customers with at least one recorded usage event, grouped by customer status.
- **Validation:** SQL and Power BI results matched.

| Customer status | Total events | Customers with events | Average events per customer |
|---|---:|---:|---:|
| Active | 190,123 | 9,500 | 20.01 |
| Churned | 109,877 | 5,500 | 19.98 |

**Finding:** Average usage-event volume is almost identical between active and churned customers.

**Limitation:** Customers with no recorded usage events are excluded from the denominator. The comparison does not establish causation or rule out differences in engagement recency or event type.

### Average Tenure at Churn

- **Definition:** Average number of days between subscription start and end dates for churned subscriptions with both dates recorded.
- **SQL result:** 188.687 days before rounding, or approximately 188.69 days.
- **Power BI validation:** Not applicable; this metric is not displayed on the current dashboard.
- **Limitation:** This measures subscription tenure, not necessarily customer tenure, because customers may have multiple subscriptions.

## 4. Sales Measures

### Overall Win Rate

- **Definition:** Won opportunities divided by the total opportunities included in the calculation.
- **Validation:** SQL and Power BI results matched at approximately 68.3%.

### Average Days to Close

- **Definition:** Average number of days between opportunity creation and closure for opportunities in the Closed Won or Closed Lost stages.
- **SQL result:** 76.6 days.
- **Power BI validation:** Record the comparison result for the dashboard measure, if displayed.

## 5. Data Model Validation

The following checks were performed:

- Eight tested relationships had zero unmatched records in the integrity checks performed.
- Invoice IDs were unique.
- Payment invoice IDs were unique.
- No invalid opportunity or subscription date sequences were found in the checks performed.
- Financial measures, churn metrics, early and late churn counts, average usage per customer and overall win rate were reconciled against SQL as documented above.

These checks support consistency between the tested SQL calculations and Power BI measures. They do not establish that every source record is accurate or that every possible filter interaction has been tested.

## 6. Visual Interaction Testing

### Customer Signups Over Time

Selecting a signup month changed all five KPI cards on the Executive Overview page.

**Interpretation:** The selection provides a cohort-based view of metrics associated with customers who signed up during the selected period.

**Limitation:** The resulting metrics do not necessarily represent activity that occurred during that month. For example, the churn rate reflects churned subscriptions associated with the selected customers, not necessarily subscriptions that churned during that month.

### Payments Collected Over Time

Selecting a payment month changed the Total Revenue Collected card, while the other four KPI cards remained unchanged.

**Interpretation:** The interaction focuses on payments recorded during the selected period without changing the other KPI cards.

### Acquisition Channel

Selecting an acquisition channel changed the subscription churn rate, early and late churn counts, average tenure at churn by plan, and average usage events per customer.

**Interpretation:** The selected channel filters related customer, subscription and usage metrics. The resulting values appeared reasonable during testing.

### Invoice Status

Selecting Paid or Overdue in the invoice-status donut changed some visuals but not all.

- Selecting Overdue caused Payments Collected by Plan to display zero.
- Selecting Paid removed the overdue invoice value.
- Overdue Invoices by Subscription Status remained unchanged.
- The Overdue Invoice Count line chart did not respond.

**Interpretation and limitation:** The observed behaviour is partly consistent with invoice-status filtering, but the resulting interactions do not provide useful information in every visual. Further review of visual interaction settings and filter propagation may be warranted if those visuals are intended to respond.

## 7. Data Quality and Reporting Limitations

### Missing Invoice Amounts

Sixty invoices have missing amounts, including two marked as overdue. Their exact financial impact cannot be quantified from the available data. The overdue invoice value should therefore be interpreted as the recorded value for overdue invoices with available amounts.

### Negative Payment

One payment of -$25.00 remains unexplained. The record was investigated, but the available data did not establish why the amount was negative. It should remain flagged for investigation rather than being silently excluded from the reported total.

### December 2025 Churn Anomaly

Of 2,430 subscriptions marked as churned in December 2025, 2,178 have an end date of 31 December 2025. This concentration should be investigated before drawing conclusions about the underlying churn trend.

### Dataset Limitations

Northstar is a fictional portfolio dataset. Its recorded financial values and statuses are not independently verified real-world business records. The analysis identifies patterns and areas for investigation rather than proving their causes.

## 8. Further Investigation

The principal remaining data-quality questions are:

- Establish the business explanation for the negative payment.
- Investigate the two overdue invoices with missing amounts.
- Determine why so many churned subscriptions have an end date of 31 December 2025.
- Review invoice-status visual interactions if improving their analytical usefulness is a project priority.

