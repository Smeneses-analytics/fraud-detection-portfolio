# Account Takeover (ATO) — BNPL Context

## Definition
An ATO appears when a third party accesses a legitimate existing account without authorization. 
## Attack Vectors
Credential Stuffing:  Reused passwords leaked in external breaches.
Phishing: Victim submits credentials to spoofed sites 
SIM Swap:  the thief is able to change the customer’s SIM to his phone to be able to get the 2FA codes and access to the account to place orders. 
Malware/Keylogging: Compromise device captures credentials.
## Detection Signals
Severity classification criteria: 
Three criteria classify signals:
###1. Damage irreversibility (How fast/how much is lost if ignored)
###2. Signal specificity (How unique the fraud vs normal user behavior)
###3. Isolability (Whether the signal alone warrants actions or requires a combination) 
#### High-severity red flags (investigate immediately):
-	Password reset attempts before transaction attempt
-	Multiple 2FA requests (+3) within 24 hrs
-	Gift card purchase from a user with no historical gift card activity 
-	Log in from new devices or unusual IP geolocation
-	Shipping address differs from the billing address and from historical addresses 
#### Medium-severity red flags (escalate if combined):
-	Email or phone number change preceding the transaction
-	Payment method change preceding transaction
-	First-time merchant with an atypical amount.


## Why ATO is Critical for BNPL
-	BNPL company assumes the responsibility for the fraudulent charge, the merchant receives their payment, and the BNPL company’s reputation will be damaged.
-	Regulation E/EFTA requires reimbursement to the legitimate account holder. 
-	CFPB risk: Repeated complaints trigger supervisory review (Supervisory highlight issue 33)
-	Operational cost: Investigation hours + reputational damage + legitimate user churn, which is the calculation of the time a shopper stops doing business with a specific merchant. 

## Observed Pattern (EFA / CS Experience)
Accounts from elderly customers, or used by a relative, are more prone to being at risk; customers who are not tech-savvy are more prone to being affected by this fraud type. 


