--1 Improved Simple. Return Tables that has SalesQuota Greater Than 250000 and Bonus Above 4000
USE AdventureWorks2017;
GO

SELECT *
FROM Sales.SalesPerson
WHERE SalesQuota
BETWEEN '200000' AND '300000';
--WHERE SalesQuota > '200000' AND SalesQuota < '300000'


--2 Best Simple. Return Tables with Employee First Name begin with A and LAst NAme begin with S along with Employee ID
USE AdventureWorksDW2017;
GO

SELECT E.EmployeeKey,
       E.FirstName,
       E.LastName
FROM dbo.[DimEmployee] AS E
WHERE E.FirstName LIKE 'a%'
      AND E.LastName LIKE 's%';


--3 Worst Simple. Return Num of Order on each Customer ID that has more than 1 dry items. Sorted by Customer ID
USE WideWorldImporters;
GO

SELECT I.CustomerID,
       COUNT(*) AS NumOrder
FROM Sales.Invoices AS I
WHERE I.TotalDryItems > '1'
GROUP BY I.CustomerID;


--4 Simple. Return Customer with Lineage Key, Data Load Start, Table Name and Data Load Completed

USE WideWorldImportersDW;
GO

SELECT [Lineage Key],
       [Data Load Started],
       [Table Name],
       [Data Load Completed]
FROM Integration.Lineage
WHERE [Table Name] LIKE 'Customer';


-- 5. Simple. Return orders on countries that begin with the letter S. Sorted by Country
USE Northwinds2020TSQLV6;
GO

SELECT o.OrderId,
       o.ShipToCountry
FROM Sales.[Order] AS o
WHERE o.ShipToCountry LIKE 'S%'
ORDER BY o.ShipToCountry;


--6 Improved Medium. Return orders on Argentina along with Total Quantity. Sorted by orderid
USE Northwinds2020TSQLV6;
GO

SELECT O.OrderId,
       COUNT(DISTINCT OD.Quantity) AS TotalDistinctOrders
FROM Sales.[OrderDetail] AS OD
    INNER JOIN Sales.[Order] AS O
        ON OD.OrderId = O.OrderId
WHERE O.ShipToCountry = 'Argentina'
GROUP BY O.OrderId;


--7 Medium. Return Shipping Company on each Order ID. Sorted by Order ID
USE Northwinds2020TSQLV6;
GO

SELECT O.OrderId,
       S.ShipperCompanyName
FROM Sales.[Shipper] AS S
    INNER JOIN Sales.[Order] AS O
        ON O.ShipperId = S.ShipperId
ORDER BY O.OrderId;


--8 Medium. Return Order Date and Customer Company Name, Contact Name and Phone Number. Sorted Through Date
USE Northwinds2020TSQLV6;
GO

SELECT O.OrderDate,
       C.CustomerCompanyName,
       C.CustomerContactName,
       C.CustomerPhoneNumber
FROM Sales.[Customer] AS C
    INNER JOIN Sales.[Order] AS O
        ON O.CustomerId = C.CustomerId;


--9 Worst Medium. Return all customers, and for each return a Yes/No value depending on if the order is from Brazil. Sorted by Orderid
USE Northwinds2020TSQLV6;
GO

SELECT DISTINCT
       OD.OrderId,
       OD.ProductId,
       CASE
           WHEN O.OrderId IS NOT NULL THEN
               'Yes'
           ELSE
               'No'
       END AS Brazil
FROM Sales.[OrderDetail] AS OD
    LEFT OUTER JOIN Sales.[Order] AS O
        ON O.OrderId = OD.OrderId
           AND O.ShipToCountry = 'Brazil';


--10 Medium. Return Shipper Company Name, Phone Number, order id and order date made on and after January 1st, 2016. Sorted by order date
USE Northwinds2020TSQLV6;
GO

SELECT S.ShipperCompanyName,
       S.PhoneNumber,
       O.OrderId,
       O.OrderDate
FROM Sales.[Shipper] AS S
    LEFT OUTER JOIN Sales.[Order] AS O
        ON O.ShipperId = S.ShipperId
WHERE O.OrderDate >= '20160101';


--11 Medium. Return Employee ID , Employee Name and Ship to Name along with orderid. Sorted by EmployeeId
USE Northwinds2020TSQLV6;
GO

