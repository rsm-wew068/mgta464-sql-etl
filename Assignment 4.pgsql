/*25.2) Exercise: Before we start with windowing, we will create a view that will be used as input into our windowing analyses. 
Use the SalesOrderHeader and the SalesOrderLine tables to create a view with three columns, SalespersonID, ReportingYear, 
and SalesInMillions. Name the view AnnualSalesPersonSales. SalespersonID is salespersonpersonid, sales is calculated at the 
line item level as quantity*unitprice*(1+taxrate/100). The results should show SalesInMillions as total sales in millions 
for each sales person each year rounded to three decimals. Sort the results by SalesPersonID and Year. Exclude sales from 2016 
as the data does not contain transactions for the entire year 2016.*/
SELECT  EmployeeID, Salary, State, 
        AVG(salary) OVER(PARTITION BY State), 
        RANK() OVER(PARTITION BY State ORDER BY salary), 
        first_value(salary) OVER(PARTITION BY State ORDER BY salary ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
    FROM...

CREATE VIEW AnnualSalesPersonSales AS
    SELECT soh.salespersonpersonid AS SalespersonID, EXTRACT(year FROM soh.orderdate) AS ReportingYear, 
    ROUND(SUM(sol.quantity * sol.unitprice * (1 + sol.taxrate / 100))::numeric / 1000000, 3) AS SalesInMillions 
    FROM SalesOrderHeader AS soh
    INNER JOIN SalesOrderLine AS sol USING(orderid)
    WHERE soh.orderdate NOT BETWEEN '2016-01-01' AND '2016-12-31'  -- WHERE EXTRACT(year FROM A.OrderDate) <> 2016
    GROUP BY SalespersonID, ReportingYear
    ORDER BY SalespersonID, ReportingYear;
SELECT* FROM AnnualSalesPersonSales;
DROP VIEW AnnualSalesPersonSales;

/*25.3) As mentioned earlier, to use the window function in a query, an aggregate function or built-in window 
function is added to the list of result columns in the first part of the select statement. This is then followed
followed by the OVER clause:
•  a regular aggregate function (can also have a FILTER clause), for example: 
*/
SELECT field_y, field_x,  SUM(field_z) OVER()
	FROM…
•	a built-in window function (more about these later), for example: 
SELECT field_y, field_x,  rank() OVER(), last_value(field_z) OVER()
	FROM…

/*
Aggregate Function
Exercise: Use an aggregate function together with the over clause to add a column to the previous results 
that shows average annual salesperson sales (calculate the average across all salesperson and year). In 
the results above, 10 employees have sales in three years and the average sales across all years and all 
employees is 5.912 million.  This average should be included in a new field named AverageSales in the result 
set and repeated for each row. Also include a field that calculates the percentage difference between each 
employee’s sales each month and AverageSales. Name this field PercentDiff.*/
SELECT field_y, field_x,  SUM(field_z) OVER()
	FROM…
•	a built-in window function (more about these later), for example: 
SELECT field_y, field_x,  rank() OVER(), last_value(field_z) OVER()
	FROM…


SELECT *,
    AVG(SalesInMillions) OVER() AS AverageSales,
    (SalesInMillions - AVG(SalesInMillions) OVER()) / AVG(SalesInMillions) OVER() AS PercentDiff
    FROM AnnualSalesPersonSales
    ORDER BY SalespersonID, ReportingYear;

/*25.4) Built-in Window Functions
Postgres (and other databases) contains a number of built-in window functions, see table below. These function 
are not only useful when working with typical window problems (e.g., aggregate functions need to be applied at 
a different grouping levels then the level at which the data is displayed, rolling type analyses (including rolling 
averages), but you will also often see solutions to problems using the over clause simply to get access to these 
functions. In other words, they are very useful!  For example, row numbers, finding the value of the previous row, 
finding the value of the first or last value in a group, etc. are all common tasks but difficult to do without 
using windowing.

Exercise: Create a query that returns all the columns from AnnualSalesPersonSales and adds two new fields, Prior Sales 
and Sales Diff. Prior Sales should contain the SalesInMillions value from the row above and Sales Diff should show the 
difference between the SalesInMillions values in the current row and the previous row.*/
-- lag(field [,offset integer [, default]])      same type as field  returns value from field evaluated at the row that is offset rows before the current row

SELECT *, lag(SalesInMillions) OVER() AS "Prior Sales", 
SalesInMillions - lag(SalesInMillions) OVER() AS "Sales Diff"
FROM AnnualSalesPersonSales;

/*
25.5) WINDOW
Instead of applying the aggregate or built-in function across all rows in a partition, the function can be applied to specific 
window, i.e., specific rows in the partition as identified by a window frame. While the window definition applies to all rows for the
specific column, each row's window can (and typically does) consist of different rows (e.g., all rows in the partition prior to the
current row).  To define the window the following is added inside the OVER clause (add either or both):
•	PARTITION BY, e.g., OVER(PARTITION BY field_1)
•	Frame Specifications, e.g., OVER(RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)

PARTITION BY 
Similarly to GROUP BY, PARTITION BY, is used to define partitions based on unique combiations of values in the fields specified in 
the PARTITION BY statement. When using partition by, the window function is applied to each partition (group) separately.  When partition 
by is not added in the over clause, then all rows is considered to belong to the same partition.

Exercise: Use the AnnualSalesPersonSales view and add a field that shows average annual sales. For example, the average sales 
in 2013 for the 10 employees is 5.397 million (the value 5.397 will be repeated 10 times since the average is the same for all 
employees in 2013). Name this field Average Annual Sales. In your results also include the lag and row difference results from 
the previous query, but partition this by SalesPersonID. Order the results by SalesPersonID and year.
*/
-- partition by = divide by = depend on
SELECT *, AVG(SalesInMillions) OVER(PARTITION BY reportingyear) AS "Average Annual Sale",
    lag(SalesInMillions) OVER(PARTITION BY salespersonid) AS "Prior Sales", 
    SalesInMillions - lag(SalesInMillions) OVER(PARTITION BY salespersonid) AS "Sales Diff" 
FROM AnnualSalesPersonSales
ORDER BY SalesPersonID, reportingyear;



/*Note that Average Annual Sales is the same for each year across all employees. However, the lagged sales in the result set does 
not make sense. We would expect the first row for each salesperson to be null and year 2014 rows to pull from year 2013 (and 2015 
from 2014). 

25.6) ORDER BY
The odd results is because the order of the rows in each partition is arbitrary, even when the result set itself is sorted.  
This is not a problem only for lag, all the built-in functions depend on the order of that data.  It is therefore important to 
include an ORDER BY clause in the window definition itself when working with built-in functions. When including an ORDER BY clause 
in the window definition, the rows in each window are sorted based on the ORDER BY before the aggregate function or built-in window 
function is applied.  This sorting does not necessarily effect how the rows are presented in the query.

Exercise:
Change the previous query by adding an ORDER BY clause inside each OVER clause.  
- For the average field, sort each reporting year partition by SalesPersonID (since we are taking an average, the sorting of the rows within a given partition should not matter – 
but it does because something else also changes when we sort… we will look at this after we see the results). 
- For the lag and difference fields, order each SalesPersonID partition by ReportingYear.
*/
-- each column and all columns have different sorts
SELECT *, AVG(SalesInMillions) OVER(PARTITION BY salespersonid ORDER BY reportingyear) AS "Average Annual Sale",
    lag(SalesInMillions) OVER(PARTITION BY reportingyear ORDER BY salespersonid) AS "Prior Sales", 
    SalesInMillions - lag(SalesInMillions) OVER(PARTITION BY reportingyear ORDER BY salespersonid) AS "Sales Diff" 
FROM AnnualSalesPersonSales
ORDER BY SalesPersonID, reportingyear;


/*25.9) Named Window Definitions
Finally, when using windowing functions, the same window (as defined by PARTITION BY, ORDER BY, and frame clause) is often used for multiple fields in a single SELECT statement. 
To increase readability and reduce the risk of errors, the definition of the window (i.e., what goes inside the over clause), can be named and defined in a separate WINDOW clause.
 The WINDOW clause, if used, is placed after any HAVING clause and before any ORDER BY and referenced by name in the OVER statement. 

*/
-- DON"T
SELECT 	field_y, 
	field_x, 
	function_1_name OVER (PARTITION BY... ORDER BY... frame_clause),
	function_2_name OVER (same window definition as above)
FROM
…
HAVING field… 
ORDER BY field…

-- USE
SELECT 	field_y, 
	field_x, 
	function_1_name OVER WindowName,
	function_2_name OVER WindowName
FROM
…
HAVING filed…
WINDOW WindowName AS (PARTITION BY... ORDER BY... frame_clause)
ORDER BY field…
/*
25.10) Exercise: Create a query that shows information about monthly customer payments for different customer categories. exclude 2016.
In your output show CustomerCategoryName (from the CustomerCategory table), TruncatedMonth based on PaymentDate (from the Payment table), and the fields below based on PaymentAmount (from the Payment Table). 
Use name windows when two or more fields have (or can have) them same window definition:
•	Cumulative total for each year and customer category "Running Total - Annual”
•	Percentage difference between current month and the first month in the year for each customer category "Percent change from beginning of year" (the first month does not necessarily have to be January if this data is missing)
•	Cumulative total for each quarter and customer category, name this field "Running Total - Quarterly")
•	3-month total for each customer category. If one (two) month is missing, then the total payments should be calculate based on two (one) months. Name this field "3-Month Total Payments"
•	3-month average payments for each customer category name. If one (two) month is missing then the average should be calculated based on two months (one month). Name this field "Average Monthly Payments (3-Month Moving Average)". 
•	Percentage difference between previous month payment and current month payment (if a month is missing then take the value from 2 months ago, if that is also missing then return null) for each customer category. Name this field, "Percentage Change".*/

SELECT 	field_y, 
	field_x, 
	function_1_name OVER WindowName,
	function_2_name OVER WindowName
FROM
…
HAVING filed…
WINDOW WindowName AS (PARTITION BY... ORDER BY... frame_clause)
ORDER BY field…

WITH monthlypayment AS (
    SELECT 
        CustomerCategoryName, 
        DATE_TRUNC('Month', paymentdate) AS monthly, 
        SUM(-paymentamount) AS monthlytotal
    FROM payment AS p
    INNER JOIN customercategorymembership USING(customerid)
    INNER JOIN CustomerCategory USING(customercategoryid)
    WHERE EXTRACT(year FROM paymentdate) <> 2016
    GROUP BY CustomerCategoryName, monthly
)
SELECT 
    *, 
    SUM(monthlytotal) OVER customercategorytruncy AS "Running Total - Annual",
    (monthlytotal - first_value(monthlytotal) OVER customercategorytruncy) / first_value(monthlytotal) OVER customercategorytruncy AS "Percent change from beginning of year",
    SUM(monthlytotal) OVER customercategorytruncq AS "Running Total - Quarterly",
    SUM(monthlytotal) OVER customercategoryminus2 AS "3-Month Total Payments",
    AVG(monthlytotal) OVER customercategoryminus2 AS "Average Monthly Payments (3-Month Moving Average)"
FROM monthlypayment
WINDOW 
    customercategorytruncy AS (
        PARTITION BY CustomerCategoryName, DATE_TRUNC('year', monthly) 
        ORDER BY monthly 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ),
    customercategorytruncq AS (
        PARTITION BY CustomerCategoryName, DATE_TRUNC('quarter', monthly) 
        ORDER BY monthly 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ),
    customercategoryminus2 AS (
        PARTITION BY CustomerCategoryName
        ORDER BY monthly 
        RANGE BETWEEN INTERVAL '2 months' PRECEDING AND CURRENT ROW
    );

/*
Before we start, run the SQL code in the Assignment3_Problem2_CreateTables.psql file (see course website). 
This code will create an employee table and a table with standard street suffixes.

26.1) Remove Address with PO Boxes
Filter out all rows in the location table with streetaddressline1 that start with the string 'PO Box'.  
We are assuming that we are not interested in addresses with PO Boxes. Use the function LEFT(string, n) 
and the pattern matching keyword LIKE. Left returns the first n characters from string.  Note that since 
we are not using a wildcard (i.e., _ or %), we do not need to use LIKE, we could just use =. However, 
since we are working with text it seemed appropriate. In your output return streetaddressline2.
*/

SELECT*FROM StreetDirection;
SELECT*FROM StreetPrefixMapping;
SELECT*FROM StreetSuffixMapping;
SELECT*FROM employee_table;
SELECT*FROM location;
SELECT streetaddressline2
FROM location
WHERE LEFT(streetaddressline1, 6) NOT LIKE 'PO Box';

/*26.2) StreetNumberExtraction
We are next going to extract the street number. In your solution, use a WITH statement and use 
the previous query that removed PO Box addresses as the first temporary view and name it NotPoBox. 
Then use NotPoBox as input into a query that will extract street numbers. Name the field with the 
extracted data StreetNumber and the temporary view StreetNumberExtraction. You can assume that 
the street number is the first component in streetaddressline2 (after the removal of PO BOX addresses) 
before the first space and that this is a number. In addition to extracting street numbers, also 
include the original streetaddressline2 and a field containing all text to the right of the street 
number (use  SUBSTRING and POSITION for this). Name this new field RightOfStreetNumber.

To extract this part of the string use SUBSTRING and POSITION (LEFT would be more natural, but we 
have already been introduce to left. There are also other options, e.g., SPLIT_PART, that can be 
used for this but that I will not cover.):
> SUBSTRING (string, start_position, length)
Returns a substring of string starting at start_position and having length number of characters.

> POSITION(sub_string IN string)
Returns an integer representing the location of sub_string in string. We could also use 
STRPOS(sub_string, string), but it is the same thing as POSITION and while I like the format better 
it is a postgresql extension and might not work with other databases.*/

WITH notpobox AS (
    SELECT streetaddressline2
    FROM location
    WHERE LEFT(streetaddressline1, 6) NOT LIKE 'PO Box'
),
    StreetNumberExtraction AS (
    SELECT streetaddressline2, SUBSTRING(streetaddressline2, 1, POSITION(' ' IN streetaddressline2)-1) AS StreetNumber, 
    SUBSTRING(streetaddressline2, POSITION(' ' IN streetaddressline2)+1) AS RightOfStreetNumber
    FROM notpobox
    
    )
SELECT *
FROM StreetNumberExtraction;

-- Locating street number using LEFT:
SELECT streetaddressline1, streetaddressline2, LEFT(streetaddressline2, POSITION(' ' in streetaddressline2)) AS StreetNumber
    FROM location;

/*26.3) Validate Street Number
The extracted number should be the street number, but we want to validate that what we extract are numbers. 
Create a new temporary view named StreetNumberCheck to the Common Table Expression. In this query, include a 
field named StreetNumber (it will 'replace' the StreetNumber field that is used as input into this query) 
that is populated with the street number if the street number only contains numbers, otherwise null. */


WITH notpobox AS (
    SELECT streetaddressline2
    FROM location
    WHERE LEFT(streetaddressline1, 6) NOT LIKE 'PO Box'
),
    StreetNumberExtraction AS (
    SELECT streetaddressline2, SUBSTRING(streetaddressline2, 1, POSITION(' ' IN streetaddressline2)-1) AS StreetNumber, 
    SUBSTRING(streetaddressline2, POSITION(' ' IN streetaddressline2)+1) AS RightOfStreetNumber
    FROM notpobox
),
    StreetNumberCheck AS (
    SELECT *,
    CASE WHEN streetnumber SIMILAR TO '[0-9]+'
    THEN streetnumber
    ELSE NULL
    END AS streetnumber
    FROM StreetNumberExtraction)
SELECT *
FROM StreetNumberCheck;

/*
26.4) Extract Street Suffix
Next, we are going to extract the street suffix (e.g., street, road, etc.). We are going to assume it 
is one word and it is the last word in the string. Add another temporary view named StreetSuffixExtraction 
to the Common Table Expression that extracts the last word in the RightOfStreetNumber field. There is no 
function in postgres to search for substrings from the right (regex could be used to locate the last 
occurrence of a space or the text to the right of the last occurrence of a space, but I still want to wait 
a little longer before we look at regex).  However, postgres has a function called REVERSE that reverses 
the order of the characters in a string. Use this function along with RIGHT(string, n) and POSITION to 
extract all characters to the right of the last space. Name this new field StreetSuffix.

Westridge Blue Rd
dR eulB .....
*/

WITH notpobox AS (
    SELECT streetaddressline2
    FROM location
    WHERE LEFT(streetaddressline1, 6) NOT LIKE 'PO Box'
),
    StreetNumberExtraction AS (
    SELECT streetaddressline2, SUBSTRING(streetaddressline2, 1, POSITION(' ' IN streetaddressline2)-1) AS StreetNumber, 
    SUBSTRING(streetaddressline2, POSITION(' ' IN streetaddressline2)+1) AS RightOfStreetNumber
    FROM notpobox
),
    StreetNumberCheck AS (
    SELECT *,
    CASE WHEN streetnumber SIMILAR TO '[0-9]+'
    THEN streetnumber
    ELSE NULL
    END AS streetnumber
    FROM StreetNumberExtraction),
    StreetSuffixExtraction AS (
    SELECT *,
    RIGHT(RightOfStreetNumber, POSITION(' ' IN REVERSE(RightOfStreetNumber))-1) AS StreetSuffix
    FROM StreetNumberCheck 
    )
SELECT *
FROM StreetSuffixExtraction;

/*
26.5) Validate Street Suffix 
Now validate the extracted street suffix. We will first run SQL code to 
create a table, StreetSuffixMapping. This table contains valid street suffixes and standard codes for the same 
(or very similar) suffixes that are just spelled differently, e.g., st vs street. The various potential 
spellings are located in a field called Written and the Standard suffixes are in a field called Standard. 
For example:
Written		Standard
St		      ST
Street		  ST

Add another temporary view named StreetSuffixCheck to the CTE that validates that the field StreetSuffix 
has a matching value in the Written column in StreetSuffixMapping. If the extracted suffix is located in 
the written column then it is considered to be a valid suffix. For valid StreetSuffix values, include the 
corresponding standard value (i.e., the  value from Standard in StreetSuffixMapping) in a new field named Standard.
If there is not match then populate this field with a null value (left join) for that row. The standard values will help improve matching 
addresses later. In this SELECT statement also include a new field named StreetName that contains all 
the text between the street number and the street suffix.
*/

WITH notpobox AS (
    SELECT streetaddressline2
    FROM location
    WHERE LEFT(streetaddressline1, 6) NOT LIKE 'PO Box'
),
    StreetNumberExtraction AS (
    SELECT streetaddressline2, SUBSTRING(streetaddressline2, 1, POSITION(' ' IN streetaddressline2)-1) AS StreetNumber, 
    SUBSTRING(streetaddressline2, POSITION(' ' IN streetaddressline2)+1) AS RightOfStreetNumber
    FROM notpobox
),
    StreetNumberCheck AS (
    SELECT *,
    CASE WHEN streetnumber SIMILAR TO '[0-9]+'
    THEN streetnumber
    ELSE NULL
    END AS streetnumber
    FROM StreetNumberExtraction
),
    StreetSuffixExtraction AS (
    SELECT *,
    RIGHT(RightOfStreetNumber, POSITION(' ' IN REVERSE(RightOfStreetNumber))-1) AS StreetSuffix
    FROM StreetNumberCheck 
),
    StreetSuffixCheck AS (
    SELECT *, standard,
    LEFT(RightOfStreetNumber, LENGTH(RightOfStreetNumber) - LENGTH(StreetSuffix) -1) AS streetname
    FROM StreetSuffixExtraction AS sne
    LEFT JOIN StreetSuffixMapping AS ssm
    ON UPPER(sne.StreetSuffix) = ssm.Written
)
SELECT *
FROM StreetSuffixCheck;

/*
27.1) Regular Match on Street Names
We are now going to use the extracted address information (from what we are pretending to be supplier 
addresses) and compare it to the employee table (this table already contains extracted and validated 
data) to see if we have any employees that the company may also be purchasing from.  Below the temporary 
views in the CTE, add a SELECT statement that compares the streetname from StreetSuffixCheck to the 
streetname in the Employee_Table using a regular equality operator. Only keep rows where there is a 
match. In your results create a new field called MatchType and populate it with a string saying 
'StreetNameMatch'. Also include streetaddressline2 and streetname from StreetSuffixCheck and streetnumber, 
streetname, and streetsuffix from Employee_Table.
*/


WITH notpobox AS (
    SELECT streetaddressline2
    FROM location
    WHERE LEFT(streetaddressline1, 6) NOT LIKE 'PO Box'
),
    StreetNumberExtraction AS (
    SELECT streetaddressline2, SUBSTRING(streetaddressline2, 1, POSITION(' ' IN streetaddressline2)-1) AS StreetNumber, 
    SUBSTRING(streetaddressline2, POSITION(' ' IN streetaddressline2)+1) AS RightOfStreetNumber
    FROM notpobox
),
    StreetNumberCheck AS (
    SELECT *,
    CASE WHEN streetnumber SIMILAR TO '[0-9]+'
    THEN streetnumber
    ELSE NULL
    END AS streetnumber
    FROM StreetNumberExtraction
),
    StreetSuffixExtraction AS (
    SELECT *,
    RIGHT(RightOfStreetNumber, POSITION(' ' IN REVERSE(RightOfStreetNumber))-1) AS StreetSuffix
    FROM StreetNumberCheck 
),
    StreetSuffixCheck AS (
    SELECT *, standard,
    LEFT(RightOfStreetNumber, LENGTH(RightOfStreetNumber) - LENGTH(StreetSuffix) -1) AS streetname
    FROM StreetSuffixExtraction AS sne
    LEFT JOIN StreetSuffixMapping AS ssm
    ON UPPER(sne.StreetSuffix) = ssm.Written
)
SELECT 'StreetNameMatch' AS MatchType, ssc.streetaddressline2, ssc.streetname, e.streetnumber, 
e.streetname, e.streetsuffix
FROM StreetSuffixCheck AS ssc
INNER JOIN employee_table AS e
ON ssc.streetname = e.streetname;

/*
27.2) Regular Match on Street Numbers, Names, and Suffixes
Stack the results from the query above together with a new query (use UNION) that matches on all address 
components (again using a regular equality operator), i.e., streetname, streetnumber, and standard from 
StreetSuffixCheck and streetname, streetnumber, and streetsuffix from Employee_Table. Include the same 
field sas in 3.1 (for MatchType, use the string 'FullStreetAddressMatch'.
*/

WITH notpobox AS (
    SELECT streetaddressline2
    FROM location
    WHERE LEFT(streetaddressline1, 6) NOT LIKE 'PO Box'
),
    StreetNumberExtraction AS (
    SELECT streetaddressline2, SUBSTRING(streetaddressline2, 1, POSITION(' ' IN streetaddressline2)-1) AS StreetNumber, 
    SUBSTRING(streetaddressline2, POSITION(' ' IN streetaddressline2)+1) AS RightOfStreetNumber
    FROM notpobox
),
    StreetNumberCheck AS (
    SELECT *,
    CASE WHEN streetnumber SIMILAR TO '[0-9]+'
    THEN streetnumber
    ELSE NULL
    END AS streetnumber
    FROM StreetNumberExtraction
),
    StreetSuffixExtraction AS (
    SELECT *,
    RIGHT(RightOfStreetNumber, POSITION(' ' IN REVERSE(RightOfStreetNumber))-1) AS StreetSuffix
    FROM StreetNumberCheck 
),
    StreetSuffixCheck AS (
    SELECT *, standard,
    LEFT(RightOfStreetNumber, LENGTH(RightOfStreetNumber) - LENGTH(StreetSuffix) -1) AS streetname
    FROM StreetSuffixExtraction AS sne
    LEFT JOIN StreetSuffixMapping AS ssm
    ON UPPER(sne.StreetSuffix) = ssm.Written
)
SELECT 'StreetNameMatch' AS MatchType, ssc.streetaddressline2, ssc.streetname, e.streetnumber, 
e.streetname, e.streetsuffix
FROM StreetSuffixCheck AS ssc
INNER JOIN employee_table AS e
ON ssc.streetname = e.streetname
UNION
SELECT 'FullStreetAddressMatch' AS MatchType, ssc.streetaddressline2, ssc.streetname, e.streetnumber, 
e.streetname, e.streetsuffix
FROM StreetSuffixCheck AS ssc
INNER JOIN employee_table AS e
ON ssc.streetname = e.streetname;

/*
Then run the following query that displays the name from each row as well as the string Johan converted 
using soundex and dmetaphone. I also use a function that returns a SoundExDifference score and 
LEVENSHTEIN(). Both these functions take two strings as input and compared them. Finally, running 
LEVENSHTEIN and calculating scores for dissimilar variables is time consuming and typically unnessary. 
By using a function called levenshtein_less_equal, a max score is passed into the function that is then 
used to stop comparisons when the distance score is above the max score. So for example, if I know that 
I will only consider distance scores below 8 to be similar then it is not helpful to know the exact 
distance score when the distance score is higher than 8 (but it can be very costly to calculate these 
scores).
*/

SELECT 
    *, 
    soundex(nm) AS SoundEx_Field, 
    soundex('Johan') AS SoundEx_Johan, 
    dmetaphone(nm) AS DoubleMetaphone_Field,
    dmetaphone('Johan') AS DoubleMetaphone_Johan,
    dmetaphone_alt(nm) AS DoubleMetaphoneAlt_Field,
    dmetaphone_alt('Johan') AS DoubleMetaphoneAlt_Johan,
    difference(s.nm, 'Johan') AS SoundExDifference, 
    LEVENSHTEIN(s.nm, 'Johan') AS Levenshtein,
    levenshtein_less_equal(nm, 'Johan', 2)
    FROM s;
-- Examples of using fuzzy matching in WHERE statement
SELECT * 
    FROM s 
    WHERE dmetaphone(nm) =  dmetaphone('Johan');
/*
27.4) SoundEX Difference Matching
Create another SELECT statement (and combine with the other select statements using UNION). In this 
query, use the soundex DIFFERENCE() function to find similar streetnames (use a difference score above 
3 as the cutoff). Also make sure that the streetnumbers match. Include the same fields as in 3.3 (for 
MatchType, use the string 'StreetNameAndNumberMatchSoundexDifference'.
*/

WITH 
    NotPoBox AS(
    SELECT streetaddressline2
    FROM location
    WHERE LEFT(streetaddressline1, 6) NOT LIKE 'PO Box'
),
    StreetNumberExtraction AS (
    SELECT streetaddressline2, 
           SUBSTRING(streetaddressline2, 1, POSITION(' ' IN streetaddressline2)-1) AS StreetNumber, 
           SUBSTRING(streetaddressline2, POSITION(' ' IN streetaddressline2)+1) AS RightOfStreetNumber
    FROM NotPoBox
),
    StreetNumberCheck AS (
    SELECT *,
           CASE WHEN streetnumber SIMILAR TO '[0-9]+' 
                THEN streetnumber 
                ELSE NULL 
           END AS CheckedStreetNumber  -- Changed alias to avoid ambiguity
    FROM StreetNumberExtraction
),
    StreetSuffixExtraction AS (
    SELECT *,
           RIGHT(RightOfStreetNumber, POSITION(' ' IN REVERSE(RightOfStreetNumber))-1) AS StreetSuffix
    FROM StreetNumberCheck 
),
    StreetSuffixCheck AS (
    SELECT sse.*,
           Standard,
           LEFT(RightOfStreetNumber, LENGTH(RightOfStreetNumber) - LENGTH(StreetSuffix) -1) AS StreetName
    FROM StreetSuffixExtraction AS sse
    LEFT JOIN StreetSuffixMapping AS ssm
           ON UPPER(sse.StreetSuffix) = ssm.Written
)
SELECT 'StreetNameMatch' AS MatchType, 
       ssc.streetaddressline2, 
       ssc.streetname, 
       e.streetnumber, 
       e.streetname, 
       e.streetsuffix
FROM StreetSuffixCheck AS ssc
INNER JOIN employee_table AS e
ON ssc.streetname = e.streetname
UNION
SELECT 'FullStreetAddressMatch' AS MatchType, 
       ssc.streetaddressline2, 
       ssc.streetname, 
       e.streetnumber, 
       e.streetname, 
       e.streetsuffix
FROM StreetSuffixCheck AS ssc
INNER JOIN employee_table AS e
ON ssc.streetname = e.streetname
AND ssc.CheckedStreetNumber::int = e.streetnumber  -- Use the new alias here
AND ssc.standard = e.streetsuffix
UNION
SELECT 'StreetNameAndNumberMatchSoundexDifference' AS MatchType, 
       ssc.streetaddressline2, 
       ssc.streetname, 
       e.streetnumber, 
       e.streetname, 
       e.streetsuffix 
FROM StreetSuffixCheck AS ssc
INNER JOIN employee_table AS e
ON ssc.CheckedStreetNumber::int = e.streetnumber  -- Use the new alias here
WHERE difference(ssc.streetname, e.streetname) > 3;
/*
27.5) Levenshtein Distance Matching
Create another SELECT statement (and combine with the other select statements using UNION). Use the 
levenshtein_less_equal function to find similar streetnames (use a distance score of less than 2). 
Include the same fields as in 3.4 (for MatchType, use the string 'LevenshteinMatch'.
*/



WITH 
    NotPoBox AS(
    SELECT streetaddressline2
    FROM location
    WHERE LEFT(streetaddressline1, 6) NOT LIKE 'PO Box'
),
    StreetNumberExtraction AS (
    SELECT streetaddressline2, 
           SUBSTRING(streetaddressline2, 1, POSITION(' ' IN streetaddressline2)-1) AS StreetNumber, 
           SUBSTRING(streetaddressline2, POSITION(' ' IN streetaddressline2)+1) AS RightOfStreetNumber
    FROM NotPoBox
),
    StreetNumberCheck AS (
    SELECT *,
           CASE WHEN streetnumber SIMILAR TO '[0-9]+' 
                THEN streetnumber 
                ELSE NULL 
           END AS CheckedStreetNumber  -- Changed alias to avoid ambiguity
    FROM StreetNumberExtraction
),
    StreetSuffixExtraction AS (
    SELECT *,
           RIGHT(RightOfStreetNumber, POSITION(' ' IN REVERSE(RightOfStreetNumber))-1) AS StreetSuffix
    FROM StreetNumberCheck 
),
    StreetSuffixCheck AS (
    SELECT sse.*,
           Standard,
           LEFT(RightOfStreetNumber, LENGTH(RightOfStreetNumber) - LENGTH(StreetSuffix) -1) AS StreetName
    FROM StreetSuffixExtraction AS sse
    LEFT JOIN StreetSuffixMapping AS ssm
           ON UPPER(sse.StreetSuffix) = ssm.Written
)
SELECT 'StreetNameMatch' AS MatchType, 
       ssc.streetaddressline2, 
       ssc.streetname, 
       e.streetnumber, 
       e.streetname, 
       e.streetsuffix
FROM StreetSuffixCheck AS ssc
INNER JOIN employee_table AS e
ON ssc.streetname = e.streetname
UNION
SELECT 'FullStreetAddressMatch' AS MatchType, 
       ssc.streetaddressline2, 
       ssc.streetname, 
       e.streetnumber, 
       e.streetname, 
       e.streetsuffix
FROM StreetSuffixCheck AS ssc
INNER JOIN employee_table AS e
ON ssc.streetname = e.streetname
AND ssc.CheckedStreetNumber::int = e.streetnumber  -- Use the new alias here
AND ssc.standard = e.streetsuffix
UNION
SELECT 'StreetNameAndNumberMatchSoundexDifference' AS MatchType, 
       ssc.streetaddressline2, 
       ssc.streetname, 
       e.streetnumber, 
       e.streetname, 
       e.streetsuffix 
FROM StreetSuffixCheck AS ssc
INNER JOIN employee_table AS e
ON ssc.CheckedStreetNumber::int = e.streetnumber  -- Use the new alias here
WHERE difference(ssc.streetname, e.streetname) > 3
UNION
SELECT 'LevenshteinMatch' AS MatchType, 
       ssc.streetaddressline2, 
       ssc.streetname, 
       e.streetnumber, 
       e.streetname, 
       e.streetsuffix 
FROM StreetSuffixCheck AS ssc, employee_table AS e -- Use the new alias here
WHERE levenshtein_less_equal(ssc.streetname, e.streetname, 1) < 2;



/*
27.6) Double Metaphone Matching
Create another SELECT statement (and combine with the other select statements using UNION). Use the 
dmetaphone function to find similar streetnames. Also make sure that the streetnumbers match. Include 
the same fields as in 3.5 (for MatchType, use the string 'StreetNameandNumberDoubleMetaphoneMatch'.*/


WITH 
    NotPoBox AS(
    SELECT streetaddressline2
    FROM location
    WHERE LEFT(streetaddressline1, 6) NOT LIKE 'PO Box'
),
    StreetNumberExtraction AS (
    SELECT streetaddressline2, 
           SUBSTRING(streetaddressline2, 1, POSITION(' ' IN streetaddressline2)-1) AS StreetNumber, 
           SUBSTRING(streetaddressline2, POSITION(' ' IN streetaddressline2)+1) AS RightOfStreetNumber
    FROM NotPoBox
),
    StreetNumberCheck AS (
    SELECT *,
           CASE WHEN streetnumber SIMILAR TO '[0-9]+' 
                THEN streetnumber 
                ELSE NULL 
           END AS CheckedStreetNumber  -- Changed alias to avoid ambiguity
    FROM StreetNumberExtraction
),
    StreetSuffixExtraction AS (
    SELECT *,
           RIGHT(RightOfStreetNumber, POSITION(' ' IN REVERSE(RightOfStreetNumber))-1) AS StreetSuffix
    FROM StreetNumberCheck 
),
    StreetSuffixCheck AS (
    SELECT sse.*,
           Standard,
           LEFT(RightOfStreetNumber, LENGTH(RightOfStreetNumber) - LENGTH(StreetSuffix) -1) AS StreetName
    FROM StreetSuffixExtraction AS sse
    LEFT JOIN StreetSuffixMapping AS ssm
           ON UPPER(sse.StreetSuffix) = ssm.Written
)
SELECT 'StreetNameMatch' AS MatchType, 
       ssc.streetaddressline2, 
       ssc.streetname, 
       e.streetnumber, 
       e.streetname, 
       e.streetsuffix
FROM StreetSuffixCheck AS ssc
INNER JOIN employee_table AS e
ON ssc.streetname = e.streetname
UNION
SELECT 'FullStreetAddressMatch' AS MatchType, 
       ssc.streetaddressline2, 
       ssc.streetname, 
       e.streetnumber, 
       e.streetname, 
       e.streetsuffix
FROM StreetSuffixCheck AS ssc
INNER JOIN employee_table AS e
ON ssc.streetname = e.streetname
AND ssc.CheckedStreetNumber::int = e.streetnumber  -- Use the new alias here
AND ssc.standard = e.streetsuffix
UNION
SELECT 'StreetNameAndNumberMatchSoundexDifference' AS MatchType, 
       ssc.streetaddressline2, 
       ssc.streetname, 
       e.streetnumber, 
       e.streetname, 
       e.streetsuffix 
FROM StreetSuffixCheck AS ssc
INNER JOIN employee_table AS e
ON ssc.CheckedStreetNumber::int = e.streetnumber  -- Use the new alias here
WHERE difference(ssc.streetname, e.streetname) > 3
UNION
SELECT 'LevenshteinMatch' AS MatchType, 
       ssc.streetaddressline2, 
       ssc.streetname, 
       e.streetnumber, 
       e.streetname, 
       e.streetsuffix 
FROM StreetSuffixCheck AS ssc, employee_table AS e -- Use the new alias here
WHERE levenshtein_less_equal(ssc.streetname, e.streetname, 1) < 2
UNION
SELECT 'StreetNameandNumberDoubleMetaphoneMatch' AS MatchType, 
       ssc.streetaddressline2, 
       ssc.streetname, 
       e.streetnumber, 
       e.streetname, 
       e.streetsuffix 
FROM StreetSuffixCheck AS ssc
INNER JOIN employee_table AS e -- Use the new alias here
ON dmetaphone(ssc.streetname) = dmetaphone(e.streetname)
AND ssc.CheckedStreetNumber::int = e.streetnumber  -- Use the new alias here
ORDER BY MatchType;

-- soundex
SELECT 
    *, 
    soundex(nm) AS SoundEx_Field, 
    soundex('Johan') AS SoundEx_Johan, 
    dmetaphone(nm) AS DoubleMetaphone_Field,
    dmetaphone('Johan') AS DoubleMetaphone_Johan,
    dmetaphone_alt(nm) AS DoubleMetaphoneAlt_Field,
    dmetaphone_alt('Johan') AS DoubleMetaphoneAlt_Johan,
    difference(s.nm, 'Johan') AS SoundExDifference, 
    LEVENSHTEIN(s.nm, 'Johan') AS Levenshtein,
    levenshtein_less_equal(nm, 'Johan', 2)
    FROM s;
-- Examples of using fuzzy matching in WHERE statement
SELECT * 
    FROM s 
    WHERE dmetaphone(nm) =  dmetaphone('Johan');