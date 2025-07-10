/*20) RECURSIVE
When having table self-joins or other types of hierarchies that can be arbitrarily deep, recursive queries are very useful.
A type of CTE that specifies two SELECT statements separated by UNION or UNION ALL.
Essen!ally a loop that keeps repea!ng the second SELECT statement that refers to the previous itera!on's result to generate new results. When the recursive CTE query runs, the first SELECT generates the ini!al result set. The second SELECT then references this result set and creates a new result set that feeds back into the second query. The recursion ends when no more rows are returned from the second SELECT. Because UNION is used, the non-recursive and the recursive select statements have to create the same columns.


Order of execu!on:
1. The non-recursive select statement is executed and creates the base result set R0.
2. While Ri is not empty: the recursive select statement is executed with Ri as an input and the result set Ri+1 is created.
3. The last select statement is executed to create final result, which is a UNION (or UNION ALL) of all previous result set (R0, R1,... Rn).
We will next create a table to look at this in more detail: 
*/
CREATE TABLE employees (
employee_id serial PRIMARY KEY, full_name VARCHAR NOT NULL, manager_id INT)

INSERT INTO employees (employee_id, full_name, manager_id) VALUES
(1, 'Michael North', NULL), (2, 'Megan Berry', 1),
(3, 'Sarah Berry', 1),
(4, 'Zoe Black', 1),
(5, 'Tim James', 1),
(6, 'Bella Tucker', 2),
(7, 'Ryan Metcalfe', 2),
(8, 'Max Mills', 2),
(9, 'Benjamin Glover', 2), (10, 'Carolyn Henderson', 3), (11, 'Nicola Kelly', 3),
(12, 'Alexandra Climo', 3), (13, 'Dominic King', 3),
(14, 'Leonard Gray', 4),
(15, 'Eric Rampling', 4),
(16, 'Piers Paige', 7),
(17, 'Ryan Henderson', 7), (18, 'Frank Tucker', 8),
(19, 'Nathan Ferguson', 8), (20, 'Kevin Rampling', 10);

SELECT * FROM employees;
/*


Look at the data and make sure that you no!ce the rela!onship between manager_id and employee_id. For example: 
1) Who have Michael North as their direct manager?
- Megan Berry, Sarah Berry, Zoe Black, and Tim James 
2) Who has Megan Berry as their direct manager?
- Bella Tucker, Ryan Metcalfe, Max Mills, and Benjamin Glover 
3) Who has a manager that has Megan Berry as a manager?
- Piers Paige (via Ryan Metcalfe), Ryan Henderson (via Ryan Metcalfe), Frank Tucker (via Max Mills), and Nathan Ferguson (via Max Mills)


20a) Exercise
Create a query to find out all the employees that work under Megan Berry, e.g., the people in the answers to ques!ons 1 and 2 above. 
In the result, include both Megan Berry and all the employees that work under her. Do not use recursive yet. 
To accomplish this, write a regular (non-recursive) CTE query to extract all employee_ids of employees that work under Megan Berry (directly and through someone else). 
Because we have three levels, you need three select statement to extract the rows and one select statement to stack them together:
1. This first select statement should extract the row with Megan Berry.
2. The second select statement should extract rows with manager_ids that are equal to the employee_id in the first result set, i.e., it should find rows
that have Megan Berry as the manager.
3. The third select statement should find all the rows with manager_ids that are equal to an employee_id in the second result set, so it should find all
employees that have managers that have Megan Berry as a manager (the explana!on of the corresponding recursive query shows the expect
output from EACH select statement in more detail).
4. The fourth select statement should stack the results from 1, 2, and 3 together.
*/

SELECT *
    FROM employees;


-- A -> B -> C
-- A is C's manager, but not direct manager
WITH meganberry AS (
    SELECT *
    FROM employees
    WHERE full_name = 'Megan Berry'
),
    employeesundermb AS (
    SELECT e.*
    FROM employees AS e
    INNER JOIN meganberry AS m
    ON e.manager_id = m.employee_id
),
    employeesdirectundermb AS (
    SELECT e.*
    FROM employees AS e
    INNER JOIN employeesundermb AS eumb
    ON e.manager_id = eumb.employee_id
)
SELECT *
FROM meganberry
UNION
SELECT *
FROM employeesundermb
UNION
SELECT *
FROM employeesdirectundermb;





