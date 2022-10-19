--Simple
--show me the person who packed the most orders (with ties)
--using WideWorldImporters

USE WideWorldImporters;
SELECT TOP (1) WITH TIES
       PackedByPersonID,
       COUNT(*) AS packed_orders
FROM Sales.Invoices
GROUP BY PackedByPersonID
ORDER BY packed_orders DESC;

--simple
--show me the top 5 items where we have the most stock on hand and their total price
--using WideWorldImportersDW

USE WideWorldImportersDW;

SELECT TOP (5)
       [Stock Item Key],
       [Quantity On Hand],
       [Last Cost Price],
       ([Quantity On Hand] * [Last Cost Price]) AS total_price
FROM Fact.[Stock Holding]
WHERE [Last Cost Price] > 0
ORDER BY [Quantity On Hand] DESC;

--simple
--show me the worst selling internet items to the best selling items
--using AdventureWorksDW2017

USE AdventureWorksDW2017;

SELECT ProductKey,
       COUNT(ProductKey) AS how_many_sold
FROM dbo.FactInternetSales
GROUP BY ProductKey
ORDER BY how_many_sold;

--simple
--show me work orders where there were products scapped and the reason
--using AdventureWorks2017

USE AdventureWorks2017;

SELECT WO.WorkOrderID,
       WO.ScrappedQty,
       WO.ScrapReasonID,
       SR.Name
FROM Production.WorkOrder AS WO
    INNER JOIN Production.ScrapReason AS SR
        ON WO.ScrapReasonID = SR.ScrapReasonID
WHERE ScrappedQty > 70
ORDER BY ScrappedQty;

--simple
--show me countries that have a total cost of less than 10000 of orders
--Northwinds2020TSQLV6

USE Northwinds2020TSQLV6;

SELECT ShipToCountry,
       SUM(Freight) AS total_cost
FROM Sales.[Order]
GROUP BY ShipToCountry
HAVING SUM(Freight) < 10000
ORDER BY total_cost;

--medium *
--show me the employee name whos made the highest sales amount in 2011 quarter 1
--using AdventureWorksDW2017

USE AdventureWorksDW2017;

DECLARE @max AS INT =
        (
            SELECT MAX(SalesAmountQuota)
            FROM dbo.FactSalesQuota
            WHERE CalendarQuarter = '1'
                  AND CalendarYear = '2011'
        );

SELECT FirstName,
       LastName,
       EmployeeKey
FROM dbo.DimEmployee
WHERE EmployeeKey IN
      (
          SELECT TOP (1) WITH TIES
                 EmployeeKey
          FROM dbo.FactSalesQuota
          WHERE SalesAmountQuota = @max
          ORDER BY SalesAmountQuota DESC
      );

--medium
--show me the shipper that we use the most along with their info
--Northwinds2020TSQLV6

USE Northwinds2020TSQLV6;

DECLARE @topshipid AS INT =
        (
            SELECT TOP (1)
                   ShipperId
            FROM Sales.[Order]
            GROUP BY ShipperId
            ORDER BY COUNT(ShipperId) DESC
        );

SELECT DISTINCT
       o.ShipperId,
       ss.ShipperCompanyName,
       ss.PhoneNumber
FROM Sales.[Order] AS o
    INNER JOIN Sales.Shipper AS ss
        ON o.ShipperId = ss.ShipperId
WHERE o.ShipperId = @topshipid;

--medium
--show me all us territories with the number of customers they have and growth from last years sales
--AdventureWorks2017

USE AdventureWorks2017;

SELECT c.TerritoryID,
       c.numcust,
       st.growth
FROM
(
    SELECT TerritoryID,
           COUNT(CustomerID) AS numcust
    FROM Sales.Customer
    GROUP BY TerritoryID
) AS c
    INNER JOIN
    (
        SELECT TerritoryID,
               CountryRegionCode,
               (SalesYTD - SalesLastYear) AS growth
        FROM Sales.SalesTerritory
    ) AS st
        ON st.TerritoryID = c.TerritoryID
