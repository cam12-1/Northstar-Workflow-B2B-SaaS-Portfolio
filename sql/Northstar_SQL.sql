-- ============================================================
-- NORTHSTAR SaaS BUSINESS ANALYSIS — EXECUTIVE SUMMARY
-- Analyst: Cameron Moore | Dataset: Jan 2024 – Dec 2025
-- ============================================================

-- KEY FINDINGS:

-- GROWTH: Northstar cquired customers consistently (557-681/month).
-- Net growth was positive every month Jan 2024 - Nov 2025.
-- December 2025 shows an unusual churn spike requiring validation.

-- REVENUE: Monthly revenue grew from $38k (Jan 2024) to $3.6M recorded in Dec 2025.
-- (December 2025 data is incomplete as dataset cuts off 14 December 2025).
-- Growth driven by increasing paying customers, not rising prices.
-- $2.85M in overdue invoices identified - a significant collection risk

-- COLLECTIONS: 10666 overdue invocies linked to active customers.
-- Churned customers averaged 144 days of unpaid invoices before cancelling.
-- Recommendation: Implement proactive collections monitoring immediately.

-- CHURN: Approximately 31% of customers across all channels and plans eventually churn.
-- Average tenure at churn is 188 days (6 months).
-- Churn is consistent across all segments - points to a product/experience issue.
-- Recommendation: Investigate onboarding and product value delivery.

-- ENGAGEMENT: Average usage is similar for active and churned customers (20.01 vs 19.98 events per customer).
-- Among churned customers, average usage increased in the final 90 days compared with the preceding 90 days.
-- Recommendation: Investigate whether other usage patterns help distinguish active customers from those who churn.

-- SALES: 68.33% win rate, consistent across reps and lead sources.
-- Average deal closes in ~77 days regardless of outcome.

-- SUPPORT: Balanced ticket volume across categories. 
-- Avg resolution 21 hours.
-- Support activity doesn't directly correlate with churn timing.


CREATE SCHEMA Northstar_Workflow;

-- cleaning the data
-- customer table
SELECT * 
FROM customers;
-- checking any blank values or NULLS
SELECT
    SUM(customer_id IS NULL) AS customer_id_nulls,
    SUM(company_id IS NULL) AS company_id_nulls,
    SUM(signup_date IS NULL) AS signup_date_nulls,
    SUM(role IS NULL OR TRIM(role) = '') AS role_missing,
    SUM(acquisition_channel IS NULL OR TRIM(acquisition_channel) = '') AS acquisition_channel_missing,
    SUM(country IS NULL OR TRIM(country) = '') AS country_missing,
    SUM(customer_status IS NULL OR TRIM(customer_status) = '') AS customer_status_missing
FROM customers;
-- There are 120 blanks and no nulls so let's identify them

-- checking customer_id
SELECT
    customer_id,
    COUNT(*) AS occurrences
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;
SELECT *
FROM customers
WHERE customer_id = 25582;
-- two rows exactly same so duplicate and we'll remove the one
DELETE FROM customers
WHERE customer_id = 25582
LIMIT 1;
-- Insepcting acquisition channel for any unexpected/mispelled channels
SELECT DISTINCT(acquisition_channel)
FROM customers;
-- Looking at table, there is no duplicates or mispelled channels. SO all looks in order. We've also earleir recognised there's no blank cells in the acquisition channel column.

-- Checking country column
SELECT DISTINCT(country)
FROM customers;
-- Again no duplicates, slightly mispelled countries so all is in order there. Again earlier we checked for blanks or nulls and there were none. 

-- Inspecting customer_status
SELECT DISTINCT(customer_status)
FROM customers;
-- We see that there is only churned and active no otehrs, therefore from this table nothing mispelled either or any blanks from earleir checking.


-- cleaning companies table
SELECT *
FROM companies;

-- Checking company_id uniqueness
SELECT COUNT(company_id) , COUNT(DISTINCT company_id), COUNT(DISTINCT company_name)
FROM companies;
-- Looking at this table there are a total of 5000 company_id's. Those that are distinct are also 5000, therefore all company_id's are unique and each match to a unique company_name.



-- Checking employee_count is all positive
SELECT employee_count
FROM companies
WHERE employee_count < 0;
-- There are no negative values

-- checking any blank values or NULLS
SELECT
    SUM(company_id IS NULL) AS company_id_nulls,
    SUM(company_name IS NULL OR TRIM(company_name) = '') AS company_name_missing,
    SUM(industry IS NULL OR TRIM(industry) = '') AS industry_missing,
    SUM(company_size IS NULL OR TRIM(company_size) = '') AS company_size_missing,
    SUM(employee_count IS NULL) AS employee_count_nulls,
    SUM(country IS NULL OR TRIM(country) = '') AS country_missing,
    SUM(signup_date IS NULL) AS signup_date_nulls
FROM companies;
-- Looks like the industry column has 35 missing values but the rest of the data looks normal so we won't delete these rows.


-- Checking country column
SELECT DISTINCT(country)
FROM companies;
-- No slightly mispelled countries so all looks in order there. Earlier we checked for blanks or nulls and there were none. 

-- Checking signup_date
SELECT MIN(signup_date) AS earliest, MAX(signup_date) AS latest
FROM companies;
SELECT COUNT(signup_date), COUNT(DISTINCT signup_date)
FROM companies;
-- theres 5000 sign_ups which aligns but 4999 distinct dates. Not saying that's wrong it could possibly mean to signed up at the same time but lets jsut check
SELECT signup_date, COUNT(*)
FROM companies
GROUP BY signup_date
HAVING COUNT(*) > 1;
-- We can see there's two signups that occured at 2025-06-26 06:04:57. This isn't a duplicate becasue we found earlier that all company_id's are unique.

-- cleaning invoices
SELECT *
FROM invoices;
SELECT
    SUM(invoice_id IS NULL) AS invoice_id_nulls,
    SUM(subscription_id IS NULL) AS subscription_id_nulls,
    SUM(customer_id IS NULL) AS customer_id_nulls,
    SUM(invoice_date IS NULL) AS invoice_date_nulls,
    SUM(amount_usd IS NULL) AS amount_usd_nulls,
    SUM(invoice_status IS NULL OR TRIM(invoice_status) = '') AS invoice_status_missing
FROM invoices;
-- There's 60 amount_usd null values but all other data looks fine for those rows so we won't remove. Also we could potentially link an estimated price of what they paid depending on package bougght if any same subscription id so we will leave for now.
SELECT *
FROM invoices
WHERE amount_usd IS NULL;
-- All the rows look normal (apart form the null amount_usd values). The last row is full of null values but no need to remove.

-- Checking invoice_id uniqueness
SELECT COUNT(*), COUNT(DISTINCT invoice_id)
FROM invoices;
-- Since there are 214599 total invoices and 214599 distinct invoices, we can say all invoices are unique