/*
20b) Exercise (con!nued)
Next, rewrite the CTE query as a CTE recursive query.

General syntax:
WITH RECURSIVE cte_name AS(
select statement 1 (non-recursive)
UNION [ALL]
select statement 2 (recursive), which includes a reference to cte_name either in FROM or JOIN
SELECT * FROM cte_name; 
*/
WITH RECURSIVE employeesundermb AS (
    SELECT *
    FROM employees
    WHERE full_name = 'Megan Berry'
    UNION
    SELECT e.*
    FROM employees AS e
    INNER JOIN employeesundermb AS eumb
    ON e.manager_id = eumb.employee_id
)
SELECT *
FROM employeesundermb;



/*
In the first itera!on, the query runs the first select statement (the non-recursive term) and returns the base result set:
employee_id full_name manager_id
2 Megan Berry 1
In the second itera!on, the base result is then passed into the second select (the recursive term) and returns the first recursive result set:
employee_id full_name
6 Bella Tucker 2
7 Ryan Metcalfe 2
8 Max Mills 2
9 Benjamin Glover 2
In the third itera!on, the first recursive result (the result set from the second itera!on) is then passed into the second select (the recursive term) and returns the second recursive result set:
employee_id full_name manager_id
16 Piers Paige 7
17 Ryan Henderson 7
18 Frank Tucker 8
19 Nathan Ferguson 8
In the fourth itera!on, the second recursive result is passed into the second select, but this returns no results (no rows in the employees table have manager_ids equal to an employee_id in this result set). Because this returns an empty result set, the recursive query ends.


20c) Exercise (con!nued)
Modify the query bin 20 to keep track of "mid-level managers". 
To accomplish this, create an array using the key word ARRAY[] (name this array Managers) 
and in each itera!on add manager full_name to the Managers array (i.e., full_name || Managers). 
Because the array is ini!ally empty you need to cast it to varchar (it by default otherwise figures out the type based on the elements in the array). 
Also keep track of how many layers of managers each employee has above them (how many itera!ons the recursive query has been repeated) 
by crea!ng a new field and ini!ally setting this to 0 and then adding 1 to this field in each itera!on. Name this field, NumberOfManagers. 
In addi!on to these two fields, show employee_id and full_name and show all employees (start the recursion at the highest manager level). 

	•	First Iteration (Megan Berry):
	•	Managers = ARRAY[] (empty).
	•	e.full_name = 'Megan Berry'.
	•	Result: Managers = ARRAY['Megan Berry'].
	•	Second Iteration (John Smith):
	•	mh.Managers = ARRAY['Megan Berry'].
	•	e.full_name = 'John Smith'.
	•	Result: Managers = ARRAY['Megan Berry', 'John Smith'].
	•	Third Iteration (Alice Johnson):
	•	mh.Managers = ARRAY['Megan Berry', 'John Smith'].
	•	e.full_name = 'Alice Johnson'.
	•	Result: Managers = ARRAY['Megan Berry', 'John Smith', 'Alice Johnson'].

    	1.	First Iteration (Megan Berry):
	•	NumberOfManagers = 0 (since she’s the top-level manager).
	•	Result: NumberOfManagers = 0.
	2.	Second Iteration (John Smith):
	•	mh.NumberOfManagers = 0 (from Megan Berry’s level).
	•	+ 1 (moving one level down).
	•	Result: NumberOfManagers = 1.
	3.	Third Iteration (Alice Johnson):
	•	mh.NumberOfManagers = 1 (from John Smith’s level).
	•	+ 1 (moving another level down).
	•	Result: NumberOfManagers = 2.

*/