WHERE st.CountryRegionCode = 'US'
ORDER BY c.numcust;

--medium
--the top 10% of customers that spent the most money in 2015
--WideWorldImporters

USE WideWorldImporters;

SELECT TOP (10) PERCENT
       o.CustomerID,
       YEAR(o.OrderDate) AS Orderyear,
       SUM(ol.Quantity * ol.UnitPrice) AS spent
FROM Sales.Orders AS o
    INNER JOIN Sales.OrderLines AS ol
        ON ol.OrderID = o.OrderID
WHERE YEAR(o.OrderDate) = '2015'
GROUP BY o.CustomerID,
         YEAR(o.OrderDate)
ORDER BY spent DESC;

--medium
--show who helped customer 69 in 2015
--WideWorldImportersDW


USE WideWorldImportersDW;

DROP VIEW IF EXISTS Fact.totalsalesp;
GO
CREATE VIEW Fact.totalsalesp
AS
SELECT [Customer Key],
       [Salesperson Key],
       SUM(DISTINCT [Salesperson Key]) AS totalsalesperson
FROM Fact.[Order] AS o
WHERE [Customer Key] = 69
      AND YEAR(o.[Order Date Key]) = 2014
GROUP BY [Customer Key],
         o.[Salesperson Key];
GO

SELECT o.[Customer Key],
       e.[Preferred Name]
FROM Dimension.Employee AS e
    INNER JOIN Fact.totalsalesp AS o
        ON o.[Salesperson Key] = e.[Employee Key];

--medium**
--show all discontinued orders that customer 5 placed
--and show the amount
--Northwinds2020TSQLV6

USE Northwinds2020TSQLV6;

SELECT o.CustomerId,
       od.ProductId,
       COUNT(p.Discontinued) AS discontamount
FROM Sales.[Order] AS o
    INNER JOIN Sales.OrderDetail AS od
        ON od.OrderId = o.OrderId
    INNER JOIN Production.Product AS p
        ON p.ProductId = od.ProductId
WHERE p.Discontinued = 1
      AND o.CustomerId = 5
GROUP BY o.CustomerId,
         od.ProductId;

--medium**
--show all discontinued orders that customer 5 placed
--and show the amount
--Northwinds2020TSQLV6

USE Northwinds2020TSQLV6;
DROP FUNCTION IF EXISTS Sales.viewcustdiscontinue;
GO
CREATE FUNCTION Sales.viewcustdiscontinue
(
    @custid AS INT
)
RETURNS TABLE
AS
RETURN SELECT o.CustomerId,
              od.ProductId,
              COUNT(p.Discontinued) AS discontamount
       FROM Sales.[Order] AS o
           INNER JOIN Sales.OrderDetail AS od
               ON od.OrderId = o.OrderId
           INNER JOIN Production.Product AS p
               ON p.ProductId = od.ProductId
       WHERE p.Discontinued = 1
             AND o.CustomerId = @custid
       GROUP BY o.CustomerId,
                od.ProductId;
GO
SELECT *
FROM Sales.viewcustdiscontinue(5);

--medium
--show the each supplier with their total price of goods
--Northwinds2020TSQLV6

USE Northwinds2020TSQLV6;

SELECT p.SupplierId,
       s.SupplierCompanyName,
       SUM(p.UnitPrice) AS totalpriceofgoods
FROM Production.Product AS p
    INNER JOIN Production.Supplier AS s
        ON s.SupplierId = p.SupplierId
WHERE p.Discontinued = 0
GROUP BY p.SupplierId,
         s.SupplierCompanyName;

--medium
--show me all potential buyers that have an income of more than 100000
--and match them with the youngest female employee
--AdventureWorksDW2017

USE AdventureWorksDW2017;

