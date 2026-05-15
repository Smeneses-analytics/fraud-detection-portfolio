# Fraud Detection Portfolio

Production-grade SQL queries, fraud terminology documentation, and operational 
case studies for fraud detection in BNPL (Buy Now Pay Later) environments.

## Disclaimer

This portfolio is an independent learning project developed for 
educational purposes and professional skill demonstration. 

All content — including SQL queries, fraud terminology documentation, 
detection logic, and observed patterns — reflect publicly available 
concepts and industry-standard frameworks in fraud detection. The 
SQL queries operate on a self-created PostgreSQL database with 
synthetic data designed specifically for learning purposes; they do 
not reference, replicate, or derive from any real organization's 
data, systems, or internal processes.

Nothing in this repository represents proprietary information, 
internal procedures, operational data, customer information, or 
official positions of any current or past employer. All examples, 
patterns, and observations are illustrative and generalized from 
publicly documented fraud typologies in the BNPL and financial 
services industry.

## About

This portfolio reflects hands-on work developed during my transition from 
Customer Service Agent to Fraud Operations Analyst. It combines 
technical SQL skills with fraud domain knowledge gained through the Extended 
Fraud Alerts (EFA) verification work.

## Structure

| Folder | Contents |
|--------|----------|
| `sql_queries/` | PostgreSQL queries for fraud pattern detection |
| `fraud_terminology/` | Documentation of fraud types relevant to BNPL |
| `case_studies/` | Real-world fraud detection scenarios and analysis |
| `regulatory_tracker/` | BNPL regulatory landscape and compliance updates |

## SQL Queries Index

| File | Purpose | Techniques |
|------|---------|------------|
| 01_velocity_analysis.sql | Detect transaction bursts (3+ in 1 hour) | Window functions with RANGE BETWEEN, conditional aggregation |
| 02_collusion_detection.sql | Identify merchants with concentrated user activity | ROW_NUMBER ranking, multi-CTE assembly |
| 03_first_transaction_risk.sql | Risk-label first transactions by time-of-day | ROW_NUMBER for first event, time extraction |
| 04_escalation_detection.sql | Detect users with escalating transaction amounts | Conditional aggregation, ratio analysis |
| 05_temporal_drift_detection.sql | Identify abrupt hour pattern changes (ATO indicator) | Circular distance, conditional aggregation, percentage calculations |

## Fraud Terminology Documented

- Account Takeover (ATO)
- Synthetic Identity Fraud (SIF)

## Schema Reference

All SQL queries operate on a `transactions` table:

| Column | Type | Description |
|--------|------|-------------|
| txn_id | SERIAL PRIMARY KEY | Unique transaction identifier |
| user_id | VARCHAR(10) | Customer identifier |
| amount | DECIMAL(10,2) | Transaction amount in USD |
| merchant | VARCHAR(30) | Merchant name |
| txn_time | TIMESTAMP | Transaction timestamp |

## Background

Currently working in the Customer Service department, supporting the Extended Fraud Alerts (EFA) team at a BNPL company. This portfolio represents preparation 
for transition into Fraud Operations Analyst and subsequently Fraud Data 
Analyst roles.

Active interests: synthetic identity detection, regulatory compliance 
(Reg E/EFTA, Reg P/GLBA, FCRA), and BNPL-specific fraud patterns.

## Contact

Santiago Meneses

www.linkedin.com/in/santiago-meneses-454097248


 