WITH RECURSIVE managementhierarchy AS (
    -- Anchor member: Start with the highest-level managers (those who do not have a manager)
    SELECT 
        employee_id, 
        full_name, 
        ARRAY[]::VARCHAR[] AS Managers, 
        0 AS NumberOfManagers
    FROM employees
    WHERE manager_id IS NULL  -- Start with the highest-level managers 
    UNION ALL
    -- Recursive member: Find employees who report to the employees in the previous result set
    SELECT 
        e.employee_id, 
        e.full_name, 
        mh.Managers || mh.full_name,  -- Add the current manager's name to the Managers array
        NumberOfManagers + 1  -- how many layers of managers each employee has above them
    FROM employees AS e
    INNER JOIN ManagementHierarchy AS mh 
    ON e.manager_id = mh.employee_id
)
SELECT *
FROM ManagementHierarchy;


-- Finally run this command to remove the employees table:
DROP TABLE employees;


/*
21a) RECURSIVE - Backorders (overview and CTE)
Some orders have backorders, which in turn can have backorders. etc. There are no business rules that limits how deep this goes. Use a recursive to find all backorders and show their backorder history (e.g., what orders were backordered to create the specific backorder). In the result, only include backorders that is the third !me the order had to be backordered, i.e., only include backorders for orders that have been backordered and then the backorder got backordered, and then this backorder of the backorder got backordered (I am just having fun with this...). In your output
show orderid, orderdate, backorderid, a list showing parent orders (name this field backorderlist), and a field showing how many !mes it has been backordered (name this field depth). Also, in your final result set make sure that you do not show the original orders or backorders that were subsequently backordered.
In the first step, create a regular query that finds order informa!on for backorders, include orderid, orderedate, backorderidof the backordered order and orderid, orderedate, backorderid from the order's backorder. Only include orders that have been backordered twice. See the table overview below for a be#er understanding of the data related to this problem.

Here we can see that order 2, 3, 5, 7, and 8 have been backordered. Interes!ngly, order 2 was backordered, and the backorder (order 5) of order 2 ended up also being backordered (order 7), and the backorder (order 7) of order 5 also ended up being backordered (order 13) - evidently some items were difficult to fulfill).
In the ques!ons above, you are asked to only show backorders that are for orders that have been backordered two or more !mes. You also want include the most current backorder when there is a chain of backorders. In our example, we would as such like to display order 13 and a list consis!ng of 7, 5, and 2 (that indicates that 13 came from 7, that came from 5, that came from 2). We also want a variable that indicates how many !mes the order has already been backordered, e.g., 3 for order 13. Only show this one row; do not show (a) rows 2, 3, 5, 7, and 8 because they were themselves backordered, (b) rows 1, 4, 6, 9, 10, and 11 because they are not backorders, or (c) rows 6 and 12 because they are the first !me the items were backordered.
In this analysis, SalesOrderHeader needs a self-join. However, first iden!fy all orders that have backorders (no self-join yet) but that themselves were not backorders (this is our ini!al set of orders), and output OrderID, OrderDate, and BackOrderID:
*/
SELECT A.Orderid, A.OrderDate, A.backorderid 
FROM salesorderheader AS A
LEFT JOIN salesorderheader AS B
ON A.OrderID = B.backorderid
WHERE B.backorderid IS NULL AND A.backorderid IS NOT NULL;
/*
With only the second part of the where statement, we would get (also showing table B info):
A.OrderID
2 1/10/2021
3 1/12/2021
5 1/14/2021
7 1/15/2021
8 1/15/2021
A.BackOrderID B.OrderID B.BackOrderID 5
6
725
13 5 7
12
A.OrderDate
However, because OrderIDs 5 and 7 are equal to BackOrderID in other rows these two rows are removed by the first part of the WHERE statement and we end up with:
OrderID OrderDate BackOrderID
2 1/10/2021 5
3 1/12/2021 6
8 1/15/2021 12
Now add a CTE that uses the query above and another select statement that uses this result to find the order informa!on (using
the salesorderheader table) associated with the backorder id of the backordered items. In other words, we want to get order informa!on for orders 5, 6, and 12. This should return the following:
OrderID Order Date BackOrderID
2 1/10/2021 5
3 1/12/2021 6
8 1/15/2021 12
5 1/14/2021 7
6 1/14/2021
12 1/17/2021
*/
SELECT orderid, backorderid
FROM salesorderheader;

  

