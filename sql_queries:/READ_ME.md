# SQL Queries — Fraud Detection Portfolio

This folder contains production-grade SQL queries developed for fraud 
detection scenarios in a BNPL (Buy Now Pay Later) context. All queries 
operate on PostgreSQL.

## Index

| File | Purpose | Key Techniques |
|------|---------|----------------|
| 01_velocity_analysis.sql | Detect transaction bursts (3+ in 1 hour) | Window functions with RANGE BETWEEN, conditional aggregation |
| 02_collusion_detection.sql | Identify merchants with concentrated user activity | ROW_NUMBER ranking, multi-CTE assembly, percentage calculations |
| 03_first_transaction_risk.sql | Risk-label first transactions by time-of-day | ROW_NUMBER for first event, time extraction, CASE WHEN labeling |

## Schema

All queries operate on a `transactions` table:

| Column | Type | Description |
|--------|------|-------------|
| txn_id | SERIAL PRIMARY KEY | Unique transaction identifier |
| user_id | VARCHAR(10) | Customer identifier |
| amount | DECIMAL(10,2) | Transaction amount in USD |
| merchant | VARCHAR(30) | Merchant name |
| txn_time | TIMESTAMP | Transaction timestamp |

## Author

Santiago Meneses — Customer Service Agent → Fraud Operations transition.
Currently working on Sezzle as a Customer Service Specialist supporting the Extended Fraud Alerts (EFA) team.
