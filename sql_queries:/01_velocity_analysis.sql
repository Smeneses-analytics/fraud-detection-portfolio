-- ============================================================================
-- VELOCITY ANALYSIS: TRANSACTION BURST DETECTION
-- ============================================================================
-- Author: Santiago Meneses
-- Date: 2026-04-22
-- Database: PostgreSQL
--
-- Purpose: Identifies users with 3+ transactions within a 1-hour window — a
-- pattern associated with card testing fraud, bot automation, or account 
-- takeover where attackers drain accounts rapidly before detection.
--
-- Output: One row per suspicious user with severity label (CRITICAL/HIGH).
-- ============================================================================
-- INPUT: transactions 
-- OUTPUT:user_id, txn_time,transactions_last_hour
--Purpose: Determine the quantity of transactiosn per a specific time interval

With 
	transactions_x_hour AS
(
SELECT 
	user_id, 
	txn_time, 
	amount,
	COUNT(*) OVER (PARTITION BY user_id ORDER BY txn_time RANGE BETWEEN INTERVAL '1 hour' PRECEDING AND CURRENT ROW) AS transactions_last_hour,
	SUM(amount) OVER (PARTITION BY user_id ORDER BY txn_time RANGE BETWEEN INTERVAL '1 hour' PRECEDING AND CURRENT ROW) AS spent_last_hour
FROM 
	transactions
GROUP BY 
	user_id, 
	txn_time,
	amount
ORDER BY 
	user_id, 
	txn_time
	
),


-- INPUT:transactions
-- OUTPUT:user_id, total_transactions
--Purpose:Trnsactions total per user. 
tr AS 
(
SELECT 
	user_id, 
	COUNT(*) AS total_transactions
FROM 
	transactions 
GROUP BY 
	user_id
),


-- INPUT:transactions_x_hour
-- OUTPUT:user_id, txn_time, transactions_last_hour, spent_last_hour,total_transactions_per_interval
--Purpose:Determine what is teh ma xammount of transactions in a intreval of 1 hr per user_id

max_ AS
(
SELECT 
	user_id, 
	txn_time,
	transactions_last_hour,
	spent_last_hour,
	ROW_NUMBER () OVER (PARTITION BY user_id ORDER BY transactions_last_hour DESC,txn_time ASC) AS transactions_rank 
FROM 
	transactions_x_hour
), 



-- INPUT:max_
-- OUTPUT:user_id,txn_time,transactions_last_hour,spent_last_hour,transactions_rank =1
--Purpose:Determine the one en unique moment when the shopper has more or 3 transactions on an interval of 1 hr and find the major one
filter_1 AS
(
SELECT
	user_id, 
	txn_time,
	transactions_last_hour,
	spent_last_hour,
	transactions_rank 
FROM 
	max_ 
WHERE 
	transactions_rank =1
), 

-- INPUT:filter_1
-- OUTPUT:user_id, initial_time_interval,transactions_last_hour, spent_last_hour, label_1
--Purpose: Calculate the initial time of the interval of transactions per user and also create the label 
almost_there AS
(
SELECT
	user_id, 
	(txn_time - INTERVAL '1 hour') AS initial_time_interval,
	transactions_last_hour,
	spent_last_hour,
	(CASE 
		WHEN transactions_last_hour > 5 THEN 'CRITICAL'
		WHEN transactions_last_hour >= 3 THEN 'HIGH'
		WHEN transactions_last_hour < 3 THEN 'NORMAL'
		END) AS Label_1
FROM 
	filter_1
)

--final select 

SELECT 
	almost_there.user_id,
	total_transactions,
	transactions_last_hour,
	initial_time_interval,
	spent_last_hour,
	Label_1
FROM 
	almost_there JOIN tr ON almost_there.user_id=tr.user_id
WHERE transactions_last_hour >= 3
ORDER BY 
	transactions_last_hour DESC, 
	total_transactions DESC
	