-- Checking invoice dates for implausable dates (we've already checked for blanks and nulls) 
SELECT MIN(invoice_date), MAX(invoice_date)
FROM invoices;
-- the min and max dates look plausable with no negatives

-- Checking subscription_id / customer_id
SELECT i.invoice_id, i.subscription_id
FROM invoices i
LEFT JOIN subscriptions s
	ON i.subscription_id = s.subscription_id
WHERE i.subscription_id IS NOT NULL
AND s.subscription_id IS NULL;
-- Since there's nothing that's shown, we haven't found any invoices referencing a subscription that doesn't exist.

-- Inspecting invoice status
SELECT invoice_status, COUNT(invoice_status)
FROM invoices
GROUP BY invoice_status;
-- There are only the two invoice_status options, no misspells, looks plausable

-- Cleaning payments table
SELECT *
FROM payments;

SELECT *
FROM payments
WHERE invoice_id IS NULL
   OR customer_id IS NULL
   OR payment_date IS NULL
   OR amount_usd IS NULL
   OR payment_method IS NULL
   OR TRIM(payment_method) = '';
-- Looks like it's the amount_usd that isn't filled. Possibly link the payment to the deal he bought.



-- Checking payment_id uniqueness
SELECT COUNT(payment_id), COUNT(DISTINCT payment_id)
FROM payments;
-- The total number of payment_id's is the same as the distinct ones, hence all the payment_id's are unique
SELECT p.payment_id, p.invoice_id
FROM payments p
LEFT JOIN invoices i
    ON p.invoice_id = i.invoice_id
WHERE p.invoice_id IS NOT NULL
  AND i.invoice_id IS NULL;
-- According to the table, there are no broken invoice references

-- Check payment date relative to invoice
SELECT 
    p.payment_id,
    p.invoice_id,
    p.payment_date,
    i.invoice_date
FROM payments p
JOIN invoices i
    ON p.invoice_id = i.invoice_id
WHERE p.payment_date < i.invoice_date;
-- There are no payment dates prior to the invoice date which is good

-- Are there any amounts (usd) lesss than 0?
SELECT *
FROM payments
WHERE amount_usd < 0;
-- We have one payment amount that is negative. Let's investigate it. First looking at history of this customer
SELECT * 
FROM payments 
WHERE customer_id = 21092
ORDER BY payment_date ASC;
-- Everything else looks in order with his payments.
SELECT *
FROM subscriptions
WHERE customer_id = 21092;
-- The customer was on plan 1 which is: 
SELECT *
FROM plans;
-- The starter plan, which is a monthly billing frequency at 49 usd includes 5 seats.

SELECT *
FROM payments
WHERE customer_id = 21092
ORDER BY payment_date ASC;


SELECT *
FROM subscriptions
WHERE customer_id = 21092;

SELECT
    p.payment_id,
    p.payment_date,
    p.amount_usd AS payment_amount,
    i.invoice_id,
    i.invoice_date,
    i.amount_usd AS invoice_amount,
    i.invoice_status,
    s.subscription_id,
    s.plan_id,
    s.seats,
    pl.plan_name,
    pl.list_price_usd,
    pl.included_seats
FROM payments AS p
LEFT JOIN invoices AS i
    ON p.invoice_id = i.invoice_id
LEFT JOIN subscriptions AS s
    ON i.subscription_id = s.subscription_id
LEFT JOIN plans AS pl
    ON s.plan_id = pl.plan_id
WHERE p.payment_id = 311631;

SELECT *
FROM payments
WHERE invoice_id = 112422;

SELECT
    invoice_id,
    SUM(amount_usd) AS total_payments,
    COUNT(*) AS payment_count
FROM payments
WHERE invoice_id = 112422
GROUP BY invoice_id;

-- One negative payment identified, but it's the only apyment asscociated with that invoice. The avaialble data does not provide a valid ebusines explanation fo the negative amount so the record should be flagged as anomalous and excluded from standard payment/revenue calculations unless confirmed otherwise.
SELECT *
FROM payments;
-- Inspecting payment_method
SELECT DISTINCT payment_method
FROM payments;
-- These three look plausable and correct.

-- Cleaning support tickets

SELECT *
FROM support_tickets;

SELECT *
FROM support_tickets
WHERE ticket_id IS NULL
   OR customer_id IS NULL
   OR created_at IS NULL
   OR category IS NULL
   OR TRIM(category) = ''
   OR priority IS NULL
   OR TRIM(priority) = ''
   OR resolution_hours IS NULL
   OR status IS NULL
   OR TRIM(status) = '';
-- There's one row where all cells are null so we'll leave it and data looks ok.

-- Checking ticket_id uniqueness
SELECT COUNT(ticket_id),  COUNT(DISTINCT ticket_id)
FROM support_tickets;
-- There are 50000 ticket_id's and 50000 distinct ticket_id's therefore each id is unique

-- Checking customer_id coverage
SELECT COUNT(customer_id),  COUNT(DISTINCT customer_id)
FROM support_tickets;
-- It's good that the total number of customer_id is less than the distinct number of customer id's. Means we have 50000 support tickets with a customer_id belonging to 14463 different customers
-- To make sure each suport belongs to someone we will check than at least each custoemr_id has one ticket
SELECT customer_id, COUNT(*) AS ticket_count
FROM support_tickets
GROUP BY customer_id
ORDER BY ticket_count DESC;

-- checking if there's duplicate ticket_id's
SELECT ticket_id, COUNT(*) AS count
FROM support_tickets
GROUP BY ticket_id
HAVING COUNT(*) > 1;
-- There is no duplicates

-- Inspecting category / priority / status
-- Category
SELECT DISTINCT category
FROM support_tickets;
-- Doesn't look like any typo issues
-- Priorities
SELECT DISTINCT priority
FROM support_tickets;
-- Again no typo issues

-- Status
SELECT DISTINCT status
FROM support_tickets;
-- Again no typo issues

-- Checking resolution_hours
-- If negatives
SELECT *
FROM support_tickets
WHERE resolution_hours < 0
ORDER BY resolution_hours ASC;

SELECT status, resolution_hours, COUNT(*) AS count
FROM support_tickets
WHERE resolution_hours < 0
GROUP BY status, resolution_hours;


SELECT *
FROM support_tickets
WHERE resolution_hours = -1
  AND status = 'Resolved';

SELECT
    COUNT(*) AS total_tickets,
    SUM(resolution_hours = -1) AS negative_resolution,
    SUM(resolution_hours >= 0) AS non_negative_resolution
FROM support_tickets;

SELECT
    status,
    MIN(resolution_hours) AS min_hours,
    MAX(resolution_hours) AS max_hours,
    AVG(resolution_hours) AS avg_hours
FROM support_tickets
GROUP BY status;
SELECT
    status,
    MIN(resolution_hours) AS min_hours,
    MAX(resolution_hours) AS max_hours,
    AVG(resolution_hours) AS avg_hours,
    COUNT(*) AS ticket_count
FROM support_tickets
WHERE resolution_hours >= 0
GROUP BY status;

SELECT resolution_hours, COUNT(*) AS count
FROM support_tickets
WHERE resolution_hours <= 0
GROUP BY resolution_hours
ORDER BY resolution_hours;

-- 25 support tickets have resolution_hours = -1, which is not a valid duration. Of these, 19 are marked Resolved, 5 Open, and 1 Pending. The meaning of -1 should be investigated before replacing or removing the values.

-- Cleaning usage_events

SELECT *
FROM usage_events;

SELECT
    COUNT(*) AS total_rows,
    SUM(event_id IS NULL) AS missing_event_id,
    SUM(customer_id IS NULL) AS missing_customer_id,
    SUM(event_timestamp IS NULL) AS missing_timestamp,
    SUM(event_type IS NULL) AS missing_event_type,
    SUM(TRIM(event_type) = '') AS blank_event_type
FROM usage_events;
-- quite a few blanks and nulls

SELECT
    COUNT(*) AS total_rows,
    SUM(event_id IS NULL) AS missing_event_id,
    SUM(customer_id IS NULL) AS missing_customer_id,
    SUM(event_timestamp IS NULL) AS missing_timestamp,
    SUM(event_type IS NULL) AS missing_event_type,
    SUM(TRIM(event_type) = '') AS blank_event_type
FROM usage_events;

SELECT DISTINCT event_type
FROM usage_events
ORDER BY event_type;
-- 90 records contain a blank value. Valid event types include Login, Export, Report Viewed, Team Invite, Workflow Created, Workflow Completed, and Integration Used. The blank values cannot be reliably classified without additional information.

SELECT *
FROM usage_events
WHERE event_timestamp IS NULL;
-- 40 records have a missing timestamp. The associated event IDs, customer IDs, and event types are present, so these records are usable for some analyses but cannot reliably be included in time-based analyses.


-- Checking event_id uniqueness
SELECT COUNT(event_id), COUNT(DISTINCT event_id)
FROM usage_events;
-- There's a total of 300000 event_id's, and 300000 distinct event_id's therefore all event_id's are unique.

-- Checking customer_id coverage
SELECT COUNT(customer_id), COUNT(DISTINCT customer_id)
FROM usage_events;
-- This looks reasonable

SELECT ue.event_id, ue.customer_id
FROM usage_events ue
LEFT JOIN customers c
    ON ue.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
-- there is nothing so every usage-event has a customer_id, and every csutomer_id has an actual customer.

-- Checking customer_id coverage
SELECT COUNT(customer_id), COUNT(DISTINCT customer_id)
FROM usage_events;
-- This looks reasonable that therev are less distinct customer_id's than total customer_id's
-- Check customer_id coverage

-- Checking event_type
SELECT DISTINCT(event_type)
FROM usage_events;
-- Doesn't look like any typos but there are blanks so we'll investigate

-- Blank event_type values need investigation
SELECT *
FROM usage_events
WHERE event_type = '';
-- quite a few rows withtout event type

SELECT COUNT(*) AS blank_event_types
FROM usage_events
WHERE TRIM(event_type) = '';
-- There are 90 blank-event types

-- converting those blanks to nulls
UPDATE usage_events
SET event_type = NULL
WHERE TRIM(event_type) = '';

-- Checking plans table
SELECT *
FROM plans;
-- All plans' cells look in order and correct

-- Checking opportunties table
SELECT *
FROM opportunities;

SELECT *
FROM opportunities
WHERE opportunity_id IS NULL
   OR company_id IS NULL
   OR created_at IS NULL
   OR sales_rep IS NULL
   OR lead_source = ''
   OR deal_size_usd IS NULL
   OR stage = ''
   OR close_date IS NULL;
-- Looks like close date has a lot of nulls 

SELECT stage, COUNT(*) AS count
FROM opportunities
WHERE close_date IS NULL
GROUP BY stage
ORDER BY count DESC;

SELECT stage, COUNT(*) AS count
FROM opportunities
WHERE close_date IS NOT NULL
GROUP BY stage
ORDER BY count DESC;
-- NULL values occur only for opportunities in Proposal, Qualified, and Negotiation stages, while Closed Won and Closed Lost opportunities have recorded close dates. The NULL values therefore represent opportunities that have not yet closed and were retained.

-- Checking opportunity_id uniqueness
SELECT COUNT(opportunity_id), COUNT(DISTINCT opportunity_id)
FROM opportunities;
-- There are a total of 30000 opportuntiy id's and 30000 distinct opportunity_id's so each opportunity id is unique.

-- Inspecting stage_values
SELECT DISTINCT stage
FROM opportunities;
-- Doesn't appear to be any typos 


-- Checking close_date logic
SELECT
    stage,
    COUNT(*) AS total_opportunities,
    COUNT(close_date) AS with_close_date,
    COUNT(*) - COUNT(close_date) AS without_close_date
FROM opportunities
GROUP BY stage
ORDER BY stage;
-- Looks plausable, null close_dates are those without closed deals (negotiation, proposal, qualified)

-- Check close_date >= created_at
SELECT *
FROM opportunities
WHERE created_at > close_date;
-- There isn't any rows where created_at is greater than close_date so data is fine here

-- Inspect deal_size_usd
SELECT *
FROM opportunities
WHERE deal_size_usd IS NULL OR deal_size_usd = 0 OR deal_size_usd < 0;
-- No issues with this check 
SELECT deal_size_usd
FROM opportunities
ORDER BY deal_size_usd ASC;
-- No appeared outliers

-- Inspecting lead_source consistency
SELECT DISTINCT lead_source
FROM opportunities;
-- Looks plausable, nothing looks of error 


-- Checking subscriptions table
SELECT *
FROM subscriptions
WHERE subscription_id IS NULL
   OR customer_id IS NULL
   OR plan_id IS NULL
   OR start_date IS NULL
   OR end_date IS NULL
   OR status = ''
   OR seats IS NULL;
-- Looks like end_date full of nulls. Let's see how many
SELECT COUNT(*) row_count, COUNT(*) - COUNT(end_date) null_end_dates
FROM subscriptions;
-- Theres a total of 21000 rows and 15316 rows where the end_dates is nulls

-- Checking subscription_id uniqueness
SELECT COUNT(*), COUNT(DISTINCT subscription_id)
FROM subscriptions;
-- There are equal numbers for both these counts therefore all subscription_id's are unique

-- Checking plan_id uniqueness
SELECT COUNT(*) missing_plan_id
FROM subscriptions
WHERE plan_id IS NULL;
-- There's 40 plan_id's missing
SELECT *
FROM subscriptions
WHERE plan_id IS NULL;
DESCRIBE subscriptions;
SELECT *
FROM subscriptions
ORDER BY customer_id;
-- 40 subscriptions have null plan_id's. Some customers have more than one plan, therefore missing data can't be invented based on their other plans so we retain these valeus as NULL.

-- Checking start, end logic
SELECT *
FROM subscriptions
WHERE start_date > end_date;
-- No rows where start date is greater than end date

-- Inspecting status
SELECT DISTINCT status
FROM subscriptions;
-- Nothing looks odd here 

-- Are all seats positive
SELECT *
FROM subscriptions
WHERE seats < 1;
-- no negative seats or seats = 0

-- Business area 1 — Growth
-- Is Northstar acquiring customers consistently over time?
SELECT *
FROM customers;

SELECT DATE_FORMAT(signup_date, '%Y-%m') month, COUNT(*) total_customers_by_month
FROM customers
GROUP BY DATE_FORMAT(signup_date, '%Y-%m')
ORDER BY month;
-- Every month is similar. majority ranging between 600 and 700 new customers per month. Feb 2025 has a dip at 557 but march recovers to 666. 
-- December2025 is low too let's see why (posisbly month not finished)
SELECT MAX(signup_date)
FROM customers;
-- Yes so max signup date is the 14th of december 2025 that we have so month is incomplete. we will keep that in mind on doing further analysis.
-- So yes overall they are acquiring customers consistently over time

-- Which acquisition channels bring in the most customers? Becuase on topic of growth we will do by month as well in next query
SELECT acquisition_channel, COUNT(*) total_customers
FROM customers
GROUP BY acquisition_channel
ORDER BY total_customers DESC;
-- Inbound has the most customers over these two years (including the incomplete december 2025) with 3450 customers, followed by outbound sales and paid search. 
-- Referral has the least customers at 1513, 2nd least is partner at 1828. This raises the question about hwo much Northstar relies on referrals and business partnerships comapred with the other acquisition channels.
-- Possible recommendation: Explore how to continue improving the effective inbound, outbound sales or how to improve partner and referral acquisition channels.
-- customers per acquisiton per month / total customers per month
-- Is the composition of new customers changing?
WITH customers_per_acq AS (
SELECT DATE_FORMAT(signup_date, '%Y-%m') month, acquisition_channel, COUNT(*) customer_total
FROM customers
GROUP BY DATE_FORMAT(signup_date, '%Y-%m'), acquisition_channel
	)
SELECT *, SUM(customer_total) OVER (PARTITION BY month) monthly_total, ROUND(((customer_total / SUM(customer_total) OVER (PARTITION BY month)) * 100), 2) percentage_of_customers
FROM customers_per_acq;
-- What stands out:
-- Inbound genreally a major acquisition over the two years averaging around 21%, and reaching high in april 2025 at 25.94%
-- Outbound sales: Also storng throughout the 2 years, slighlty less average than inbound maybe 19 to 20 percent. Share rose to 22.26% in may 2024 and spiked so far in december 2025 at 28.52% but month isn't finished yet
-- Paid search: Generally consistnet as well range aorund 18 to 21%, so far dropped in december 2025 at 14.08%.
-- Organic: Its share fluctuated with lower values around 13% iun several months of 2025
-- Referral: Consistently one of the smalelr channels around 8 to 12 %
-- partner: Share fluctuated (also on lower side around 10 to 13%) rather than increasing or decreasing.
-- Inbound remained a significant acquisition channel throughout the period, generally accounting for around 22–25% of new customers. Outbound Sales and Paid Search experienced month-to-month fluctuations, but their shares were broadly stable across 2024 and the first 11 months of 2025. December 2025 shows a higher share for Outbound Sales and a lower share for Paid Search, although the incomplete month limits meaningful comparison.
-- recommednation:investigate channel performance using acquisition costs and conversion rates before deciding where to increase investment.

-- Is the customer base growing overall, once customer losses are considered?

-- Calculating monthly new customers from customers table
SELECT DATE_FORMAT(signup_date, '%Y-%m') month, COUNT(DISTINCT customer_id) new_customers
FROM customers
GROUP BY DATE_FORMAT(signup_date, '%Y-%m');
-- There appears to be new customers ranging from 557 to 681 each month with Feb 2025 having the least and October 2024 having the most (681). 
-- Note signfiicant drops in customers for least customer months. 
-- Namely:
	-- 2025-04	609
	-- 2025-02	557
	-- 2025-12	277
-- December 2025 is excluded from comparisons of full-month acquisition because the latest recorded signup date is 14 December 2025.



-- Calculating monthly lost customers using subscription end dates, making sure customers with another active subscription aren't treated as lost. 
SELECT DATE_FORMAT(end_date, '%Y-%m') month, COUNT(*) churned_subscriptions
FROM subscriptions
WHERE status = 'Churned'
GROUP BY DATE_FORMAT(end_date, '%Y-%m')
ORDER BY month ASC;
-- Interestingly the churned count increases each month from March 2024 (5) till November 2025 (251). Also intersting that December 2025, though incomplete is already an outlier as it has a huge increase from november 2025, namely 2430. Defintely worth investigating
SELECT *
FROM subscriptions;


-- Let's understand that December 2025 number
SELECT
    COUNT(*) AS churned_subscriptions,
    COUNT(DISTINCT customer_id) AS customers_with_churned_subscriptions
FROM subscriptions
WHERE status = 'Churned'
  AND end_date >= '2025-12-01'
  AND end_date < '2026-01-01';
-- So there are 2430 churned subscriptions in Dec 2025 so far and 2247 customers have churned subscriptions. 
-- So there is 183 subscriptions where customers have who have at least one churned subscription, have another active.
-- I don't think that effects the analysis, the bigger question is why did december 2025 churn count spike so high already. ALso would be interesting to know the ratio of active_count vs churned count.
-- ratio of active vs churned over time
SELECT DATE_FORMAT(end_date, '%Y-%m') month, COUNT(*) churned_count
FROM subscriptions
WHERE status = 'Churned'
GROUP BY DATE_FORMAT(end_date, '%Y-%m')
ORDER BY month ASC;
-- Interestingly the churned count increases each month from March 2024 (5) till November 2025 (251). Also intersting that December 2025, though incomplete is already an outlier as it has a huge increase from november 2025, namely 2430. Defintely worth investigating.
-- Let's see what plans the december 2025 subscriptions were on
-- Are the december churns contractual
SELECT
	DATE_FORMAT(start_date, '%Y-%m') start_month,
	COUNT(*) churned_count
FROM subscriptions
WHERE status = "Churned"
	AND end_date >= '2025-12-01'
    AND end_date < '2026-01-01'
GROUP BY DATE_FORMAT(start_date, '%Y-%m')
ORDER BY churned_count DESC;
-- The largest group of December churned subscriptions started in December 2025, followed by November and October 2025. 
-- However, the start dates span multiple months, so the results do not establish a single explanation for the December spike.
-- Further investigation of the end dates is required.
WITH december_churned AS (
	SELECT 
		s.subscription_id,
		s.customer_id,
		s.plan_id,
		s.start_date,
		s.end_date,
        COALESCE(p.plan_name, 'Missing plan') plan_name,
		TIMESTAMPDIFF(MONTH, s.start_date, s.end_date) month_active
	FROM subscriptions s
    LEFT JOIN plans p
		ON s.plan_id = p.plan_id 
    WHERE status = "Churned"
    AND s.end_date >= '2025-12-01'
    AND s.end_date < '2026-01-01'
), bucketed AS (
	SELECT *, 
		CASE
			WHEN month_active = 0 THEN '0 - Same Month'
            WHEN month_active BETWEEN 1 AND 3 THEN '1 - 3 Months'
            WHEN month_active BETWEEN 4 AND 12 THEN '4 - 12 Months'
            ELSE 'Over 12 Months'
		END AS tenure_bucket
	FROM december_churned
)
SELECT plan_name,
tenure_bucket,
COUNT(*) churned_count,
ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (), 2) percentage
FROM bucketed
GROUP BY plan_name, tenure_bucket
ORDER BY percentage DESC;
-- Subscriptions with a calculated tenure of 4–12 months formed the largest tenure group in the December churn records. 
-- Growth contributed the largest number of churned subscriptions in most tenure categories. 
-- These are counts and shares of recorded churn, not plan-specific churn rates.
-- The analysis does not establish whether customers on Growth were more likely to churn than customers on other plans

