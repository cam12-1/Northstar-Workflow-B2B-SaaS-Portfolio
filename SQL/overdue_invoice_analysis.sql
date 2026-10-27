
-- ============================================
-- OVERDUE INVOICE AND PAYMENT ANALYSIS
-- ============================================


-- Is the number and total dollar value of invoices currently labelled overdue increasing over time?
SELECT
    DATE_FORMAT(invoice_date, '%Y-%m') AS invoice_month,
    COUNT(invoice_id) AS total_invoices,
    SUM(amount_usd) AS total_overdue_amount
FROM invoices
WHERE invoice_status = 'Overdue'
GROUP BY DATE_FORMAT(invoice_date, '%Y-%m')
ORDER BY invoice_month ASC;


-- Of all invoices issued in each month, what percentage are currently labelled Overdue?
SELECT
    DATE_FORMAT(invoice_date, '%Y-%m') AS invoice_month,
    COUNT(invoice_id) AS total_invoices,
    COUNT(
        CASE
            WHEN invoice_status = 'Overdue' THEN invoice_id
        END
    ) AS overdue_invoice_count,
    ROUND(
        COUNT(
            CASE
                WHEN invoice_status = 'Overdue' THEN invoice_id
            END
        ) * 100.0 / NULLIF(COUNT(invoice_id), 0),
        2
    ) AS overdue_percentage
FROM invoices
GROUP BY DATE_FORMAT(invoice_date, '%Y-%m')
ORDER BY invoice_month ASC;


-- The number and total value of invoices currently labelled overdue have increased substantially over the period analysed.
-- However, the share of invoices labelled overdue has remained relatively stable, generally around 5–6.5% after January 2024.
-- This suggests that the growth in overdue invoice volume is associated at least partly with the expansion in overall invoice volume.
-- Further analysis is needed to determine whether collection performance has deteriorated.


-- ============================================
-- PAYMENT DATA VALIDATION
-- ============================================

DESCRIBE payments;


-- Are there any invoices with multiple payment records?
SELECT
    invoice_id,
    COUNT(payment_id) AS payment_count
FROM payments
WHERE invoice_id IS NOT NULL
GROUP BY invoice_id
HAVING COUNT(payment_id) > 1
LIMIT 10;

-- No rows returned: no invoice with a non-null invoice_id has multiple payment records in this table.


-- How many invoices have no matching payments?
SELECT
    COUNT(*) AS total_invoices,
    COUNT(p.invoice_id) AS invoices_with_payment,
    COUNT(*) - COUNT(p.invoice_id) AS invoices_without_payment
FROM invoices i
LEFT JOIN payments p
    ON i.invoice_id = p.invoice_id;


-- Are invoices without payment records actually the invoices currently marked as overdue?
SELECT
    i.invoice_status,
    COUNT(*) AS invoice_count,
    COUNT(p.invoice_id) AS invoices_with_payment,
    COUNT(*) - COUNT(p.invoice_id) AS invoices_without_payment
FROM invoices i
LEFT JOIN payments p
    ON i.invoice_id = p.invoice_id
GROUP BY i.invoice_status
ORDER BY invoice_count DESC;

-- The payment records align almost perfectly with invoice status.
-- All but one invoice marked Paid have a matching payment record.
-- Every invoice marked Overdue lacks a matching payment record. There are 13,043 of these.
-- This suggests the invoice status and payment records are consistent, although we haven't independently verified whether every payment amount matches its invoice amount.


-- Are there any payments recorded before their corresponding invoice dates?
SELECT
    COUNT(*) AS payments_before_invoice
FROM invoices i
JOIN payments p
    ON i.invoice_id = p.invoice_id
WHERE p.payment_date < i.invoice_date;

-- Zero payments occurred before their corresponding invoice dates.


-- ============================================
-- PAYMENT TURNAROUND ANALYSIS
-- ============================================

-- Are invoice-to-payment turnaround times increasing over time?
SELECT
    DATE_FORMAT(i.invoice_date, '%Y-%m') AS invoice_month,
    AVG(DATEDIFF(p.payment_date, i.invoice_date)) AS average_days_to_payment,
    COUNT(p.invoice_id) AS paid_invoices
FROM invoices i
JOIN payments p
    ON i.invoice_id = p.invoice_id
GROUP BY DATE_FORMAT(i.invoice_date, '%Y-%m')
ORDER BY invoice_month ASC;

-- No obvious deterioration in average payment turnaround, even though invoice volume grew substantially.
-- January 2024 is an outlier, but it also has only 155 paid invoices, so the smaller sample could make the figure less representative.
-- Stable average payment turnaround does not necessarily mean that overall collection performance has not deteriorated.


-- ============================================
-- OVERALL FINDINGS AND CONCLUSION
-- ============================================

-- Average payment turnaround among invoices with recorded payments remained broadly stable across the period.
-- The proportion of invoices currently marked overdue also remained within a relatively narrow range across invoice cohorts.
-- However, these measures do not establish whether overall collection performance improved or deteriorated,
-- because payment turnaround excludes unpaid invoices and the dataset does not provide an identified due-date field
-- or historical invoice-status snapshots.
-- Further analysis would be required to assess collection performance more conclusively.

