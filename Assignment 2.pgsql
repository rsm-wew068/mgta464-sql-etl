-- DISTINCT

/*1. Use the salesorderheader table and the DISTINCT keyword to find out how many customers have placed orders. 
In your output show the count and name this field "Number of Customers With Orders". 
Your output should return 1 row and the value should 663.*/

SELECT DISTINCT customerid, COUNT(customerid) AS NumberofCustomersWithOrders
FROM salesorderheader
GROUP BY customerid;


/*2. Modify query 1 to show how many customers are associated with each salesperson. 
Include salespersonpersonid and the count in your output. Your output should return 10 rows.*/

SELECT salespersonpersonid, COUNT(DISTINCT customerid) AS NumberofCustomersWithSalesperson
FROM salesorderheader
GROUP BY salespersonpersonid;


/*3a. Use the salesorderheader table and DISTINCT to only show unique customerid and shippinglocationid combinations. 
In your output show customerid and shippinglocationid. Your output should return 663 rows.*/

SELECT DISTINCT customerid, shippinglocationid
FROM salesorderheader;


/*3b. Create the same result using GROUP BY instead of DISTINCT.*/

SELECT customerid, shippinglocationid
FROM salesorderheader
GROUP BY customerid, shippinglocationid;


/*4. Use the customer, location, and salesorderheader to show all customers shipping addresses. 
Note that the location table contains both shipping and billing addresses. 
The salesorderheader table is needed to determine if an address is a shipping address. 
In your output include customerid from the customer table, customername, streetaddressline1, streetaddressline2, city, state, and zip. Your results should return 663 rows.*/










SELECT DISTINCT c.customerid, c.customername, l.streetaddressline1, l.streetaddressline2, l.city, l.state, l.zip
FROM customer As c
INNER JOIN location AS l
ON c.customerid = l.customerid
INNER JOIN salesorderheader As soh
ON l.locationid = soh.shippinglocationid
ORDER BY c.customerid;

5. How many customers are there in each customer category?
In your results show CustomerCategoryID, CustomerCategoryName, and a new field named NumberOfCustomers. 
Create two separate solu!ons, one that only counts dis!nct customerIDs and one that counts all rows in each group. Compare the results and look at the ERD diagram - are the results the same? 
Based on the ERD diagram, are they guaranteed to be the same - why or why not? Why are they the same?
The results are the same and the ERD diagram indicates that they should be the same. 
Notice that while a single customer can be associated with multiple rows in the CustomerCategoryMemebership table, a single customer can only belong to mul!ple different customer categories and cannot belong to the same customer category mul!ple !mes (because of the composite primary key constraint).

#only counts distinct customerIDs
SELECT DISTINCT ccm.customercategoryid, cc.customercategoryname, COUNT(cc.customercategoryname) As numberofcustomers
FROM customercategorymembership AS ccm
INNER JOIN customercategory AS cc
ON ccm.customercategoryid = cc.customercategoryid
GROUP BY ccm.customercategoryid, cc.customercategoryname;

#counts all rows in each group
SELECT ccm.customercategoryid, cc.customercategoryname, COUNT(cc.customercategoryname) As numberofcustomers
FROM customercategorymembership AS ccm
INNER JOIN customercategory AS cc
ON ccm.customercategoryid = cc.customercategoryid
INNER JOIN (SELECT location, customerid
FROM location
WHERE state IN('Kansas', 'Colorado', 'Utah')) AS l
ON l.customerid = ccm.customerid
GROUP BY ccm.customercategoryid, cc.customercategoryname;


6. How many customers are there in each customer category?
In your results show CustomerCategoryID, CustomerCategoryName, and a new field named NumberOfCustomers. 
Create two separate solu!ons, one that only counts dis!nct customerIDs and one that counts all rows in each group. Compare the results and look at the ERD diagram - are the results the same? 
Based on the ERD diagram, are they guaranteed to be the same - why or why not? Why are they the same?
The results are the same and the ERD diagram indicates that they should be the same. 
Notice that while a single customer can be associated with multiple rows in the CustomerCategoryMemebership table, a single customer can only belong to mul!ple different customer categories and cannot belong to the same customer category mul!ple !mes (because of the composite primary key constraint).
The IN operator can be used instead of mul!ple OR operators in WHERE statements. The general syntax is: SELECT city, state
Exercise :
Modify query 4 to only show customers in Kansas, Colorado, and Utah. Use the IN operator in your WHERE statement.