-- Investigating the concentration of December churn on 31 December
SELECT
    CASE
        WHEN DATE(end_date) = '2025-12-31'
            THEN '31 December'
        ELSE 'Other December dates'
    END AS date_group,
    COUNT(*) AS churned_subscriptions
FROM subscriptions
WHERE status = 'Churned'
  AND end_date >= '2025-12-01'
  AND end_date < '2026-01-01'
GROUP BY date_group;

-- Of the 2,430 churned subscriptions recorded in December 2025, 2,178 (89.6%) had an end date of 31 December. 
-- This concentration occurred across all subscription plans. 
-- The pattern raises the possibility of a common expiry date, bulk termination or a data-processing issue, but the available data does not establish the cause. 
-- The recorded spike should be validated before being interpreted as a genuine change in customer behaviour.

-- So answering the main question of is customer base growing overall, once customers lost considered
-- Calculating monthly new customers and genuinely lost customers

WITH monthly_new AS (
    SELECT
        DATE_FORMAT(signup_date, '%Y-%m') AS month,
        COUNT(DISTINCT customer_id) AS new_customers
    FROM customers
    GROUP BY DATE_FORMAT(signup_date, '%Y-%m')
),
customer_subscription_summary AS (
    SELECT
        customer_id,
        MAX(CASE
            WHEN status = 'Active' THEN 1
            ELSE 0
        END) AS has_active_subscription,
        MAX(CASE
            WHEN status = 'Churned' THEN end_date
        END) AS last_churn_date
    FROM subscriptions
    GROUP BY customer_id
),
monthly_lost AS (
    SELECT
        DATE_FORMAT(last_churn_date, '%Y-%m') AS month,
        COUNT(*) AS lost_customers
    FROM customer_subscription_summary
    WHERE has_active_subscription = 0
      AND last_churn_date IS NOT NULL
    GROUP BY DATE_FORMAT(last_churn_date, '%Y-%m')
),
all_months AS (
    SELECT month FROM monthly_new
    UNION
    SELECT month FROM monthly_lost
)
SELECT
    m.month,
    COALESCE(n.new_customers, 0) AS new_customers,
    COALESCE(l.lost_customers, 0) AS lost_customers,
    COALESCE(n.new_customers, 0)
        - COALESCE(l.lost_customers, 0) AS net_customer_change
