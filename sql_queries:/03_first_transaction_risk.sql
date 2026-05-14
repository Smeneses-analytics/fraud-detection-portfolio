
-- ============================================================================
-- FIRST TRANSACTION RISK ASSESSMENT
-- ============================================================================
-- Author: Santiago Meneses
-- Date: 2026-04-19
-- Database: PostgreSQL
--
-- Purpose: Risk-labels each user's first transaction based on time-of-day. 
-- First transactions are the most vulnerable point for new accounts — common 
-- vector for synthetic identity fraud and account takeover testing.
--
-- Output: One row per user with first transaction details and risk label.
-- ============================================================================


-- INPUT: Transactions
-- OUTPUT: user_id, first_transaction_time
--			una fila por cliente 
--Purpose: Calculate the first transaction of every user with their date 
WITH 
	first_transaction_time AS 
		(
SELECT 
	user_id, 
	MIN(txn_time) AS first_transaction_date
FROM 
	transactions
GROUP BY 
	user_id
ORDER BY 
	user_id
), 

--INPUT: Transactions
--Outcome: user_id, txn_time, amount, ROW_NUMBER ORDER ASC since we need the oldest and the oldest is the most chiquita 
--Purpose: to create a numeration so that on a new CTE we can just select the first of every user, and then we will be able to see the first amount of every user.
	-- UN montón de filas por usuario 

numeration_amount AS 
	(
SELECT
	user_id,  
	amount AS first_amount, 
	txn_time,
	ROW_NUMBER () OVER (PARTITION BY user_id ORDER BY txn_time) AS transaction_rank, 
	merchant AS first_merchant
FROM 
	transactions 
GROUP BY 
	user_id, 
	amount,
	merchant,
	txn_time
),

--INPUT:numeration_amount
--OUTPUT:USER_ID, first_amount, first_merchant, txn_time WHERE transaction_rank = 1
--PURPOSE: Determine the fisrst ammount and merchant of every user. 


first_amount_filter AS
(
SELECT 
	user_id, 
	first_amount, 
	first_merchant,
	txn_time
FROM 
	numeration_amount
WHERE
	transaction_rank = 1
	
), 

-- INPUT:first_transaction_time
-- OUTPUT: User_id, hour, risk_label
--Purpose: Create the flag depending on the hours of teh tarsnasction on every user base on this order :
--HIGH RISK: primera transacción entre 12:00 AM y 5:59 AM
--MEDIUM RISK: primera transacción entre 6:00 AM - 8:59 AM o entre 10:00 PM - 11:59 PM
--LOW RISK: cualquier otro horario

label_conditions AS 
(
SELECT 
	user_id,
	EXTRACT (HOUR FROM first_transaction_date) AS hour_, 
	(CASE 
		WHEN EXTRACT (HOUR FROM first_transaction_date) BETWEEN 0 AND 5 THEN 'HIGH RISK'
		WHEN EXTRACT (HOUR FROM first_transaction_date) BETWEEN 6 AND 8 THEN 'MEDIUM RISK'
		WHEN EXTRACT (HOUR FROM first_transaction_date) BETWEEN 22 AND 23 THEN 'MEDIUM RISK'
		ELSE 'LOW RISK'
			END) AS risk_label
FROM
	first_transaction_time
)

--FINAL SELECT 


SELECT
	label_conditions.user_id, 
	first_transaction_date, 
	first_amount, 
	first_merchant,
	risk_label
FROM 
	first_transaction_time
JOIN first_amount_filter ON first_transaction_time.user_id = first_amount_filter.user_id
JOIN label_conditions ON first_transaction_time.user_id = label_conditions.user_id
	



--JOIN: first_transaction_time, first_amount_filter, label_conditions
