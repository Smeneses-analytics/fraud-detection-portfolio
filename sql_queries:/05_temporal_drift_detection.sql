-- ============================================================================
-- TEMPORAL DRIFT DETECTION: ABRUPT HOUR PATTERN CHANGES
-- ============================================================================
-- Author: Santiago Meneses
-- Date: 2026-05-13
-- Database: PostgreSQL
--
-- Purpose: Identifies users whose transaction hour patterns shift abruptly 
-- between their historical behavior and their most recent activity. This 
-- detection targets:
--   - Account Takeover (ATO), where the attacker operates in a different 
--     time zone than the legitimate customer
--   - Sold or shared account access where operational ownership changed
--   - Bot automation operating on schedules distinct from the human user
--
-- Logic: Splits each user's transactions into HISTORICAL (all but last 3) 
-- and RECENT (last 3 by timestamp). Computes the average hour for each segment 
-- using the circular distance formula to account for the cyclical nature of 
-- hours (e.g., 23:00 and 01:00 are 2 hours apart, not 22).
--
-- Key technique: Conditional aggregation combined with circular distance 
-- calculation (LEAST function applied to absolute difference and its 
-- 24-hour complement).
--
-- Output: One row per user with at least 6 transactions, including 
-- historical/recent average hours, hour shift magnitude, night percentages 
-- for each segment and risk label.
--
-- Note: Thresholds (8 / 6 / 3) are illustrative. Production thresholds 
-- would be calibrated from historical fraud cases using an analysis of 
-- shift magnitude distribution among confirmed ATO incidents.
-- ============================================================================

WITH 
	transrank AS 
(
SELECT 
	user_id,
	amount, 
	txn_time,
	EXTRACT(HOUR FROM txn_time) AS hours,
	COUNT (*) OVER (PARTITION BY user_id) AS total_transactions, 
	ROW_NUMBER () OVER (PARTITION BY user_id ORDER BY txn_time DESC) AS recency_rank
FROM 
	transactions	
), 
labeled AS 
(
SELECT
	user_id, 
	hours,
	total_transactions, 
	recency_rank, 
	CASE 
		WHEN recency_rank <= 3 THEN 'RECENT' ELSE 'HISTORICAL' 
			END AS timeframe, 
	CASE 
		WHEN hours BETWEEN 0 AND 5 THEN 'NIGHT' ELSE 'NOT NIGHT' END AS night_label
FROM
	transrank
),
metrics AS 
(
SELECT 
	user_id, 
	MAX(total_transactions) AS total_transactions_1,
	ROUND (AVG (CASE WHEN timeframe = 'RECENT' THEN hours END)) AS recent_avg_hour ,
	
	ROUND(AVG (CASE WHEN timeframe = 'HISTORICAL'THEN hours END)) AS historical_avg_hour, 
	
	ROUND (COUNT (CASE WHEN timeframe = 'RECENT' AND night_label = 'NIGHT' THEN 1 END) * 100.0/
	NULLIF(COUNT(CASE WHEN timeframe = 'RECENT' THEN 1 END),0)) AS recent_night_pct, 
	
	ROUND(COUNT (CASE WHEN timeframe = 'HISTORICAL' AND night_label = 'NIGHT' THEN 1 END) *100.0/
	NULLIF(COUNT (CASE WHEN timeframe = 'HISTORICAL' THEN 1 END),0)) AS historical_night_pct
FROM 
	labeled
GROUP BY 
	user_id
	
	
	
), 
magnitude AS 
	(SELECT 
		user_id, 
		LEAST 
		(ABS(recent_avg_hour - historical_avg_hour), 
		24 - ABS(recent_avg_hour - historical_avg_hour) 
		) AS hour_shift_magnitude 
FROM 
	metrics	
		)


SELECT 
	metrics.user_id,
	total_transactions_1, 
	recent_avg_hour, 
	historical_avg_hour, 
	hour_shift_magnitude, 
	recent_night_pct, 
	historical_night_pct, 
	CASE
		WHEN hour_shift_magnitude > 8 AND recent_night_pct > historical_night_pct + 50 THEN 'CRITICAL DRIFT'
		WHEN hour_shift_magnitude > 6 THEN 'HIGH DRIFT'
		WHEN hour_shift_magnitude BETWEEN 3 AND 6 THEN 'MODERATE DRIFT'
		ELSE 'NORMAL'
			END AS risk_label
FROM 
	metrics
JOIN magnitude ON metrics.user_id=magnitude.user_id

WHERE 
	total_transactions_1 >= 6

ORDER BY 
	hour_shift_magnitude DESC