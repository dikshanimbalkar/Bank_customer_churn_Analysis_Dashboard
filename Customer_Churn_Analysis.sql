
-- Data Quality & Initial Validation (SQL)
-- Check record count

select count(*) total from bankcustomerchurn;
select * from BankCustomerChurn;

-- Check for duplicates

select customerId,
count(*) as total
from bankcustomerchurn
group by customerId
having count(*) > 1;

-- Check null values

SELECT 
    SUM(CASE WHEN CreditScore IS NULL THEN 1 ELSE 0 END) AS null_creditscore,
    SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS null_age,
    SUM(CASE WHEN Balance IS NULL THEN 1 ELSE 0 END) AS null_balance
FROM BankCustomerChurn;
-- ***************************************************************************
--****************************************************************************

-- Exploratory Data Analysis (EDA) in SQL

-- Total customers and churn rate

select
	COUNT(*) total_customers,
	sum(case when Exited = 1 then 1 else 0 end) as churned_customers,
	concat(
		ROUND(100 * sum(case when Exited = 1 then 1 else 0 end) / COUNT(*), 2),
		'%'
	)as churn_rate 
from BankCustomerChurn

 -- Insight: Suppose churn_rate = 20%. That means 1 in 5 customers leave the bank.

-- Churn rate by Geography

select
	Geography,
	COUNT(*) total_customers,
	sum(case when Exited = 1 then 1 else 0 end) as churned_customers,
	concat(
		ROUND(100 * sum(case when Exited = 1 then 1 else 0 end) / COUNT(*), 2),
		'%'
	)as churn_rate 
from BankCustomerChurn
group by Geography
order by churn_rate desc;
-- Insight: Germany customers have the highest churn rate → possible dissatisfaction 
-- or competition in that market.

-- Churn rate by Gender

select
	Gender,
	COUNT(*) total_customers,
	sum(case when Exited = 1 then 1 else 0 end) as churned_customers,
	concat(
		ROUND(100 * sum(case when Exited = 1 then 1 else 0 end) / COUNT(*), 2),
		'%'
	)as churn_rate 
from BankCustomerChurn
group by Gender
order by churn_rate desc;
-- Insight: If Female churn rate > Male, HR or product team 
-- can explore gender-based product offerings.


-- Average balance and salary by churn status
-- 0=> Stayed and 1(Churned)

select
	Exited as churn_status,
	round(avg(Balance), 2) as avg_balance,
	ROUND(avg(estimatedSalary), 2) as avg_salary,
	ROUND(avg(creditScore),2) as avg_credit_score
from BankCustomerChurn
group by Exited;

-- Insight: Churners might have slightly higher balance 
-- (indicating dissatisfied high-value customers).

-- Age group churn

select Age,
	case 
		when Age < 30 then 'Under 30'
		when Age between 30 and 40 then '30-40'
		when Age between 41 and 50 then '41-50'
		else '51+'
	End as AgeGroup
from BankCustomerChurn

select
	case 
		when Age < 30 then 'Under 30'
		when Age between 30 and 40 then '30-40'
		when Age between 41 and 50 then '41-50'
		else '51+'
	End as AgeGroup,
	COUNT(*) total_customers,
	sum(case when exited = 1 then 1 else 0 end) as churned,
	concat(
		ROUND(100 * sum(case when exited = 1 then 1 else 0 end) / count(*), 2),
		'%') as churn_rate 
from BankCustomerChurn
group by 
		case 
		when Age < 30 then 'Under 30'
		when Age between 30 and 40 then '30-40'
		when Age between 41 and 50 then '41-50'
		else '51+'
	End 
order by churn_rate desc;

-- Insight: Customers between 51+ years might have higher churn → maybe they prefer other banks or better returns.

-- Tenure vs Churn (customer loyalty)
select
	Tenure,
	concat(
		ROUND(100 * sum(case when Exited = 1 then 1 else 0 end) / COUNT(*), 2),
		'%'
	)as churn_rate 
from BankCustomerChurn
group by Tenure
order by churn_rate desc;

-- Insight: New customers (low tenure) may churn quickly if onboarding is poor.

-- Product usage vs Churn