WITH 
  Originals AS(
    SELECT A.Orderid, A.OrderDate, A.backorderid
      FROM salesorderheader AS A
      LEFT JOIN salesorderheader AS B
      ON A.OrderID = B.backorderid
      WHERE B.backorderid IS NULL AND A.backorderid IS NOT NULL),
  BackOrders AS(
    SELECT B.Orderid, B.OrderDate, B.backorderid
      FROM Originals AS A
      JOIN salesorderheader B
      ON A.backorderid = B.orderid)
  SELECT * FROM Originals
  UNION
  SELECT * FROM BackOrders
  ORDER BY Orderid;

/*
21b) RECURSIVE - Backorders (recursion)
To follow the en!re chain we need to add another SELECT statement to find out more informa!on about orderid 7. 
Now rewrite the CTE code above as a recursive query. First do so without the list of orders and without showing the deepest level. 
Next, add the two variables that keep track of prior order ids and recursion depth. 
Finally add a WHERE statement that only keeps the "final" backorders (the bo#om level of a chain) and only shows backorder chains that are two levels or more.
*/
  

WITH RECURSIVE 
  Originals AS(
    SELECT A.Orderid, A.OrderDate, A.backorderid
      FROM salesorderheader AS A
      LEFT JOIN salesorderheader AS B
      ON A.OrderID = B.backorderid
      WHERE B.backorderid IS NULL AND A.backorderid IS NOT NULL
      UNION
    SELECT B.Orderid, B.OrderDate, B.backorderid
      FROM Originals AS A
      JOIN salesorderheader B
      ON A.backorderid = B.orderid)
  SELECT * FROM Originals
  ORDER BY Orderid;

  
-- array
WITH RECURSIVE 
  Originals AS(
    SELECT A.Orderid, A.OrderDate, A.backorderid, 
    ARRAY[A.Orderid]::INTEGER[] AS OrderChain   -- Base case: Start with the original backorders
      FROM salesorderheader AS A
      LEFT JOIN salesorderheader AS B
      ON A.OrderID = B.backorderid
      WHERE B.backorderid IS NULL AND A.backorderid IS NOT NULL
      UNION
    SELECT B.Orderid, B.OrderDate, B.backorderid,
     A.OrderChain || B.Orderid  -- Append the current Orderid to the chain
      FROM Originals AS A
      JOIN salesorderheader B
      ON A.backorderid = B.orderid)
  SELECT * FROM Originals
  ORDER BY Orderid;


-- text string
WITH RECURSIVE 
  Originals AS (
    -- Base case: Start with the original backorders
    SELECT 
      A.Orderid, 
      A.OrderDate, 
      A.backorderid, 
      A.Orderid::TEXT AS OrderChain
    FROM 
      salesorderheader AS A
    LEFT JOIN 
      salesorderheader AS B
    ON 
      A.OrderID = B.backorderid
    WHERE 
      B.backorderid IS NULL 
      AND A.backorderid IS NOT NULL
    UNION
    -- Recursive case: Continue the chain of backorders
    SELECT 
      B.Orderid, 
      B.OrderDate, 
      B.backorderid, 
      A.OrderChain || ' -> ' || B.Orderid::TEXT AS OrderChain  -- Append the current Orderid to the chain with an arrow separator
    FROM 
      Originals AS A
    JOIN 
      salesorderheader B
    ON 
      A.backorderid = B.orderid
  )
  
  SELECT 
    Orderid, 
    OrderDate, 
    backorderid, 
    OrderChain  -- Display the chain of orders as a text string
  FROM 
    Originals
  ORDER BY 
    Orderid;



    
