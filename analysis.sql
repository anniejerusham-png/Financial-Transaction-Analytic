-- FinSight SQL Analysis
-- Synthetic financial transaction dataset
-- Load the CSV into a table named transactions.

-- Executive KPIs
SELECT COUNT(*) AS total_transactions,
       ROUND(SUM(transaction_amount_inr),2) AS total_value_inr,
       ROUND(AVG(transaction_amount_inr),2) AS avg_transaction_inr,
       ROUND(100.0*SUM(CASE WHEN transaction_status='Success' THEN 1 ELSE 0 END)/COUNT(*),2) AS success_rate_pct,
       SUM(CASE WHEN transaction_status='Failed' THEN 1 ELSE 0 END) AS failed_transactions,
       SUM(CASE WHEN fraud_flag='Yes' THEN 1 ELSE 0 END) AS suspicious_transactions
FROM transactions;

-- Monthly trend
SELECT DATE_TRUNC('month',transaction_date) AS month,
       COUNT(*) AS transaction_count,
       ROUND(SUM(transaction_amount_inr),2) AS transaction_value_inr
FROM transactions GROUP BY 1 ORDER BY 1;

-- Merchant category performance
SELECT merchant_category, COUNT(*) AS transaction_count,
       ROUND(SUM(transaction_amount_inr),2) AS transaction_value_inr,
       ROUND(AVG(transaction_amount_inr),2) AS avg_transaction_inr
FROM transactions GROUP BY merchant_category
ORDER BY transaction_value_inr DESC;

-- Payment methods and failure rates
SELECT payment_method, COUNT(*) AS transaction_count,
       ROUND(SUM(transaction_amount_inr),2) AS transaction_value_inr,
       SUM(CASE WHEN transaction_status='Failed' THEN 1 ELSE 0 END) AS failed_transactions,
       ROUND(100.0*SUM(CASE WHEN transaction_status='Failed' THEN 1 ELSE 0 END)/COUNT(*),2) AS failure_rate_pct
FROM transactions GROUP BY payment_method
ORDER BY transaction_value_inr DESC;

-- Geographic performance
SELECT city, COUNT(*) AS transaction_count,
       ROUND(SUM(transaction_amount_inr),2) AS transaction_value_inr
FROM transactions GROUP BY city ORDER BY transaction_value_inr DESC;

-- Customer segments
SELECT customer_segment, COUNT(DISTINCT customer_id) AS customers,
       COUNT(*) AS transaction_count,
       ROUND(SUM(transaction_amount_inr),2) AS transaction_value_inr
FROM transactions GROUP BY customer_segment
ORDER BY transaction_value_inr DESC;

-- Suspicious activity by merchant category
SELECT merchant_category,
       SUM(CASE WHEN fraud_flag='Yes' THEN 1 ELSE 0 END) AS suspicious_transactions,
       COUNT(*) AS total_transactions,
       ROUND(100.0*SUM(CASE WHEN fraud_flag='Yes' THEN 1 ELSE 0 END)/COUNT(*),2) AS suspicious_rate_pct
FROM transactions GROUP BY merchant_category
ORDER BY suspicious_rate_pct DESC;

-- Customer ranking using a window function
SELECT customer_id, customer_segment, COUNT(*) AS transaction_count,
       ROUND(SUM(transaction_amount_inr),2) AS total_spend_inr,
       RANK() OVER (ORDER BY SUM(transaction_amount_inr) DESC) AS spend_rank
FROM transactions
GROUP BY customer_id, customer_segment
ORDER BY spend_rank LIMIT 20;

-- High-value transactions
SELECT transaction_id, transaction_date, customer_id, merchant_category,
       payment_method, city, transaction_amount_inr, transaction_status, fraud_flag
FROM transactions
WHERE transaction_amount_inr >= 50000
ORDER BY transaction_amount_inr DESC LIMIT 25;