SELECT DISTINCT c.customerid, c.customername, l.streetaddressline1, l.streetaddressline2, l.city, l.state, l.zip
FROM customer As c
INNER JOIN location AS l
ON c.customerid = l.customerid
INNER JOIN salesorderheader As soh
ON l.locationid = soh.shippinglocationid
WHERE state IN('Kansas', 'Colorado', 'Utah')
ORDER BY c.customerid;

DROP TABLE location;


-- EXTRACT and DATE_TRUNC

/* 7. Using the purchaseorderheader table, show purchaseorderid and three columns showing dates. Two columns using EXTRACT to indicate the orderdate year, name this field "Year", and the orderdate month, name this field "Month". 
One column using DATE_TRUNC to show both the Year and the Month, name field "Year and Month". Only include purchases from 2013 and 2014.
Example:
EXTRACT(MONTH FROM orderdate)
Example:
date_trunc('month', orderdate)*/


SELECT purchaseorderid, 
    EXTRACT(year FROM orderdate) AS Year, 
    EXTRACT(month FROM orderdate) AS Month,
    DATE_TRUNC('month', orderdate) AS "Year and Month"
FROM purchaseorderheader
WHERE orderdate BETWEEN '2013-01-01' AND '2014-12-31';


8. Create a count of purchase orders (name this field NumberOfOrders) for each month in 2013 and 2014 (based on orderdate). 
Use the purchaseorderheader table. In addi!on to NumberOfOrders, include column(s) to show the year and month. 
Create two solu!ons, one that uses EXTRACT (show a total of three columns in this solu!on) and one that uses DATA_TRUNC (show a total of two columns in this solu!on).

#EXTRACT (show a total of three columns in this solu!on)
SELECT COUNT(purchaseorderid) AS NumberOfOrders, 
    EXTRACT(year FROM orderdate) AS Year, 
    EXTRACT(month FROM orderdate) AS Month
FROM purchaseorderheader
WHERE orderdate BETWEEN '2013-01-01' AND '2014-12-31'
GROUP BY Year, Month
ORDER BY Year, Month;


#DATA_TRUNC (show a total of two columns in this solu!on)
SELECT COUNT(purchaseorderid) AS NumberOfOrders, 
    DATE_TRUNC('month', orderdate) AS YearandMonth
FROM purchaseorderheader
WHERE orderdate BETWEEN '2013-01-01' AND '2014-12-31'
GROUP BY YearandMonth
ORDER BY YearandMonth;

9. !!!!!!!!!
Calculate for each supplier how long it takes on average to receive ordered items (only including orders that have actually been received). 
Name this field "Average Fulfillment Time (hours)". 
determine how many orders have been placed and received with each supplier and how many unique items we order (and have received) from each supplier. 
Name these two fields "Number of Orders" and "Number of Unique Items".

CREATE TABLE date_tester ( id_field integer,
orderdate !mestamp, deliverydate !mestamp);
CREATE TABLE date_tester_dates ( id_field integer,
orderdate DATE,
deliverydate date);

SELECT p.supplierid, AVG(EXTRACT(hour FROM r.receivingdate) - EXTRACT(hour FROM p.orderdate)) AS AverageFulfillmentTime, COUNT(p.purchaseorderid) AS NumberofOrders, COUNT(r.receivingreportid) AS NumberofUniqueItems
FROM receivingreportheader AS r
INNER JOIN purchaseorderheader AS p
ON p.purchaseorderid = p.purchaseorderid;


10a. for each year, the "Number of Open Orders" and "Number of open order lines in period", as two new fields. 
Also include a field that indicates the year (name this field "Year"). 
An open order is an order that has not yet been delivered. You can assume that if the order does not have an invoice (there is no invoice id in the order header), then it has not yet been delivered.
-- for each supplier -> order to cash
-- COUNT(1) -> count the number of rows
-- order does not have an invoice -> invoiceid IS NULL
-- order line!!!! -> salesorderline table
-- group by year/month/...

SELECT EXTRACT(year FROM soh.orderdate) AS Year, COUNT(DISTINCT sol.orderid) AS NumberofOpenOrders, COUNT(1) AS Numberofopenorderlinesinperiod
FROM salesorderline As sol
LEFT JOIN salesorderheader AS soh
ON soh.orderid = sol.orderid
WHERE soh.invoiceid IS NULL
GROUP BY Year;