SELECT E.EmployeeId,
       E.EmployeeFirstName,
       E.EmployeeLastName,
       O.ShipToName,
       O.OrderId
FROM HumanResources.[Employee] AS E,
     Sales.[Order] AS O
WHERE E.EmployeeId = O.EmployeeId
ORDER BY E.EmployeeId;


--12 Best Medium. Return Customer ID, Order ID, Product ID, Quantity, and UnitPrice. Sorted by Customer ID
USE Northwinds2020TSQLV6;
GO

SELECT C.CustomerId,
       O.OrderId,
       OD.ProductId,
       OD.Quantity,
       OD.UnitPrice
FROM Sales.[Order] AS O
    INNER JOIN Sales.[OrderDetail] AS OD
        ON O.OrderId = OD.OrderId
    RIGHT OUTER JOIN Sales.[Customer] AS C
        ON C.CustomerId = O.CustomerId
ORDER BY C.CustomerId;

--13 Medium. Count the nuber of shipments of each ShipperID
USE Northwinds2020TSQLV6;
GO

SELECT S.ShipperId,
       COUNT(*) AS NumberofShipment
FROM Sales.Shipper AS S
    LEFT OUTER JOIN Sales.[Order] AS O
        ON S.ShipperId = O.ShipperId
GROUP BY S.ShipperId;


--14 Complex. Create a recursive function where it will return all manager id that is greater than employee id with repeats. Also cross join it with order id
USE Northwinds2020TSQLV6;
GO

WITH CTE
AS (SELECT EmployeeId,
           EmployeeManagerId,
           EmployeeFirstName,
           EmployeeLastName
    FROM HumanResources.[Employee]
    WHERE EmployeeId = 9
    UNION ALL
    SELECT P.EmployeeId,
           P.EmployeeManagerId,
           P.EmployeeFirstName,
           P.EmployeeLastName
    FROM CTE AS C
        INNER JOIN HumanResources.[Employee] AS P
            ON C.EmployeeManagerId > P.EmployeeId)
SELECT C.EmployeeId,
       C.EmployeeManagerId,
       C.EmployeeFirstName,
       C.EmployeeLastName,
       O.OrderId
FROM CTE AS C
    CROSS JOIN Sales.[Order] AS O;


--15 Best Complex. Create a Function where the input returns the top 3 suppliers in USA along with Product ID and Order ID. Sorted by Supplier ID
USE Northwinds2020TSQLV6;
GO

DROP FUNCTION IF EXISTS Production.USASuppliers;
GO
CREATE FUNCTION Production.USASuppliers
(
    @country AS CHAR(3),
    @n AS INT
)
RETURNS TABLE
AS
RETURN SELECT TOP (@n)
              SupplierId,
              SupplierCompanyName,
              SupplierContactName,
              SupplierContactTitle
       FROM Production.Supplier
       WHERE SupplierCountry = @country
       ORDER BY SupplierId DESC;
GO

SELECT S.SupplierCompanyName,
       S.SupplierContactName,
       S.SupplierContactTitle,
       P.ProductId,
       OD.OrderId
FROM Production.USASuppliers('USA', 3) AS S
    INNER JOIN Production.Product AS P
        ON S.SupplierId = P.SupplierId
    INNER JOIN Sales.[OrderDetail] AS OD
        ON P.ProductId = OD.ProductId
ORDER BY S.SupplierId DESC;


--16 Complex. Return monthly growth in the year of 2015 base on the customer orders. Sorted by ordermonth
USE Northwinds2020TSQLV6;
GO

WITH MonthlyCount
AS (SELECT MONTH(OrderDate) AS OrderMonth,
           COUNT(DISTINCT CustomerId) AS NumCust
    FROM Sales.[Order]
    WHERE YEAR(OrderDate) = '2015'
    GROUP BY MONTH(OrderDate))
SELECT Cur.OrderMonth,
       Cur.NumCust AS CurCust,
       Prv.NumCust AS PrvCust,
       Cur.NumCust - Prv.NumCust AS GROWTH
FROM MonthlyCount AS Cur
    LEFT OUTER JOIN MonthlyCount AS Prv
        ON Cur.OrderMonth = Prv.OrderMonth + 1
    CROSS JOIN dbo.Nums AS D
WHERE D.N <= 5
ORDER BY N,
         OrderMonth;