DROP VIEW IF EXISTS dbo.femp;
GO
CREATE VIEW dbo.femp
AS
SELECT FirstName,
       LastName,
       EmployeeKey,
       ROW_NUMBER() OVER (ORDER BY YEAR(BirthDate) DESC) AS rownum
FROM dbo.DimEmployee
WHERE MaritalStatus = 's'
      AND Gender = 'F'
      AND YEAR(BirthDate) > '1970';


GO

SELECT pb.FirstName,
       pb.LastName,
       pb.YearlyIncome,
       pb.Phone,
       f.FirstName,
       f.LastName,
       f.EmployeeKey
FROM
(
    SELECT FirstName,
           LastName,
           YearlyIncome,
           Phone,
           ROW_NUMBER() OVER (ORDER BY YearlyIncome DESC) AS rownum
    FROM dbo.ProspectiveBuyer
    WHERE MaritalStatus = 'S'
          AND Gender = 'M'
          AND YearlyIncome > 100000
) AS pb
    INNER JOIN dbo.femp AS f
        ON f.rownum = pb.rownum;

--complex
--show me the employees, sumfreight and shipper who is assigned to customer 69
--Northwinds2020TSQLV6

USE Northwinds2020TSQLV6;

DROP FUNCTION IF EXISTS dbo.custod;
GO
CREATE FUNCTION dbo.custod
(
    @customerid AS INT
)
RETURNS TABLE
AS
RETURN SELECT s.ShipperCompanyName,
              o.sumfreight,
              e.EmployeeId,
              e.EmployeeFirstName
       FROM
       (
           SELECT CustomerId,
                  EmployeeId,
                  ShipperId,
                  SUM(Freight) AS sumfreight
           FROM Sales.[Order]
           WHERE CustomerId = @customerid
           GROUP BY CustomerId,
                    OrderId,
                    EmployeeId,
                    ShipperId
       ) AS o
           INNER JOIN Sales.Shipper AS s
               ON s.ShipperId = o.ShipperId
           INNER JOIN HumanResources.Employee AS e
               ON e.EmployeeId = o.EmployeeId;
GO

SELECT *
FROM dbo.custod(69);

--complex
--stalk people and find their addresses/email addresses
--adventureWorks2017

USE AdventureWorks2017;

DROP FUNCTION IF EXISTS Person.stalkperson;
GO
CREATE FUNCTION Person.stalkperson
(
    @personfn AS Name,
    @personmn AS Name,
    @personln AS Name
)
RETURNS TABLE
AS
RETURN SELECT p.FirstName,
              p.MiddleName,
              p.LastName,
              em.EmailAddress,
              a.AddressLine1,
              a.City,
              a.PostalCode
       FROM
       (
           SELECT FirstName,
                  MiddleName,
                  LastName,
                  BusinessEntityID
           FROM Person.Person
           WHERE FirstName = @personfn
                 AND
                 (
                     MiddleName = @personmn
                     OR MiddleName IS NULL
                 )
                 AND LastName = @personln
       ) AS p
           LEFT OUTER JOIN Person.BusinessEntityAddress AS bea
               ON bea.BusinessEntityID = p.BusinessEntityID
           INNER JOIN Person.Address AS a
               ON a.AddressID = bea.AddressID
           INNER JOIN Person.EmailAddress AS em
               ON em.BusinessEntityID = p.BusinessEntityID;
GO

SELECT *
FROM Person.stalkperson('rob', NULL, 'walters');

--complex
--irs asked about a customer you hate, give him how much the customer payed in taxes each year
--and information about his assets.
--adventureWorksDW2017

USE AdventureWorksDW2017;

