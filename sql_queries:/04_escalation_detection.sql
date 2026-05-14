-- ============================================================================
-- ESCALATION PATTERN DETECTION
-- ============================================================================
-- Author: Santiago Meneses
-- Date: 2026-05-12
-- Database: PostgreSQL
--
-- Purpose: Identifies users whose average transaction amount increases 
-- significantly between the first and second halves of their transaction 
-- history. This pattern is associated with synthetic identity maturation, 
-- account testing, and credit limit probing — all common precursors to 
-- bust-out fraud in BNPL platforms.
--
-- Output: One row per user with at least 4 transactions, including 
-- first/last amounts, half averages, escalation ratio, and risk label.
-- ============================================================================

--INPUT: Transactions
--OUTPUT:user_id, transtotal
--OUTCOME: determine total transactions qty per user
With 
	total_transaction AS 
	(
SELECT  
	user_id,
	COUNT(*) AS transtotal
FROM 
	transactions 
GROUP BY 
	transactions.user_id
),
--INPUT: Transactions 
--OUTPUT:user_id, amount. txn_time, First_transactionrank
--OUTCOME: Create a rank orginzed by the first transaction to the last transaction of each user. 

faq AS
(
SELECT 
	user_id, 
	amount AS amountf1, 
	txn_time, 
	ROW_NUMBER () OVER (PARTITION BY user_id ORDER BY txn_time) AS First_transactionrank
FROM 
	transactions
	
), 
--INPUT: faq
--OUTPUT: user_id, amount, txn_time, ftr
--OUTCOME:Determines exactly the first transactions amount per user 
f1 AS 
(
SELECT 
	user_id, 
	amountf1,
	txn_time, 
	First_transactionrank AS ftr
FROM 
	faq
WHERE 
	First_transactionrank = 1

), 
--INPUT:transactions
--OUTPUT:user_id, amountf2, txn_time, last_transactionrank
--OUTCOME:Create the rank so we can use it later in another CTE to determine the last amount transaction per user 

laq AS 
(
SELECT 
	user_id, 
	amount AS amountf2, 
	txn_time, 
	ROW_NUMBER () OVER (PARTITION BY user_id ORDER BY txn_time DESC) AS last_transactionrank
FROM 
	transactions
), 
--INPUT:laq 
--OUTPUT:user_id, amountf2, txn_time, ltr
--OUTCOME: Determine the last transaction per user. 
f2 AS 
(
SELECT 
	user_id, 
	amountf2,
	txn_time, 
	last_transactionrank AS ltr
FROM 
	laq
WHERE 
	last_transactionrank = 1
	
), 
--INPUT: transactions join total_transaction
--OUTPUT:user_id, txn_time, avg_rank, half_label
--OUTCOME: Calculate teh first and second half of shopper's transactions
afh AS 
(
SELECT
	transactions.user_id, 
	amount,
	txn_time, 
	ROW_NUMBER () OVER (PARTITION BY transactions.user_id ORDER BY txn_time) AS avg_rank,
	CASE
		WHEN (ROW_NUMBER () OVER (PARTITION BY transactions.user_id ORDER BY txn_time) <= transtotal/2) THEN 'FIRST_HALF'
		WHEN (ROW_NUMBER () OVER (PARTITION BY transactions.user_id ORDER BY txn_time) > transtotal/2) THEN 'SECOND_HALF'
		ELSE 'NA'
			END AS half_label
FROM 
	transactions
JOIN 
	total_transaction ON 
		transactions.user_id=total_transaction.user_id
), 
--INPUT:afh
--OUTPUT: user_id, avg_first_half, avg_second_half 
--OUTCOME:Determine the avg of each half. 
avgs AS 
(
SELECT 
	user_id, 
	ROUND(AVG(CASE WHEN half_label= 'FIRST_HALF' THEN amount END),2) AS avg_first_half,
	ROUND (AVG (CASE WHEN half_label = 'SECOND_HALF' THEN amount END),2) AS avg_second_half
FROM 
	afh
GROUP BY 
	user_id
),
--INPUT:avgs 
--OUTPUT:user_id, avg_first_half,avg_second_half, ratio
--OUTCOME:Determine the ratio
esc_rat AS 
(
SELECT
	user_id,
	avg_first_half,
	avg_second_half,
ROUND((avg_second_half/NULLIF (avg_first_half,0)),2)AS ratio
FROM 
	avgs
), 
--INPUT:esc_rat 
--OUTPUT:User_id, risk_label_1
--OUTCOME: Risk label 
last_label AS 
(
SELECT 
	user_id, 
	CASE 
		WHEN ratio > 2.0 THEN 'HIGH ESCALATION'
		WHEN ratio BETWEEN 1.5 AND 2.0 THEN 'MODERATE ESCALATION'
		ELSE 'NORMAL'
			END AS risk_label_1
FROM 
	esc_rat
)

--Final 

SELECT 
	f1.user_id,
	transtotal, 
	amountf1,
	amountf2,
	esc_rat.avg_first_half, 
	esc_rat.avg_second_half,
	ratio,
	risk_label_1
FROM 
	total_transaction
JOIN f1 ON total_transaction.user_id=f1.user_id
JOIN f2 ON total_transaction.user_id=f2.user_id
JOIN avgs ON total_transaction.user_id=avgs.user_id
JOIN esc_rat ON total_transaction.user_id=esc_rat.user_id
JOIN last_label ON total_transaction.user_id=last_label.user_id

WHERE 
	transtotal >= 8
ORDER BY 
	ratio DESC