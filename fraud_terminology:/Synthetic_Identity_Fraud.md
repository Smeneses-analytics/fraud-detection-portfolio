# Synthetic Identity Fraud (SIF) — BNPL Context

## Definition

An SIF appears when an account is created with a mix of hybrid information, real and fake information from a person taking the SSN from deceased persons or minor children. This person grows and enhances their image with financial companies, requests more credit, and, at their peak credit limit, will request the full amount and will not pay again. 

### Anatomy of a Synthetic Identity and lifecycle 

-	Real and fake information from a person who matches the credit bureau, usually the SSN of a death person or a child
-	Fabricated PII, fake name, fake address, fake DOB 
-	New contact information (Email, phone)
-	The address could be a real address, but not their real address, or a mail forwarding address

### Lifecycle

-	Cultivation (6-24 months): The customer builds a good relationship with the financial institution that they would like to take advantage of 
-	Maturation: After building a good reputation, they start requesting an increase on their loans and start using it in full
-	Bust-out: After building a very good relationship with the financial institution and requesting an important loan amount, they disappear and never pay it again 

### Detection Signals

#### Pre-bust-out

-	The person calling is not sure about their personal information (They doubt when someone asks for their DOB or their maiden name)
-	A person with a lot of different information not related to the account, when they start providing a lot of addresses and phone numbers, and email is not a good sign 
-	Someone is whispering in the background during the call when we are doing the verification process

#### Bust-out-signals (investigate immediately):

-	Very good behaviour paying, and suddenly stopped paying all their accounts, and have not contacted the company to inform them why 
-	Not getting any contact in the last 2 months despite having recurring late payments 
-	Remove their payment method or request the revocation of their payment method after having some failed payments 

### Why is Critical for BNPL

-	BNPL company assumes the responsibility since the company has been trusting this shopper for some time, since this shopper has been having a good payment history, and suddenly the shopper disappears, and when the accounts are sent to collections, there is nobody to charge that debt. 
-	This generates additional costs since the BNPL company assumes 100% of the loss.

### Connection with EFA work: (Pending)

The EFA verification is a critical checkpoint for SIF. During the call, we can determine whether the person is who they claim to be, since EFA calls are unexpected.  As part of the verification process, probing questions are asked that they must answer on the spot. 

Furthermore, the customer is informed that there is an EFA tied to their information, and they will be asked if they have tried to use the company’s services, to which the shopper will answer positively, while a fraudster may hesitate or contradict themselves.

Additionally, EFA verification applies to both ATO fraud and SIF. When the credit bureau is not able to provide enough information about the person in question, that scenario can be flagged as a potential SIF. 