DROP FUNCTION IF EXISTS dbo.taxassets;
GO
CREATE FUNCTION dbo.taxassets
(
    @custid AS INT
)
RETURNS TABLE
AS
RETURN SELECT fis.CustomerKey,
              YEAR(OrderDate) AS orderyear,
              SUM(TaxAmt) AS sumtax,
              c.NumberCarsOwned,
              CASE
                  WHEN c.HouseOwnerFlag = 1 THEN
                      'Yes'
                  ELSE
                      'No'
              END AS homeowner
       FROM dbo.FactInternetSales AS fis
           INNER JOIN dbo.DimCustomer AS c
               ON c.CustomerKey = fis.CustomerKey
       WHERE fis.CustomerKey = @custid
       GROUP BY fis.CustomerKey,
                YEAR(OrderDate),
                c.NumberCarsOwned,
                c.HouseOwnerFlag;
GO

DROP FUNCTION IF EXISTS dbo.findcustid;
GO
CREATE FUNCTION dbo.findcustid
(
    @personfn AS NVARCHAR(50),
    @personmn AS NVARCHAR(50),
    @personln AS NVARCHAR(50)
)
RETURNS TABLE
AS
RETURN SELECT CustomerKey
       FROM dbo.DimCustomer
       WHERE FirstName = @personfn
             AND
             (
                 MiddleName = @personmn
                 OR MiddleName IS NULL
             )
             AND LastName = @personln;
GO
DECLARE @custkey AS INT =
        (
            SELECT CustomerKey FROM dbo.findcustid('Caleb', 'F', 'Carter')
        );

SELECT *
FROM dbo.taxassets(@custkey);

--complex **
--find out what happened with customer 4s latest order, show when the order was picked
--and expected delivery along, check the warehouse to see if we can ship him another package
--WideWorldImporters

USE WideWorldImporters;


DROP FUNCTION IF EXISTS Sales.custorderdelivery;
GO
CREATE FUNCTION Sales.custorderdelivery
(
    @custkey AS INT
)
RETURNS TABLE
AS
RETURN SELECT o.CustomerID,
              o.OrderDate,
              o.OrderID,
              CAST(o.PickingCompletedWhen AS SMALLDATETIME) AS pickingcomplete,
              o.ExpectedDeliveryDate,
              ol.StockItemID,
              sih.QuantityOnHand,
              CASE
                  WHEN o.ExpectedDeliveryDate < SYSDATETIME() THEN
                      'late'
                  ELSE
                      'ontime'
              END AS status
       FROM Sales.Orders AS o
           INNER JOIN Sales.OrderLines AS ol
               ON ol.OrderID = o.OrderID
           INNER JOIN Warehouse.StockItemHoldings AS sih
               ON sih.StockItemID = ol.StockItemID
       WHERE o.CustomerID = @custkey
             AND o.OrderDate =
             (
                 SELECT MAX(OrderDate)FROM Sales.Orders WHERE CustomerID = @custkey
             );
GO

SELECT *
FROM Sales.custorderdelivery(4);

--complex
--figure out all the lost profits from each stock item in the latest orderyear
--because unitprice was used instead of msrp
--WideWorldImportersDW

USE WideWorldImportersDW;

DECLARE @maxyr AS INT =
        (
            SELECT MAX(YEAR([Invoice Date Key]))FROM Fact.Sale
        );

SELECT s.[Stock Item Key],
       s.ordyr,
       SUM(s.stockorderd * s.Quantity) AS totalordered,
       (s.Quantity * sh.[Recommended Retail Price] - s.Quantity * sh.[Unit Price]) AS lostprofit
FROM
(
    SELECT [Stock Item Key],
           YEAR([Invoice Date Key]) AS ordyr,
           Quantity,
           COUNT([Stock Item Key]) AS stockorderd
    FROM Fact.Sale
    GROUP BY YEAR([Invoice Date Key]),
             [Stock Item Key],
             Quantity
) AS s
    INNER JOIN
    (
        SELECT [Stock Item Key],
               [Unit Price],
               [Recommended Retail Price]
        FROM Dimension.[Stock Item]
    ) AS sh
        ON sh.[Stock Item Key] = s.[Stock Item Key]