FROM all_months m
LEFT JOIN monthly_new n
    ON m.month = n.month
LEFT JOIN monthly_lost l
    ON m.month = l.month
ORDER BY m.month;

-- From January 2024 to November 2025, recorded new customer acquisitions exceeded the customers classified as lost in every month. 
-- Monthly net change ranged from 512 to 680 customers.
-- December 2025 showed a calculated net change of −513, based on 277 recorded new customers and 790 customers classified as lost. 
-- However, December acquisition data is incomplete, and the churn analysis identified an unusual concentration of end dates on 31 December 2025. 
-- The loss calculation also relies on current subscription statuses rather than reconstructing historical customer status.
-- Consequently, the December result should be treated as requiring validation rather than evidence of an actual decline in the customer base. 
-- The historical pattern suggests positive net customer additions under the chosen calculation, but further validation is needed before drawing conclusions about the true change in Northstar's active customer base.

-- Recommendation: Validate the December 2025 churn records, particularily the subscriptions of december 31st, before using these figures to assess customer retention or make decisions.
-- Once verified, Northstar should monitor net customer growth using consistent measures of new customers and lost customrs to check if customer acquistition is keeping pace with customer looses. 


------------------------
-- 2. Revenue and payments
-- How is recorded payment value changing over time?
-- requires monthly total revenue
SELECT DATE_FORMAT(payment_date, '%Y-%m') Month, SUM(amount_usd) Total_Revenue
FROM payments
GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
ORDER BY Month ASC;
-- Observation: The figures rise every month from January 2024 ($38745.60) to December 2025 $3655719.60).
-- Before moving on lets see if its consistent if we checked total revenue excluding negative payment and missing amounts
-- Compare reported payment value with payment value excluding negatives
SELECT
    SUM(amount_usd) reported_payment_value,
    SUM(CASE
        WHEN amount_usd >= 0 THEN amount_usd
    END) AS payment_value_excluding_negatives,
    SUM(amount_usd < 0) AS negative_payment_count,
    SUM(amount_usd IS NULL) AS missing_amount_count
