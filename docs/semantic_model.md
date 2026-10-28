# Northstar Workflow — Semantic Model Notes

## Purpose

The Power BI semantic model organises customer, subscription, invoice, payment, usage, support and sales data so that business metrics can be calculated and interpreted consistently.

## Financial Measures

### Overdue Invoice Value

**Definition:** Sum of invoice amounts for records marked as overdue.

**DAX measure:** `Overdue Invoice Value`

**Validation:** Reconciled against SQL. Both returned $2,846,303.00.

**Limitation:** Two overdue invoices have missing amounts. The total excludes those blanks and does not independently verify actual outstanding balances or contractual due dates.

### Overdue Invoice Count

**Definition:** Number of distinct invoices marked as overdue.

**DAX measure:** `Overdue Invoice Count`

**Validation:** Reconciled against SQL. Both returned 13,043.

### Total Revenue Collected

**Definition:** Sum of recorded payment amounts.

**DAX measure:** `Total Revenue Collected`

**Validation:** SQL returned $44,260,183.10.

**Limitation:** Includes one unexplained negative payment of $25. The record has been investigated but its business explanation remains unconfirmed.

## Model Validation

- Invoice IDs are unique.
- Payment invoice IDs are unique.
- All eight tested relationship links had zero unmatched records.
- No invalid opportunity or subscription date sequences were found in the checks performed.
- Overall Win Rate reconciled to SQL at approximately 68.3%.

## Outstanding Checks

- Test Power BI filter behaviour for acquisition channel, subscription plan, invoice status and payment date.
- Review the definitions of average days to close and average events per customer.
- Investigate the negative payment and missing invoice amounts with the available business context.

## Limitations

Northstar is a fictional portfolio dataset. Its recorded statuses and payment amounts should not be treated as independently verified real-world financial records.