/*
22a) Subquery Expressions Overview - IN and NOT IN
Using IN, EXISTS, JOIN, and ANY (see more details below), find all suppliers with suppliercategory Toy Supplier or Novelty Goods Supplier. 
In the results, include suppliercategoryname, suppliername, and phonenumber.
IN
In earlier exercises, we used the IN operator to replace ORs in WHERE statements, e.g., WHERE state IN('Kansas', 'Utah', 'Colorado'). 
The IN operator can also take a subquery that returns only one column as input. The results of the subquery are used, similarly, to how the list of values were used in the previous IN example.
*/
SELECT s.suppliername, s.phonenumber, sc.suppliercategoryname
FROM suppliercategory AS sc
INNER JOIN suppliercategorymembership AS scm
ON sc.suppliercategoryid = scm.suppliercategoryid
INNER JOIN supplier AS s
ON scm.supplierid = s.supplierid
WHERE sc.suppliercategoryname IN('Toy Supplier', 'Novelty Goods Supplier');

/*
22b) Subquery Expressions Overview - EXISTS
EXISTS is used in WHERE statements to check if a subquery returns any rows. If the subquery returns a row then EXISTS returns true. 
EXISTS is often used in correlated queries. A correlated query is a subquery that depends on the outer query for its values and is executed once for each row evaluated by the outer query.

Now rewrite the EXISTS statement as a join.
Note that differences in performance and readability among IN, EXISTS, and JOIN depend on the context. If performance is important then evaluate performance. Otherwise, JOIN provide more flexibility (e.g., control join type, having access to all variable).
*/

SELECT s.suppliername, s.phonenumber, sc.suppliercategoryname
FROM suppliercategory AS sc
INNER JOIN suppliercategorymembership AS scm
ON sc.suppliercategoryid = scm.suppliercategoryid
INNER JOIN supplier AS s
ON scm.supplierid = s.supplierid
WHERE EXISTS (
    SELECT suppliercategoryname
    FROM suppliercategory AS sc2
    WHERE sc.suppliercategoryid = sc2.suppliercategoryid 
    AND suppliercategoryname IN('Toy Supplier', 'Novelty Goods Supplier') 
);

/*
22c) Subquery Expressions Overview - ANY (SOME) and ALL
ANY is also used in WHERE statements in a similar way to IN, but must use array!
instead of simply checking for equality between values, it can also use other operators, e.g., > and <. 
SOME is a synonym for ANY. Note that IN is equivalent to =ANY (but that ANY can also use other operators).
*/
SELECT s.suppliername, s.phonenumber, sc.suppliercategoryname
FROM suppliercategory AS sc
INNER JOIN suppliercategorymembership AS scm
ON sc.suppliercategoryid = scm.suppliercategoryid
INNER JOIN supplier AS s
ON scm.supplierid = s.supplierid
WHERE sc.suppliercategoryname = ANY(ARRAY['Toy Supplier', 'Novelty Goods Supplier']);
/*
ALL
ALL is used similarly to ANY, but instead of only one comparison having to return TRUE, all comparisons have to return TRUE.
*/
SELECT s.suppliername, s.phonenumber, sc.suppliercategoryname
FROM suppliercategory AS sc
INNER JOIN suppliercategorymembership AS scm
ON sc.suppliercategoryid = scm.suppliercategoryid
INNER JOIN supplier AS s
ON scm.supplierid = s.supplierid
WHERE sc.suppliercategoryname = ALL(ARRAY['Toy Supplier', 'Novelty Goods Supplier']);
/*23
Additional GROUP BY operators: GROUPING SETS, ROLLUP, and CUBE.
These additional GROUP BY options can be useful when grouping by multiple fields. When group by is defined with 
multiple columns then rows with the same values in all the columns in the group by statements are grouped together with
the result set containing one row for each unique combination of values in the group by columns. The result set, however,
does not show the components that makes up these groups. GROUPING SETS, ROLLUP, and CUBE can be used to create result sets
that contain information about these components.*/


SELECT -sum(PaymentAmount), EXTRACT(year FROM paymentdate) AS "Year", EXTRACT(month FROM paymentdate)  AS "Month" 
FROM Payment
GROUP BY "Year","Month"
ORDER BY "Year","Month";

/*GROUPING SETS
Instead of the combination of column values, the result set contains subtotal for each of the field values 
and a grand total of all the matching rows (but no subtotal for the combination of column values).*/

SELECT -sum(PaymentAmount), EXTRACT(year FROM paymentdate) AS "Year", EXTRACT(month FROM paymentdate) AS "Month" 
FROM Payment
GROUP BY GROUPING SETS("Year","Month")
ORDER BY "Year","Month"

