# 🏦 Bank Customer Churn Analysis
End-to-end data analytics project analyzing factors influencing customer churn in the banking domain using SQL Server and Power BI.

## 📁 Project Overview
The project identifies why customers leave the bank and provides insights to help management improve retention and engagement.

## 🧰 Tools & Technologies
- SQL Server
- Power BI
- Excel
- DAX

## 📊 Dataset
Dataset: BankCustomerChurn (10,000+ records)
Columns include: CustomerId, Geography, Gender, Age, Tenure, Balance, NumOfProducts, CreditScore, IsActiveMember, EstimatedSalary, Exited.

## 🧮 SQL Analysis Highlights
- Data quality validation (nulls, duplicates)
- Churn rate by geography, gender, age, and product usage
- Risk proxy model based on activity, balance, and credit score
- Created views:
  - `HighRiskCustomers`
  - `BankCustomer_RiskSegment`

```sql
CREATE VIEW HighRiskCustomers AS
SELECT 
    CustomerId, Geography, Gender, Age, Balance, NumOfProducts, CreditScore, 
    IsActiveMember, EstimatedSalary,
    CASE 
        WHEN Age > 40 AND Balance > 100000 AND IsActiveMember = 0 THEN 'High Risk'
        WHEN Age BETWEEN 30 AND 50 AND NumOfProducts = 1 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS RiskCategory
FROM BankCustomerChurn;


## 📈 Power BI Dashboard

Visuals include:

KPI Cards: Total Customers, Churn %, Avg. Balance

Age Group vs Risk Category

Geography-wise Churn Map

Gender vs Churn (Donut Chart)

Tenure vs Churn Rate (Line Chart)

Number of Products vs Churn (Bar Chart)

## 📊 Key Insights

Customers aged 51+ and inactive are the most churn-prone.

France region showed highest churn (competitive market).

High-balance but inactive members are high-risk for attrition.
