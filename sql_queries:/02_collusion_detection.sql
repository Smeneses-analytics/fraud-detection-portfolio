-- ============================================================================
-- COLLUSION DETECTION: TOP USER CONCENTRATION PER MERCHANT
-- ============================================================================
-- Author: Santiago Meneses
-- Date: 2026-04-29
-- Database: PostgreSQL
--
-- Purpose: Identifies merchants where transaction volume is concentrated 
-- among a few users — a pattern associated with bust-out fraud schemes, 
-- money laundering through shell merchants, or coordinated user abuse.
--
-- Output: One row per merchant with concentration metrics and risk label.
-- ============================================================================


WITH 
	mt AS
	(
SELECT 
	merchant,
	count(*) AS total_merchant_transaction
FROM 
	transactions
GROUP BY
	merchant
), 
--INPUT:Transactions
--OUTPUT:merchant,total_dinstinct_users_per_merchan
--OUTCOME: Number of users per merchant 
dt AS 
(
SELECT 
	merchant, 
	COUNT(DISTINCT user_id) AS total_distinct_users_per_merchant
FROM 
	transactions
GROUP BY 
	merchant	
), 
--INPUT:Transactions
--OUTPUT:merchant,user_id, total_transactions_per_user, rank_top_1
--OUTCOME: Create a rank based on the numebr of transactiosn per user by merchant
top1tr_ AS
(
SELECT
	merchant, 
	user_id, 
	count(*) AS total_transactions_per_user,
	ROW_NUMBER () OVER (PARTITION BY merchant ORDER BY COUNT(*)DESC, user_id)AS rank_top_1
FROM 
	transactions
GROUP BY 
	merchant, 
	user_id
), 
--INPUT:top1tr_
--OUTPUT:merchant,user_id, top_1_txn, top_1_pc Where rank=1
--OUTCOME: Determine the #1 of the user and their percentage compare the total merchants transactions 

top1_ftr AS
(
SELECT 
	mt.merchant, 
	user_id, 
	total_transactions_per_user AS top_1_txn,
	ROUND((total_transactions_per_user*100.00/total_merchant_transaction),2) AS top_1_pc
FROM 
	top1tr_ 
JOIN mt ON top1tr_.merchant = mt.merchant
WHERE 
	rank_top_1 = 1 
), 
--INPUT:top1tr_
--OUTPUT:merchant,user_id, top_2_txn, top_2_pc Where rank=2
--OUTCOME: Determine the #2 of the user and their percentage compare the total merchants transactions 
top2_ftr AS
(
SELECT 
	mt.merchant, 
	user_id, 
	total_transactions_per_user AS top_2_txn,
	ROUND((total_transactions_per_user*100.00/total_merchant_transaction),2) AS top_2_pc
FROM 
	top1tr_ 
JOIN mt ON top1tr_.merchant = mt.merchant
WHERE 
	rank_top_1 = 2 
)
SELECT 
	mt.merchant, 
	total_merchant_transaction, 
	total_distinct_users_per_merchant, 
	top_1_txn, 
	top_1_pc,
	top_2_txn,
	top_2_pc, 
	(CASE 
	WHEN top_1_pc > 50 THEN 'HIGH COLLUSION RISK'
	WHEN top_1_pc + top_2_pc > 70 THEN 'MEDIUM COLLUSION RISK'
	ELSE 'LOW RISK'
		END) AS risk_label
FROM
	mt
JOIN dt ON mt.merchant = dt.merchant
JOIN top1_ftr ON mt.merchant = top1_ftr.merchant
JOIN top2_ftr ON mt.merchant = top2_ftr.merchant
ORDER BY 
	CASE 
	WHEN top_1_pc > 50 THEN 'HIGH COLLUSION RISK'
	WHEN top_1_pc + top_2_pc > 70 THEN 'MEDIUM COLLUSION RISK'
	ELSE 'LOW RISK'
		END, 
	top_1_pc DESC
	
	