WHERE s.ordyr = @maxyr
GROUP BY s.[Stock Item Key],
         s.ordyr,
         (s.Quantity * sh.[Recommended Retail Price] - s.Quantity * sh.[Unit Price])
ORDER BY lostprofit DESC;

--complex
--get customer 78s phone number with total freight and the shipper that shipped those orders for the year 2015
--Northwinds2020TSQLV6

USE Northwinds2020TSQLV6;

DROP FUNCTION IF EXISTS Sales.custcin;
GO
CREATE FUNCTION Sales.custcin
(
    @yer AS INT,
    @c AS INT
)
RETURNS TABLE
AS
RETURN SELECT CustomerId,
              ShipperId,
              SUM(Freight) AS total
       FROM Sales.[Order]
       WHERE YEAR(OrderDate) = @yer
             AND CustomerId = @c
       GROUP BY CustomerId,
                ShipperId;
GO

DROP VIEW IF EXISTS Sales.custshipinfo;
GO
CREATE VIEW Sales.custshipinfo
AS
SELECT cc.customerid,
       cust.CustomerPhoneNumber,
       cc.total,
       sh.ShipperCompanyName
FROM Sales.custcin(2015, 78) AS cc
    INNER JOIN
    (SELECT ShipperId, ShipperCompanyName FROM Sales.Shipper) AS sh
        ON sh.ShipperId = cc.shipperid
    INNER JOIN
    (SELECT CustomerId, CustomerPhoneNumber FROM Sales.Customer) AS cust
        ON cust.CustomerId = cc.customerid;
GO

SELECT *
FROM Sales.custshipinfo;

--complex (improved)
--show who helped customer 69 in 2014
--added function to select which customer and which year and customer buying group
--WideWorldImportersDW


USE WideWorldImportersDW;

DROP FUNCTION IF EXISTS Fact.custhelp;
GO
CREATE FUNCTION Fact.custhelp
(
    @year AS INT,
    @c AS INT
)
RETURNS TABLE
AS
RETURN SELECT [Customer Key],
              [Salesperson Key],
              SUM(DISTINCT [Salesperson Key]) AS totalsalesperson
       FROM Fact.[Order] AS o
       WHERE [Customer Key] = @c
             AND YEAR(o.[Order Date Key]) = @year
       GROUP BY [Customer Key],
                o.[Salesperson Key];
GO

SELECT o.[Customer Key],
       cc.[Buying Group],
       e.[Preferred Name]
FROM Dimension.Employee AS e
    INNER JOIN Fact.custhelp(2014, 69) AS o
        ON o.[Salesperson Key] = e.[Employee Key]
    INNER JOIN Dimension.Customer AS cc
        ON cc.[Customer Key] = o.[Customer Key];

--complex(improved)
--show me all us territories with the number of customers they have and growth from last years sales
--added function to pick the territory id and show buisnessentityid
--AdventureWorks2017

USE AdventureWorks2017;

DROP FUNCTION IF EXISTS Sales.whichteri;
GO
CREATE FUNCTION Sales.whichteri
(
    @terrid AS INT
)
RETURNS TABLE
AS
RETURN SELECT TerritoryID,
              CountryRegionCode,
              (SalesYTD - SalesLastYear) AS growth
       FROM Sales.SalesTerritory
       WHERE TerritoryID = @terrid;
GO

SELECT c.TerritoryID,
       c.numcust,
       st.growth,
       sth.BusinessEntityID
FROM
(
    SELECT TerritoryID,
           COUNT(CustomerID) AS numcust
    FROM Sales.Customer
    GROUP BY TerritoryID
) AS c
    INNER JOIN Sales.whichteri(3) AS st
        ON st.TerritoryID = c.TerritoryID
    INNER JOIN Sales.SalesTerritoryHistory AS sth
        ON sth.TerritoryID = st.TerritoryID
WHERE st.CountryRegionCode = 'US'
ORDER BY c.numcust; 