-- Filter
General Syntax:
SUM(quantity) FILTER(WHERE <condition>)
SUM(CASE WHEN <condition> THEN quantity END)

10b. Modify query 10.a to find only the number of orders rather than order lines. Also pivot the results to instead report the results in one row with four columns:
“Number of open orders from 2013”, “Number of open orders from 2014”, “Number of open orders from 2015”, and “Number of open orders from 2016”.
Create two solu!ons, one that uses FILTER and one that uses CASE WHEN.


-- one table
SELECT 
    count(orderid) FILTER (WHERE EXTRACT(YEAR FROM orderdate) = 2013) AS "Number of open orders from 2013",
    count(orderid) FILTER (WHERE EXTRACT(YEAR FROM orderdate) = 2014) AS "Number of open orders from 2014",
    count(orderid) FILTER (WHERE EXTRACT(YEAR FROM orderdate) = 2015) AS "Number of open orders from 2015",
    count(orderid) FILTER (WHERE EXTRACT(YEAR FROM orderdate) = 2016) AS "Number of open orders from 2016"
  FROM salesorderheader
  WHERE invoiceid IS NULL;
SELECT count(orderid) FILTER(WHERE EXTRACT(year from orderdate) = 2020) AS ''
SELECT count(CASE WHEN EXTRACT(year from orderdate) = 2020) THEN orderdate END AS ''

-- case when 
SELECT 
    count(CASE WHEN EXTRACT(YEAR FROM orderdate) = 2013 THEN orderdate END) AS "Number of open orders from 2013",
    count(CASE WHEN EXTRACT(YEAR FROM orderdate) = 2014 THEN orderdate END) AS "Number of open orders from 2014",
    count(CASE WHEN EXTRACT(YEAR FROM orderdate) = 2015 THEN orderdate END) AS "Number of open orders from 2015",
    count(CASE WHEN EXTRACT(YEAR FROM orderdate) = 2016 THEN orderdate END) AS "Number of open orders from 2016"
  FROM salesorderheader
  WHERE invoiceid IS NULL;