--17 Complex. Create a table where supplier, shipper and customer are all in the same region and return their phone number and the shipping date
USE Northwinds2020TSQLV6;
GO

SELECT O.CustomerId,
       O.ShipToDate,
       C.CustomerPhoneNumber,
       S.SupplierPhoneNumber
FROM Sales.[Order] AS O
    INNER JOIN Sales.[Customer] AS C
        ON O.ShipToRegion = C.CustomerRegion
    INNER JOIN Production.Supplier AS S
        ON C.CustomerRegion = S.SupplierRegion;


--18 Worst Complex. Create Query That Returns both the Total Sum of Distinct Stock Item Key and Sum of Purchase Key
USE WideWorldImportersDW;
GO

WITH C1
AS (SELECT YEAR([Date Key]) AS OrderYear,
           [Stock Item Key],
           [Ordered Quantity]
    FROM Fact.[Purchase]),
     C2
AS (SELECT OrderYear,
           COUNT(DISTINCT [Stock Item Key]) AS NumKey,
           COUNT([Ordered Quantity]) AS [Ordered Quantity Y]
    FROM C1
    GROUP BY OrderYear),
     C3
AS (SELECT [Date Key],
           COUNT([Purchase Key]) AS [Ordered Quantity M]
    FROM Fact.[Purchase]
    GROUP BY [Date Key])
SELECT C.OrderYear,
       C.NumKey,
       C.[Ordered Quantity Y],
       T.[Ordered Quantity M]
FROM C2 AS C
    INNER JOIN C3 AS T
        ON C.OrderYear = YEAR(T.[Date Key]);


--19 Improved Complex. Create Function where you input first and last name and it returns the title. birth date, address, postal code, country, phone number, orderid and discount percentage. Sorted by orderid
USE Northwinds2020TSQLV6;
GO

DROP FUNCTION IF EXISTS HumanResources.Information;
GO
CREATE FUNCTION HumanResources.Information
(
    @F AS NVARCHAR(4000),
    @L AS NVARCHAR(4000)
)
RETURNS TABLE
AS
RETURN SELECT E.EmployeeId,
              O.OrderId,
              E.EmployeeTitle,
              E.BirthDate,
              E.HireDate,
              E.EmployeeAddress,
              E.EmployeePostalCode,
              E.EmployeeCountry,
              E.EmployeePhoneNumber,
              OD.DiscountPercentage
       FROM HumanResources.[Employee] AS E
           INNER JOIN Sales.[Order] AS O
               ON E.EmployeeId = O.EmployeeId
           INNER JOIN Sales.OrderDetail AS OD
               ON O.OrderId = OD.OrderId
       WHERE E.EmployeeFirstName = @F
             AND E.EmployeeLastName = @L;
GO

SELECT *
FROM HumanResources.Information('Sara', 'Davis')
FOR JSON PATH, ROOT('CustomerOrders'), INCLUDE_NULL_VALUES;


--20 Complex. Create 2 Functions. First Function takes in all the ID of a certain country. Second Function sets the Country to Germany and returns in unit price, quantity and customer company name
USE Northwinds2020TSQLV6;
GO

DROP FUNCTION IF EXISTS Sales.Order1;
GO
CREATE FUNCTION Sales.Order1
(
    @region AS NVARCHAR(400)
)
RETURNS TABLE
AS
RETURN SELECT CustomerId,
              OrderId,
              EmployeeId,
              ShipperId
       FROM Sales.[Order]
       WHERE ShipToCountry = @region
       GROUP BY CustomerId,
                OrderId,
                EmployeeId,
                ShipperId;
GO


DROP VIEW IF EXISTS Sales.Ship;
GO
CREATE VIEW Sales.Ship
AS
SELECT O.OrderId,
       O.CustomerId,
       O.EmployeeId,
       O.ShipperId,
       OD.Quantity,
       OD.UnitPrice,
       C.CustomerCompanyName
FROM Sales.Order1('Germany') AS O
    INNER JOIN
    (SELECT UnitPrice, Quantity, OrderId FROM Sales.OrderDetail) AS OD
        ON O.OrderId = OD.OrderId
    INNER JOIN
    (SELECT CustomerId, CustomerCompanyName FROM Sales.Customer) AS C
        ON O.CustomerId = C.CustomerId;
GO

SELECT *
FROM Sales.Ship;