FROM payments;
-- The reported payment value differs from the value excluding negative payments by approximately $25. 
-- Only one negative payment was identified, and 58 payment records have missing amounts. 
-- These records represent a small number of exceptions, but the negative payment should remain flagged as anomalous until its purpose is confirmed. 
-- Missing amounts are excluded from SUM calculations, so the reported total may not represent the full value of all payments. 


-- Is this because an increase in customers?
-- We've establsihed this earlier that the net customer change is more steady than this reveue increase and very interesitng with december have a negative net customers, while revenue increases is something to investigate.
-- Let's see if monthly revenue by subscription plan is the reason. Customers could be obtaining more expensive plans. Also looking at customer count per and average pyment amount. And will account any subscriptions that are missing a plan name
SELECT
    DATE_FORMAT(p.payment_date, '%Y-%m') AS month,
    COALESCE(pl.plan_name, 'Unassigned') AS plan_name,
    COUNT(*) AS payment_count,
    COUNT(DISTINCT p.customer_id) AS unique_paying_customers,
    SUM(p.amount_usd) AS monthly_revenue,
    ROUND(AVG(p.amount_usd), 2) AS avg_payment_amount
FROM payments p
JOIN invoices i
    ON p.invoice_id = i.invoice_id
JOIN subscriptions s
    ON i.subscription_id = s.subscription_id
LEFT JOIN plans pl
    ON s.plan_id = pl.plan_id