11. Now lets create a table with monthly sales where we each row is for a different year (and one column indicate which sum year it is) and the columns indica!ng months. 
Name the month columns "Jan Sales (in millions)", "Feb Sales (in millions)", etc. 
Show sales in millions (divide the sales total by 1M and round to two decimals (note that rounding to specific decimals only works for data type numeric - so you need to cast to numeric). 
Line item totals (sales) is calculated as quan!ty*unitprice*(1+taxrate/100)
--round(sum() filter(where )::numeric, 2)
-- SUM(quantity) FILTER(WHERE <condition>)
-- FILTER (WHERE <condition>)::numeric = int --> num
-- ROUND(SUM(quantity or aggregate) FILTER (WHERE <condition>)::numeric, 2)
-- quantity * sol.unitprice * (1 + sol.taxrate / 100)
SELECT 
    EXTRACT(YEAR FROM soh.orderdate) AS "Year",
    ROUND(SUM((sol.quantity * sol.unitprice * (1 + sol.taxrate / 100)) / 1000000) 
          FILTER (WHERE EXTRACT(MONTH FROM soh.orderdate) = 1)::numeric, 2) AS "Jan Sales (in millions)",
    ROUND(SUM((sol.quantity * sol.unitprice * (1 + sol.taxrate / 100)) / 1000000) 
          FILTER (WHERE EXTRACT(MONTH FROM soh.orderdate) = 2)::numeric, 2) AS "Feb Sales (in millions)",
    ROUND(SUM((sol.quantity * sol.unitprice * (1 + sol.taxrate / 100)) / 1000000) 
          FILTER (WHERE EXTRACT(MONTH FROM soh.orderdate) = 3)::numeric, 2) AS "Mar Sales (in millions)",
    ROUND(SUM((sol.quantity * sol.unitprice * (1 + sol.taxrate / 100)) / 1000000) 
          FILTER (WHERE EXTRACT(MONTH FROM soh.orderdate) = 4)::numeric, 2) AS "Apr Sales (in millions)",
    ROUND(SUM((sol.quantity * sol.unitprice * (1 + sol.taxrate / 100)) / 1000000) 
          FILTER (WHERE EXTRACT(MONTH FROM soh.orderdate) = 5)::numeric, 2) AS "May Sales (in millions)",
    ROUND(SUM((sol.quantity * sol.unitprice * (1 + sol.taxrate / 100)) / 1000000) 
          FILTER (WHERE EXTRACT(MONTH FROM soh.orderdate) = 6)::numeric, 2) AS "Jun Sales (in millions)",
    ROUND(SUM((sol.quantity * sol.unitprice * (1 + sol.taxrate / 100)) / 1000000) 
          FILTER (WHERE EXTRACT(MONTH FROM soh.orderdate) = 7)::numeric, 2) AS "Jul Sales (in millions)",
    ROUND(SUM((sol.quantity * sol.unitprice * (1 + sol.taxrate / 100)) / 1000000) 
          FILTER (WHERE EXTRACT(MONTH FROM soh.orderdate) = 8)::numeric, 2) AS "Aug Sales (in millions)",
    ROUND(SUM((sol.quantity * sol.unitprice * (1 + sol.taxrate / 100)) / 1000000) 
          FILTER (WHERE EXTRACT(MONTH FROM soh.orderdate) = 9)::numeric, 2) AS "Sep Sales (in millions)",
    ROUND(SUM((sol.quantity * sol.unitprice * (1 + sol.taxrate / 100)) / 1000000) 
          FILTER (WHERE EXTRACT(MONTH FROM soh.orderdate) = 10)::numeric, 2) AS "Oct Sales (in millions)",
    ROUND(SUM((sol.quantity * sol.unitprice * (1 + sol.taxrate / 100)) / 1000000) 
          FILTER (WHERE EXTRACT(MONTH FROM soh.orderdate) = 11)::numeric, 2) AS "Nov Sales (in millions)",
    ROUND(SUM((sol.quantity * sol.unitprice * (1 + sol.taxrate / 100)) / 1000000) 
          FILTER (WHERE EXTRACT(MONTH FROM soh.orderdate) = 12)::numeric, 2) AS "Dec Sales (in millions)"
FROM salesorderheader AS soh
INNER JOIN salesorderline AS sol ON soh.orderid = sol.orderid
GROUP BY EXTRACT(YEAR FROM soh.orderdate)
ORDER BY "Year";
-- offset and limit
13. OFFSET is used in the same part of the SELECT statement as LIMIT and is used to specify a certain number of rows to skip before returning the result set, 
e.g., ORDER BY sales_total DESC OFFSET 20 LIMIT 10 can be used to return the 21st through 30th rows with the largest sales_total.
Exercise: use the payment table and show the 6th through the 15th largest customer payments. Note that customer payments are listed as nega!ve numbers (in your results show them as posi!ve numbers). 
In your output include customerid and paymentamount. Your output should contain 10 rows.

-- 6th(offset+1) through the 15th(limit)
SELECT customerid, -paymentamount AS positivepayment
FROM payment
ORDER BY positivepayment DESC 
OFFSET 5 LIMIT 10;

/*14. Use the payment table and show the customers with the 6th through the 15th smallest total payments.
-- In your output include customerid and name the field contains the total of each customer’s payments "total_customer_payment". Your output should contain 10 rows.

SELECT customerid, -SUM(paymentamount) AS total_customer_payment
FROM payment
GROUP BY customerid
ORDER BY total_customer_payment 
OFFSET 5 LIMIT 10;

15. Create a query that shows the difference between each customer’s total orders and total payments. 
Only show customers in 'Kansas', 'Colorado' and 'Utah' and 
only show the customers with the 6th through the 15th largest differences. 
Note that some customers have the parent organiza!on pay for their orders 
(the customerid of the organiza!on paying for the order is given in the default-bill-to-customerid of the salesorderheader table). 
To accurately compare orders to payments, therefore add these organiza!ons orders to their parent organiza!on (and 
only include organiza!ons in your analysis that have both payments and orders). 
Also, if a bill-to-customer has made at least one more order but has not made any payments 
(there are no such customers in the database, but if there were, your code should s!ll work), 
then consider payment amount to be 0 for this customer. Consider building the query in the following steps.
*/
SELECT DISTINCT seq.defaultbilltocustomerid, COUNT(seq.orderid) AS totalordersdifference, SUM(-p.paymentamount) AS totalpaymentsdifference
FROM payment AS p
INNER JOIN location AS l
ON p.customerid = l.customerid
INNER JOIN (SELECT s.orderid, s.customerid, c.defaultbilltocustomerid
FROM customer AS c
INNER JOIN salesorderheader AS s
ON c.customerid = s.customerid) AS seq
ON p.customerid = seq.customerid
WHERE l.state IN('Kansas', 'Colorado', 'Utah') 
GROUP BY seq.defaultbilltocustomerid
ORDER BY totalpaymentsdifference DESC
OFFSET 5 LIMIT 10;

-- Step 1
-- Calculate sum of all orders for each customer that is later billed for the order (i.e., the default-bill-to-customerid as indicated in the customer table).*/
-- Step 2
-- Using the code from step 1 and the code from the previous query that calculated total payments for each customer, calculate the
-- difference between total orders and total payments for each bill-to-customer.
/*Step 3
If a bill-to-customer has made at least one more order but has not made any payments (there are no such customers in the database, 
but if there were, your code should still work), then consider payment amount to be 0 for this customer*/
-- The COALESCE(sp.totalpayment, 0) function in your SQL query is used to handle potential NULL values in the sp.totalpayment field. Let’s break down what this function does and the difference between using COALESCE(sp.totalpayment, 0) and just sp.totalpayment.
/* COALESCE(sp.totalpayment, 0): The COALESCE function returns the first non-NULL value in the list of arguments. In this case, it checks the value of sp.totalpayment.
	•	If sp.totalpayment is not NULL, it returns sp.totalpayment.
	•	If sp.totalpayment is NULL, it returns 0.*/
/* Step 4 state (consider if it is better to place this inside the subquery or at the end of the outer query) and top.*/

-- no matter NULL or not NULL
SELECT sp.customerid, so.totalbill - COALESCE(sp.totalpayment, 0) AS net
FROM
    (SELECT c.defaultbilltocustomerid, SUM(sol.quantity * sol.unitprice * (1 + sol.taxrate / 100)) AS totalbill
    FROM customer AS c
    INNER JOIN salesorderheader AS soh
    ON soh.customerid = c.customerid
    INNER JOIN salesorderline AS sol
    ON sol.orderid = soh.orderid
    INNER JOIN location As l
    ON l.customerid = c.defaultbilltocustomerid
    WHERE l.state IN('Kansas', 'Colorado', 'Utah') 
    GROUP BY c.defaultbilltocustomerid) AS so
LEFT JOIN 
    (SELECT customerid, SUM(-paymentamount) AS totalpayment
    FROM payment
    GROUP BY customerid) AS sp
ON so.defaultbilltocustomerid = sp.customerid
ORDER BY net DESC
OFFSET 5 LIMIT 10;

/* 16. CTE is something in between views and subqueries, where the views are created within the same expression as the primary select statement. 
As with views, the select statements are named and can be reused (but only within the CTE), but they are not stored in the schema as views are. 
It is helpful to think of these select statements as temporary views that are created inside the same common-table-expression.
The general structure of CTE is:
WITH temp_view_1_name AS ( SELECT...
),
temp_view_2_name AS (
SELECT ...
FROM temp_view_1_name...
) SELECT...
-- Does not have to select from the first inner query.
-- Select from one or more inner queries
The code first names a temporary view and then defines this view as a select statement. This can be followed by more temporary views (inner select statements) that can reference previous temporary views. The last part of the CTE is an outer SELECT statement that uses one or more of the inner select statements.
As an exercise, rewrite the SQL code from ques!on 6.
*/
/* 6. How many customers are there in each customer category?
In your results show CustomerCategoryID, CustomerCategoryName, and a new field named NumberOfCustomers. 
Create two separate solu!ons, one that only counts dis!nct customerIDs and one that counts all rows in each group. Compare the results and look at the ERD diagram - are the results the same? 
Based on the ERD diagram, are they guaranteed to be the same - why or why not? Why are they the same?
The results are the same and the ERD diagram indicates that they should be the same. 
Notice that while a single customer can be associated with multiple rows in the CustomerCategoryMemebership table, a single customer can only belong to mul!ple different customer categories and cannot belong to the same customer category mul!ple !mes (because of the composite primary key constraint).
The IN operator can be used instead of mul!ple OR operators in WHERE statements. The general syntax is: SELECT city, state
Exercise :
Modify query 4 to only show customers in Kansas, Colorado, and Utah. Use the IN operator in your WHERE statement.
*/
--COALESCE(B.total_customer_payment, 0)
WITH customerwithorders AS 
    (SELECT DISTINCT customerid, shippinglocationid
    FROM salesorderheader AS soh)
SELECT c.customername, c.customerid, l.streetaddressline1, l.streetaddressline2, l.city, l.state, l.zip
FROM location AS l
INNER JOIN customer AS c
ON c.customerid = l.customerid
INNER JOIN customerwithorders AS cwo
ON cwo.customerid = c.customerid
WHERE l.state IN('Kansas', 'Colorado', 'Utah')
ORDER BY c.customerid; 

/*17 (CTE)
Now let's move onto something a li#le more complex. Let's rewrite query 15.
salesorderheader -> salesorderline -> customer -> location
payment
Customer_Order_Sums -> Customer_Payment_Sums
*/

WITH Customer_Order_Sums AS 
    (SELECT c.defaultbilltocustomerid, SUM(sol.quantity * sol.unitprice * (1 + sol.taxrate / 100)) AS totalbill
    FROM customer AS c
    INNER JOIN salesorderheader AS soh
    ON soh.customerid = c.customerid
    INNER JOIN salesorderline AS sol
    ON sol.orderid = soh.orderid
    INNER JOIN location As l
    ON l.customerid = c.defaultbilltocustomerid
    WHERE l.state IN('Kansas', 'Colorado', 'Utah') 
    GROUP BY c.defaultbilltocustomerid) AS so
LEFT JOIN 
    (SELECT customerid, SUM(-paymentamount) AS totalpayment
    FROM payment
    GROUP BY customerid) AS sp
ON so.defaultbilltocustomerid = sp.customerid
ORDER BY net DESC
OFFSET 5 LIMIT 10;
/*
18 (CTE)
We can also rewrite this so that one of the common table expression reference the other common table expressions. 
In this exercise, change the code below (the CTE from 17) to join the results from the first two expressions in a third temporary view. 
Have the final select statement only order, limit, and offset the data.
*/

/*
19) SET operators
UNION - The UNION operator only keeps dis!nct values 
(across all values in the result set and it does not care from which select statement they came, 
i.e., if there are duplicates in the first, the second, or across both then they will be filtered out) by default.)
UNION ALL - Keeps duplicate values
INTERSECT - Keeps rows that are common to all the queries (removes duplicates)
EXCEPT - The EXCEPT operator lists the rows in the first that are not in the second (removes duplicates)
- Each query must have the same number of columns, column order, and data types.
- The output column names are referred from the first query, which means that each query may have different column names (the stacking is not done based on column names, it is done based on order).
- The ORDER BY clause goes at the end of the en!re SET expression and applies to the en!re set.
Exercise: Modify the query CTE in ques!on 18 and create a list of the top 5 and bo#om 5 customers in terms of difference between orders sums and payment sums.
In the output also include a column that indicates if the row came from the top or the bo#om query (name this field Type).
 */
-- define first, then put it in a new query
-- 3 order tables --> Customer_Order_Sums
-- Customer_Order_Sums + payment table
-- top + bottom
WITH Customer_Order_Sums AS 
    (SELECT c.defaultbilltocustomerid, SUM(sol.quantity * sol.unitprice * (1 + sol.taxrate / 100)) AS totalbill
    FROM customer AS c
    INNER JOIN salesorderheader AS soh
    ON soh.customerid = c.customerid
    INNER JOIN salesorderline AS sol
    ON sol.orderid = soh.orderid
    INNER JOIN location As l
    ON l.customerid = c.defaultbilltocustomerid
    WHERE l.state IN('Kansas', 'Colorado', 'Utah') 
    GROUP BY c.defaultbilltocustomerid),
    Customer_Payment_Sum AS
    (SELECT customerid, SUM(-paymentamount) AS totalpayment
    FROM payment
    GROUP BY customerid),
    Customer_Orders_Minus_Payments AS 
    (SELECT cos.defaultbilltocustomerid, cos.totalbill - COALESCE(cps.totalpayment, 0) AS net
    FROM Customer_Order_Sums AS cos
    LEFT JOIN Customer_Payment_Sum AS cps
    ON cos.defaultbilltocustomerid = cps.customerid),
    TOP AS
    (SELECT *
    FROM Customer_Orders_Minus_Payments
    ORDER BY net DESC
    LIMIT 10),
    BOTTOM AS
    (SELECT *
    FROM Customer_Orders_Minus_Payments
    ORDER BY net ASC
    LIMIT 10)
SELECT * FROM TOP
UNION
SELECT * FROM BOTTOM
ORDER BY net DESC;