select
	NumOfProducts,
	concat(
		ROUND(100 * sum(case when Exited = 1 then 1 else 0 end) / COUNT(*), 2),
		'%'
	)as churn_rate 
from BankCustomerChurn
group by NumOfProducts
order by churn_rate;


-- Active vs Inactive Members
-- 1 = active customer 0 = inactive

select
	IsActiveMember,
	concat(
		ROUND(100 * sum(case when Exited = 1 then 1 else 0 end) / COUNT(*), 2),
		'%'
	)as churn_rate 
from BankCustomerChurn
group by IsActiveMember;
z
-- ******************************************************************

alter table bankcustomerchurn add RiskProxy float;

UPDATE BankCustomerChurn
SET RiskProxy = 
    (CASE WHEN IsActiveMember = 0 THEN 0.4 ELSE 0 END)
  + (CASE WHEN NumOfProducts = 1 THEN 0.3 ELSE 0 END)
  + (CASE WHEN Balance > 100000 THEN 0.2 ELSE 0 END)
  + (CASE WHEN CreditScore < 600 THEN 0.2 ELSE 0 END);

-- *************************************************************

  SELECT 
   round(AVG(RiskProxy),2) AS avg_risk
FROM BankCustomerChurn;

-- **************************************************************

SELECT TOP (100)
    CustomerId, Age, Balance, CreditScore, NumOfProducts, IsActiveMember, RiskProxy
FROM BankCustomerChurn
ORDER BY RiskProxy DESC;
-- *************************************************************

SELECT
    NumOfProducts,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS churned,
    CONCAT(ROUND(100.0 * SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) / COUNT(*),2),'%') AS churn_rate
FROM BankCustomerChurn
GROUP BY NumOfProducts
ORDER BY churn_rate DESC;

select * from bankcustomerchurn;

-- ******************************************************************

CREATE VIEW HighRiskCustomers AS
SELECT 
    CustomerId,
    Geography,
    Gender,
    Age,
    Balance,
    NumOfProducts,
    CreditScore,
    IsActiveMember,
    EstimatedSalary,
    CASE 
        WHEN Age > 40 AND Balance > 100000 AND IsActiveMember = 0 THEN 'High Risk'
        WHEN Age BETWEEN 30 AND 50 AND NumOfProducts = 1 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS RiskCategory
FROM BankCustomerChurn;

alter VIEW HighRiskCustomers AS
SELECT 
    CustomerId,
    Geography,
    Gender,
    Age,
    Balance,
    NumOfProducts,
    CreditScore,
    IsActiveMember,
    EstimatedSalary,
	Tenure,
	Exited,
	RiskProxy,
    CASE 
        WHEN Age > 40 AND Balance > 100000 AND IsActiveMember = 0 THEN 'High Risk'
        WHEN Age BETWEEN 30 AND 50 AND NumOfProducts = 1 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS RiskCategory
FROM BankCustomerChurn;

select *
from highriskcustomers



SELECT RiskCategory, COUNT(*) AS customer_count
FROM HighRiskCustomers
GROUP BY RiskCategory;


-- ********************************************************************

CREATE VIEW BankCustomer_RiskSegment AS
SELECT 
    CASE 
        WHEN Age < 30 THEN 'Low Risk (Under 30)'
        WHEN Age BETWEEN 30 AND 40 THEN 'Low Risk (30–40)'
        WHEN Age BETWEEN 41 AND 50 THEN 'Medium Risk (41–50)'
        ELSE 'High Risk (51+)'
    END AS RiskSegment,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS churned_customers,
    concat(ROUND(100 * SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) / COUNT(*), 2), '%') AS churn_rate
FROM BankCustomerChurn
GROUP BY 
   CASE 
        WHEN Age < 30 THEN 'Low Risk (Under 30)'
        WHEN Age BETWEEN 30 AND 40 THEN 'Low Risk (30–40)'
        WHEN Age BETWEEN 41 AND 50 THEN 'Medium Risk (41–50)'
        ELSE 'High Risk (51+)'
    END;



SELECT * FROM BankCustomer_RiskSegment
ORDER BY churn_rate DESC;

-- *********************************************************************