GROUP BY
    DATE_FORMAT(p.payment_date, '%Y-%m'),
    COALESCE(pl.plan_name, 'Unassigned')
ORDER BY month, plan_name;
-- Revenue increased substantially across all four plans along with rising payment counts and unique paying customers
-- Professional generated the highest revenue throughout the period, reachign approx $1.5 million in december 2025, growth followed at $993k, enterprsie at $894k and starter at $327k
-- Average payment amount remained stable across the period. Enteriprise around $90, Growth around $149, Professional around $396 and starter around $57. Suggesting increase revenue more consistent with increased payment amounts than higher average payments.
-- Unique paying customers increasd across all plans. Professional rose from 35 in January 2024 to 3,360 in December 2025. This supports the possibility that a growing paying customer base is contributing to revenue growth.
-- Unassigned revenue is relatively small, reaching $4,738.20 in December 2025. These payments are associated with subscriptions that have no assigned plan.
-- Growth and starter have more payment records than unique paying cusotmers in later months indicating htat some custpomers make multiple payments within a month
-- Business takeaway:
-- Northstar's revenue growth appears to be driven primarily by increased payment activity and a growing number of paying customers, rather than rising average payment amounts. 
-- A small portion of payments revenue ($53984.50) could not attributed to a named subscription plan because some subscriptions jave missing plan ID's. This limitation should be considered whe interpreting revenue by plan.

-- group by month and plan that genreates most per month, possibly even count of subscriptions
-- The Professional plan consistently generated the highest monthly revenue, followed by Growth and Enterprise, while Starter generated the least. Revenue increased across all four plans over the period, alongside increases in payment activity and unique paying customers. Average payment amounts remained relatively stable, suggesting that the revenue growth was associated more with increased payment activity than with higher average payment amounts.

-- How much of the invoiced revenue is actually being collected?
-- what are the invoice statuses and how much money is associated with each?
SELECT
	invoice_status,
	COUNT(*) invoice_count,
    SUM(amount_usd) total_invoiced
FROM invoices
GROUP BY invoice_status
ORDER BY total_invoiced DESC;
-- This result shows that $2.85 million is associated with overdue invoices.

-- now we need to know the collection rate by comparing invoices with payments, that every payment has an invoice id and mathces an invocie
SELECT
	i.invoice_status,
    COUNT(DISTINCT i.invoice_id) invoice_count,
    SUM(i.amount_usd) invoice_amount,
    SUM(COALESCE(p.payment_amount, 0)) amount_collected,
    ROUND(SUM(COALESCE(p.payment_amount, 0)) / NULLIF(SUM(i.amount_usd), 0) * 100, 2) payment_to_invoice_ratio_pct
FROM invoices i
LEFT JOIN (
	SELECT 
		invoice_id,
		SUM(amount_usd) payment_amount
	FROM payments
	GROUP BY invoice_id
) p ON i.invoice_id = p.invoice_id
GROUP BY i.invoice_status;
-- There are 13,043 overdue invoices with a combined invoice value of approximately $2.85 million.
-- Compare invoice amounts with linked payments to investigate collection differences. 
-- An overdue status does not, by itself, prove that an invoice has received no payment.
-- Investigate the remaining difference between invoice and payment totals before drawing conclusions about collections.

-- Let's investigate the $ 2.8 million
-- Are the overdue invoices spread out over time or concentrated in certian months
SELECT invoice_status, DATE_FORMAT(invoice_date, '%Y-%m') month, COUNT(*), SUM(amount_usd) total_amount
FROM invoices 
WHERE invoice_status = "Overdue"
GROUP BY DATE_FORMAT(invoice_date, '%Y-%m')
ORDER BY month ASC;
-- Interesting that the amount of overdue invoices increases almost every month except a slight dip in 2024-12 to 2025-01 and 2025-10 and 2025-11.
-- The total amounts overdue follow a similar general pattern. 

-- So time definitely shows increased overdue pamyents and totals overtime. 
-- But what is the cause if the overdue payments aren't concentrated.

-- Let's see how many of these overdue customers are active vs churned


SELECT s.status, COUNT(*) overdue_count, SUM(i.amount_usd)
FROM invoices i
LEFT JOIN subscriptions s
	ON i.subscription_id = s.subscription_id
WHERE i.invoice_status = "Overdue"
GROUP BY s.status;
-- Northstar has 10666 overdue invoices linked to its customers. 2377 overdue invoices linked to churn customers. 
-- We can see if those overdue invoices were before or after they churned. But need to investigate the active members.
-- For churned customers with overdue invoices
SELECT COUNT(*)
FROM invoices i
LEFT JOIN subscriptions s
	ON i.subscription_id = s.subscription_id
WHERE i.invoice_status = "Overdue"
AND i.invoice_date < s.end_date
;
-- Let's see time difference between invoice date and end date of subscription when overdue invocies due date were before end date
SELECT AVG(TIMESTAMPDIFF(DAY, i.invoice_date, s.end_date)) avg_time_diff,
	MIN(TIMESTAMPDIFF(DAY, i.invoice_date, s.end_date)) min_time_diff,
    MAX(TIMESTAMPDIFF(DAY, i.invoice_date, s.end_date)) max_time_diff
FROM invoices i
LEFT JOIN subscriptions s
	ON i.subscription_id = s.subscription_id
WHERE i.invoice_status = "Overdue"
AND i.invoice_date < s.end_date
AND s.status = 'Churned';
-- The average time difference between invoice date and end date for overdue invoices that eventually churned is 144 days. 
-- The smallest difference in time is one day and the most is 493 days.
-- So there were customers who were still active for a substantial amount of time before churning.




-- I've found that there are customers who have unpaid invoices of which remain unpaid while they are still active. 
-- On average overdue invocies are left unpaid on average of 144 days before chruninig their subscriptions. 
-- I've found that these overdue invoices have left $2.8 million dollars in unpaid revenue
-- This means customers are using the Northstar services without paying, leaving Northstar without significant revenue.
-- Recommendations:
-- I recommend Northstar reach out to these customers whether active or churned, to pay their outstanding payments. 
-- I also recommend Northstar strictly monitor for unpaid invoices and address them.

----------------------------------
-- 3. Customer retention and churn

-- What's the average subscription length for churned customers overall
SELECT AVG(TIMESTAMPDIFF(DAY, start_date, end_date)) avg_time_diff,
	MIN(TIMESTAMPDIFF(DAY, start_date, end_date)) min_time_diff,
    MAX(TIMESTAMPDIFF(DAY, start_date, end_date)) max_time_diff
FROM subscriptions
WHERE status = "Churned";
-- Average subscription lenghth is 188 days. Shortest subscription length is 11 days and longest subscription length that has churned is 479 days.
-- Customers are on average using the services for 6 months befroe churning. 
-- All plans are billed monthly, meaning churned customers actively chose not to renew each month before eventually cancelling. 
-- Tenure at churn ranged from 11 to 479 days indicating that while the averae is 188 days, churn occurs across all stages of cusotmers life cycle from early to long term.