/*ROLLUP
Create a hierarchical rollup starting with the first field in the group by, then the second field, etc., i.e, ROLLUP creates
totals for a hierarchy of values where each level of the hierarchy is an aggregation of the values in the level below it.*/

SELECT -sum(PaymentAmount), EXTRACT(year FROM paymentdate) AS "Year", EXTRACT(month FROM paymentdate)  AS "Month" 
FROM Payment
GROUP BY ROLLUP("Year","Month")
ORDER BY "Year","Month"

/*CUBE
Get all the possible combinations.*/
SELECT -sum(PaymentAmount), EXTRACT(year FROM paymentdate) AS "Year", EXTRACT(month FROM paymentdate)  AS "Month" 
FROM Payment
GROUP BY CUBE("Year","Month")
ORDER BY "Year","Month"
/*
24) GROUPING SETS, ROLLUP, and CUBE – Addi!onal Example
Create a query that shows suppliercategoryname, Year, Month, Total Purchases (in millions).
Total Purchases is defined as orderedouters*expectedouterunitprice/1000000 for each suppliercategoryname, Year and Month.
show for each supplier category monthly total purchases. Show the results ordered by categoryname, year, and then month. You can assume that each supplier only belongs to
one suppliercategory (according to the ERD it is possible that each supplier can belong to mul!ple supplier categories).
Then change this query using GROUPING SETS, ROLLUP, and CUBE (create three addi!onal queries) and examine the output. Make sure you understand the output.
*/

-- GROUP BY
SELECT sc.suppliercategoryname, 
    EXTRACT(Year FROM poh.orderdate) AS Year, 
    EXTRACT(Month FROM poh.orderdate) AS Month, 
    round(SUM(pol.orderedouters * pol.expectedouterunitprice / 1000000)::numeric,2) AS "Total Purchases (in millions)"
FROM purchaseorderheader AS poh
INNER JOIN purchaseorderline AS pol
ON poh.purchaseorderid = pol.purchaseorderid
INNER JOIN suppliercategorymembership AS scm
ON scm.supplierid = poh.supplierid
INNER JOIN suppliercategory AS sc
ON sc.suppliercategoryid = scm.suppliercategoryid
GROUP BY GROUPING SETS(suppliercategoryname, Year, Month)
ORDER BY suppliercategoryname, Year, Month;

-- ROLLUP
SELECT sc.suppliercategoryname, 
    EXTRACT(Year FROM poh.orderdate) AS Year, 
    EXTRACT(Month FROM poh.orderdate) AS Month, 
    round(SUM(pol.orderedouters * pol.expectedouterunitprice / 1000000)::numeric,2) AS "Total Purchases (in millions)"
FROM purchaseorderheader AS poh
INNER JOIN purchaseorderline AS pol
ON poh.purchaseorderid = pol.purchaseorderid
INNER JOIN suppliercategorymembership AS scm
ON scm.supplierid = poh.supplierid
INNER JOIN suppliercategory AS sc
ON sc.suppliercategoryid = scm.suppliercategoryid
GROUP BY ROLLUP(suppliercategoryname, Year, Month)
ORDER BY suppliercategoryname, Year, Month;

-- CUBE
SELECT sc.suppliercategoryname, 
    EXTRACT(Year FROM poh.orderdate) AS Year, 
    EXTRACT(Month FROM poh.orderdate) AS Month, 
    round(SUM(pol.orderedouters * pol.expectedouterunitprice / 1000000)::numeric,2) AS "Total Purchases (in millions)"
FROM purchaseorderheader AS poh
INNER JOIN purchaseorderline AS pol
ON poh.purchaseorderid = pol.purchaseorderid
INNER JOIN suppliercategorymembership AS scm
ON scm.supplierid = poh.supplierid
INNER JOIN suppliercategory AS sc
ON sc.suppliercategoryid = scm.suppliercategoryid
GROUP BY CUBE(suppliercategoryname, Year, Month)
ORDER BY suppliercategoryname, Year, Month;