SELECT
    SUM(CASE
        WHEN TIMESTAMPDIFF(DAY, start_date, end_date) <= 30
        THEN 1 ELSE 0
    END) AS short_term,
    SUM(CASE
        WHEN TIMESTAMPDIFF(DAY, start_date, end_date) > 30
        THEN 1 ELSE 0
    END) AS long_term
FROM subscriptions
WHERE status = 'Churned';
-- Of 5,666 churned subscriptions, 460 ended within 30 days (approximately 8.1%), while 5206 lasted more than 30 days.
-- Early cancellations warrant further investigation.

-- Recommendations
-- 460 churned subscriptions (8% of total churn) had a tenure of 30 days or less, suggesting a meaningful portion of customers left before establishing value. Northstar should review and improve their onboarding experience to help customers see value quickly before they decide to leave.
-- Late churns means customers saw value but for specifc reasons left. Northstar should reach out to customers to understnad why they're leaving and see how they could possibly assist in providing value if possible.

-- Now which channels produced the most churned customers

WITH total_customers AS (
SELECT acquisition_channel, COUNT(*) total_customers
FROM customers
GROUP BY acquisition_channel
),
churned_customers AS (SELECT
        c.acquisition_channel,
        COUNT(DISTINCT c.customer_id) churn_count
    FROM customers c
    JOIN subscriptions s
        ON c.customer_id = s.customer_id
    WHERE s.status = 'Churned'
    GROUP BY c.acquisition_channel
)
SELECT t.acquisition_channel,
	t.total_customers,
    ch.churn_count,
    ROUND(ch.churn_count * 100 / t.total_customers, 2) churn_percentage    
FROM total_customers t 
LEFT JOIN churned_customers ch
	ON t.acquisition_channel = ch.acquisition_channel
ORDER BY churn_percentage DESC;
-- Paid search and Referral have the highest churn rates relative to their total customers. Although they are all close, with a range of 32.68% to 30.28%.
-- I would say this is a high churn rate having roughly 1 in 3 cusotmers eventually churning.
-- Churn rates are relatively consistent across acquisition channels, ranging from approximately 30.7% to 32.7%.
-- These results do not establish why customers churn or rule out an influence from acquisition channel.
-- Recommendation: Investigate cancellation reasons and review the customer experience to identify potential factors associated with churn.

-- How long do customers typically stay before churning by plan?
SELECT p.plan_name, 
	AVG(TIMESTAMPDIFF(DAY, s.start_date, s.end_date)) avg_time_diff,
	MIN(TIMESTAMPDIFF(DAY, s.start_date, s.end_date)) min_time_diff,
    MAX(TIMESTAMPDIFF(DAY, s.start_date, s.end_date)) max_time_diff
FROM subscriptions s
JOIN plans p
	ON s.plan_id = p.plan_id
WHERE s.status = "Churned"
GROUP BY p.plan_name;
-- Average tenure at churn is broadly consistent across all four plans rangning from 186 to 193 days.
-- Together with the similar churn rates across acquisition channels, this suggests no large differences in these particular measures.
-- Further analysis is needed to establish whether plan type or other customer characteristics are associated with churn.

-- Do churned customers use the product less before they leave?
-- Do usage patterns differ between active and churned customers?
SELECT
    c.customer_status,
    COUNT(DISTINCT c.customer_id) customers,
    COUNT(u.event_id) total_events,
    ROUND(
        COUNT(u.event_id) /
        NULLIF(COUNT(DISTINCT u.customer_id), 0),
        2
    ) avg_events_per_customer
FROM customers c
LEFT JOIN usage_events u
    ON c.customer_id = u.customer_id
GROUP BY c.customer_status;
-- Average usage is almost identical for active and churned customers:
-- 20.01 versus 19.98 events per customer.

-- Do churned customers show declining activity in the 90 days before their end_date?
WITH churned_customers AS (
    SELECT
        customer_id,
        MAX(end_date) AS churn_date
    FROM subscriptions
    WHERE status = 'Churned'
      AND end_date IS NOT NULL
    GROUP BY customer_id
),
customer_usage AS (
    SELECT
        c.customer_id,
        c.churn_date,
        SUM(
            CASE
                WHEN u.event_timestamp >=
                     DATE_SUB(c.churn_date, INTERVAL 180 DAY)
                 AND u.event_timestamp <
                     DATE_SUB(c.churn_date, INTERVAL 90 DAY)
                THEN 1 ELSE 0
            END
        ) AS previous_90_days,
        SUM(
            CASE
                WHEN u.event_timestamp >=
                     DATE_SUB(c.churn_date, INTERVAL 90 DAY)
                 AND u.event_timestamp < c.churn_date
                THEN 1 ELSE 0
            END
        ) AS final_90_days
    FROM churned_customers c
    LEFT JOIN usage_events u
        ON u.customer_id = c.customer_id
       AND u.event_timestamp >=
           DATE_SUB(c.churn_date, INTERVAL 180 DAY)
       AND u.event_timestamp < c.churn_date
    GROUP BY c.customer_id, c.churn_date
)
SELECT
    CASE
        WHEN churn_date = '2025-12-31'
            THEN 'December 31 cohort'
        ELSE 'Other churn dates'
    END AS cohort,
    COUNT(*) AS customers,
    ROUND(AVG(previous_90_days), 2) AS previous_90_day_avg,
    ROUND(AVG(final_90_days), 2) AS final_90_day_avg,
    ROUND(
        100.0 * (
            AVG(final_90_days) - AVG(previous_90_days)
        ) / NULLIF(AVG(previous_90_days), 0),
        2
    ) AS percentage_change,
    SUM(final_90_days > previous_90_days) AS usage_increased,
    SUM(final_90_days = previous_90_days) AS usage_unchanged,
    SUM(final_90_days < previous_90_days) AS usage_decreased
FROM customer_usage
GROUP BY
    CASE
        WHEN churn_date = '2025-12-31'
            THEN 'December 31 cohort'
        ELSE 'Other churn dates'
    END;
-- Finding: Average recorded usage increased in the final 90 days before churn compared with the preceding 90 days.]
-- This increase was 73.95% for customers whose churn date was 2025-12-31 and 52.41% for customers with other churn dates.
--
-- Across all 4,693 churned customers, 45.96% increased usage, 27.15% showed no change, and 26.89% decreased usage.
-- The unusually high concentration of churn dates on 2025-12-31 raises a significant data-quality concern.
-- These results do not establish declining usage as a reliable warning signal for churn.

-- Recommendation: Investigate the concentration of subscription end
-- dates on 2025-12-31 and validate the reliability of these dates.
-- Further analyse engagement alongside other customer characteristics
-- before using usage changes to identify customers at risk of churn.


-- Engagement Summary:
-- Churned customers averaged 24.19 events overall vs 32.30 for active customers.
-- However, average recorded usage increased in the final 90 days before churn compared with the preceding 90 days.
-- Usage increased by 52.41% for customers with churn dates other than 2025-12-31, and by 73.95% for the 2025-12-31 cohort.
-- Across all 4,693 churned customers, 45.96% increased usage, 27.15% showed no change, and 26.89% decreased usage.
-- The unusually high concentration of churn dates on 2025-12-31 raises a data-quality concern. 
-- Declining usage is not established as a reliable early warning signal for churn.
-- Recommendation: Investigate the concentrated churn dates and analyse engagement alongside other customer characteristics before identifying potentially at-risk customers.
-----------------------------------------------

-- 4. Sales pipeline:
-- Total opportunities and win rate overall
SELECT COUNT(*) total_opportunities, 
	COUNT(CASE
		WHEN stage = "Closed Won" THEN 1
        END) closed_won,
		COUNT(CASE
        WHEN stage = "Closed Lost" THEN 1
        END) closed_lost,
        COUNT(CASE
        WHEN stage IN ("Closed Won", "Closed Lost") THEN 1
        END) total_closed,
	ROUND((COUNT(CASE
		WHEN stage = "Closed Won" THEN 1
        END) * 100) / COUNT(CASE
        WHEN stage IN ("Closed Won", "Closed Lost") THEN 1
        END), 2) win_rate_percentage
FROM opportunities;
-- There are 30000 opportunities, 14190 are closed opportunties either won or lost and the remaining are either qualified, proposed or in negotiation.
-- The win rate is 68.33% so majority are won deals of those that are closed.

-- Win rate by lead source
SELECT lead_source, COUNT(*) total_opportunities, 
	COUNT(CASE
		WHEN stage = "Closed Won" THEN 1
        END) closed_won,
		COUNT(CASE
        WHEN stage = "Closed Lost" THEN 1
        END) closed_lost,
        COUNT(CASE
        WHEN stage IN ("Closed Won", "Closed Lost") THEN 1
        END) total_closed,
	ROUND((COUNT(CASE
		WHEN stage = "Closed Won" THEN 1
        END) * 100) / COUNT(CASE
        WHEN stage IN ("Closed Won", "Closed Lost") THEN 1
        END), 2) win_rate_percentage
FROM opportunities
GROUP BY lead_source;
-- Overall similar win rates across lead sources, ranging from 68.14% (Referral) to 70.68% (Paid Search).
-- This suggests win rate isn't due to a certain lead source

-- Win rate by sales rep
SELECT sales_rep, COUNT(*) total_opportunities, 
	COUNT(CASE
		WHEN stage = "Closed Won" THEN 1
        END) closed_won,
		COUNT(CASE
        WHEN stage = "Closed Lost" THEN 1
        END) closed_lost,
        COUNT(CASE
        WHEN stage IN ("Closed Won", "Closed Lost") THEN 1
        END) total_closed,
	ROUND((COUNT(CASE
		WHEN stage = "Closed Won" THEN 1
        END) * 100) / COUNT(CASE
        WHEN stage IN ("Closed Won", "Closed Lost") THEN 1
        END), 2) win_rate_percentage
FROM opportunities
GROUP BY sales_rep
ORDER BY win_rate_percentage;
-- Slightly varied win rates but still around the overall win rate. 
-- The sales rep win rate is ranged from 65.48% (Rep 19) to 70.85% (rep 7).
-- This suggests that not even a specific sales rep is responsible for the win rate but overall all sales reps contribute.


-- Average days to close a deal
SELECT stage, AVG(TIMESTAMPDIFF(DAY, created_at, close_date)) avg_days_to_close_deal
FROM opportunities
WHERE stage IN ("Closed Won", "Closed Lost")
GROUP BY stage;
-- Almost identical in how many days to clsoe a deal between deals won and lost.
-- Won deals closed at average of 76.57 days and lost deals closed at an average of 76.73 days.

-- Win rates were relatively consistnet aross lead sources and sales representatives, with some variation between groups.
-- From what I've observed, the analysis didn't identify a clear standout group. 
-- Recommendation: Northstar should investigate ways to improve performance of sales reps to increase the win rate and successfully clsoe deals more efficiently.

----------

-- Support tickets:
-- Ticket volume by category
SELECT category, COUNT(*) ticket_count
FROM support_tickets
GROUP BY category
ORDER BY ticket_count DESC;
-- Account and Performance are the leading categories for support tickets. 
-- Although all categories have siginficant support tickets ranging from 8192 to 8443. 

-- Average resolution time. Will also include min and max resolution time
SELECT
	AVG(resolution_hours) avg_hours,
    MIN(resolution_hours) min_hours,
    MAX(resolution_hours) max_hours
FROM support_tickets
WHERE status = "Resolved";
-- On average it takes Northstar 21 hours to resolve a problem.
-- An odd number of -1 hour for the min which should be investigated as that is impossible.
-- The longest its taken Northstar to resolve an issue is 132 hours.
-- Let's investigate the -1 and if there are any other negative values
SELECT *
FROM support_tickets
WHERE resolution_hours <= 0;
-- There are 25 rows of negative values. When I checked the data i said i would investigate why.No other data looks odd so not reasoning other than there was never an error but even then that wouldnt make sense so jusrt an error.

-- Do churned customers raise more tickets than active ones
SELECT s.status, COUNT(DISTINCT st.ticket_id) total_tickets
FROM support_tickets st
JOIN subscriptions s
	ON st.customer_id = s.customer_id
GROUP BY s.status;
-- Active has 31665 tickets while churned has 15624 tickets.
-- Active customers have almost double the amount of tickets than churned customers

-- I'm interested to see the time relationship for churned customers, from when they raised a support ticket to when they churned.
WITH final_churn AS (
    SELECT
        customer_id,
        MAX(end_date) churn_date
    FROM subscriptions
    WHERE status = 'Churned'
      AND end_date IS NOT NULL
    GROUP BY customer_id
)
SELECT
    CASE
	WHEN st.created_at <= fc.churn_date
	THEN 'Before or on churn date'
	ELSE 'After churn date'
    END AS ticket_timing,
    COUNT(DISTINCT st.ticket_id) ticket_count,
    AVG(TIMESTAMPDIFF(DAY, st.created_at, fc.churn_date)
    ) avg_days_from_ticket_to_churn
FROM support_tickets st
JOIN final_churn fc
    ON st.customer_id = fc.customer_id
GROUP BY ticket_timing;
-- The average days for tickets after churn date is -168 and before or on churn date is 320.  
-- Customers can contact support after churning.
-- That’s why there's get negatives - ticket created after end_date. 


-- Support Summary:
-- All ticket categories are relatively balanced (8192 to 8443 ticekts each).
-- Average resolution time is 21 hours with a maximum of 132 hours.
-- 25 tickets have invalid negative resolution hours and should be investigated
-- Active customers generate almost double the tickets of churned customers
-- This is expected given the active customers are still using the product
-- Most churned customer tickets (avg 320 days before churn) were raised well before cancellation
-- This suggests support issues alone don't directly cause churn.


















