--Proposition 1
--Employees assigned to salesterritory 6
--Best Simple	
USE AdventureWorksDW2017;
DECLARE @territoryid AS INT = 6;

SELECT D.Employee
FROM
(
    SELECT SalesTerritoryKey,
           EmployeeKey,
           FirstName + ' ' + LastName AS Employee
    FROM dbo.DimEmployee
    WHERE SalesTerritoryKey = @territoryid
) AS D;

--Proposition 2
--Staff in managerial positions and their sales territory Regions
--Best Medium
USE AdventureWorksDW2017;

WITH Manager
AS (SELECT EmployeeKey,
           (FirstName + ' ' + LastName) AS Name,
           Title,
           SalesTerritoryKey,
           EmailAddress,
           Gender,
           SalariedFlag
    FROM dbo.DimEmployee
    WHERE Title LIKE '%Manager%')
SELECT DISTINCT
       Manager.Name,
       Title,
       B.SalesTerritoryCountry,
       Gender,
       SalariedFlag
FROM Manager
    INNER JOIN dbo.DimSalesTerritory AS B
        ON Manager.SalesTerritoryKey = B.SalesTerritoryKey;

--Proposition 3
--List of stores that would possibly have each item based on their product type
--Best Complex

USE AdventureWorksDW2017;

DROP VIEW IF EXISTS BikeShops;
GO
CREATE VIEW BikeShops
AS
SELECT ResellerKey,
       ResellerName,
       ProductLine,
       NumberEmployees,
       AnnualRevenue
FROM dbo.DimReseller
WHERE BusinessType LIKE '%Bike Shop%';
GO

WITH BigStores
AS (SELECT TOP 1 WITH TIES
           ResellerName,
           ProductLine AS StoreType
    FROM BikeShops AS BS
    ORDER BY NumberEmployees DESC)
SELECT C1.*,
       A.*
FROM BigStores AS C1
    CROSS APPLY
(
    SELECT ProductLine,
           EnglishProductName,
           S.EnglishProductSubcategoryName
    FROM dbo.DimProduct AS P
        INNER JOIN dbo.DimProductSubcategory AS S
            ON P.ProductSubcategoryKey = S.ProductSubcategoryKey
    WHERE P.ProductLine = LEFT(C1.StoreType, 1)
) A;

DROP VIEW BikeShops;

--Proposition 4
--Amount of suppliers from each country
--Worst Simple
USE Northwinds2020TSQLV6;

SELECT SupplierCountry,
       COUNT(DISTINCT supplierid) AS NumberSupplier
FROM
(
    SELECT SupplierCountry,
           SupplierId
    FROM Production.Supplier
) AS D(SupplierCountry, supplierid)
GROUP BY SupplierCountry;

--Proposition 5
--pairs every UK employee with a UK based company 
--Worst medium
USE Northwinds2020TSQLV6;

WITH UKCusts
AS (SELECT DISTINCT
           CustomerCompanyName
    FROM Sales.Customer
    WHERE CustomerCountry = N'UK')
SELECT e.EmployeeId,
       e.EmployeeFirstName + ' ' + e.EmployeeLastName AS names,
       C.CustomerCompanyName
FROM HumanResources.Employee AS e,
     UKCusts AS C
WHERE e.EmployeeCountry = N'UK'
ORDER BY C.CustomerCompanyName;

--Proposition 6
--Average prices for each supplier with corresponding products
--Worst Complex 
USE Northwinds2020TSQLV6;

DROP VIEW IF EXISTS SupplyProd;
GO
CREATE VIEW SupplyProd
AS
SELECT S.SupplierId,
       S.SupplierCompanyName,
       C.CategoryName,
       PD.ProductName,
       PD.UnitPrice
FROM Production.Supplier AS S
    LEFT OUTER JOIN(Production.Product AS PD
    INNER JOIN Production.Category AS C
        ON PD.CategoryId = C.CategoryId)
        ON S.SupplierId = PD.SupplierId;
GO

WITH CT1
AS (SELECT TOP (50) WITH TIES
           *
    FROM SupplyProd
    ORDER BY UnitPrice DESC)
SELECT SupplierCompanyName,
       AVG(UnitPrice) AS avgprice
FROM CT1
GROUP BY SupplierCompanyName;

--Proposition 7
--Count of customers for each day in 2016
--Improved Simple
USE WideWorldImporters;

WITH C (days2016, customerid)
AS (SELECT OrderDate,
           CustomerID
    FROM Sales.Orders
    WHERE YEAR(OrderDate) = 2016)
SELECT days2016,
       COUNT(DISTINCT customerid) AS numcusts
FROM C
GROUP BY days2016
ORDER BY days2016 ASC;

--Proposition 8
--What did the customer order (corresponding email) improved
--Improved Medium
USE AdventureWorksDW2017;

SELECT TOP 10
       sales.CustomerKey,
       cust.EmailAddress,
       sales.SalesOrderNumber,
       prod.EnglishProductName,
       sales.SalesAmount,
       sales.OrderDate
FROM dbo.DimCustomer AS cust
    LEFT OUTER JOIN(dbo.FactInternetSales AS sales
    INNER JOIN dbo.DimProduct AS prod
        ON sales.ProductKey = prod.ProductKey)
        ON sales.CustomerKey = cust.CustomerKey
ORDER BY sales.OrderDate DESC;

--Proposition 9
--Daily average temperature of warehouse vehicle compared to overall average and average temperature of the cold room for each corresponding day
--Improved Complex

USE WideWorldImporters;

DROP FUNCTION IF EXISTS dbo.VehTemperatures;
GO
CREATE FUNCTION dbo.VehTemperatures
(
    @temp AS FLOAT
)
RETURNS TABLE
AS
RETURN SELECT CAST(RecordedWhen AS DATE) AS RecordDay,
              CAST(AVG(Temperature) AS DECIMAL(5, 2)) AS VehicleAvgTemp
       FROM Warehouse.VehicleTemperatures
       WHERE Temperature < @temp
       GROUP BY CAST(RecordedWhen AS DATE);
GO

DECLARE @temp AS FLOAT;
SELECT @temp = AVG(Temperature)
FROM Warehouse.ColdRoomTemperatures_Archive;

SELECT VH.RecordDay,
       VH.VehicleAvgTemp,
       ColdRmAvgTemp
FROM dbo.VehTemperatures(@temp) AS VH
    INNER JOIN
    (
        SELECT CAST(RecordedWhen AS DATE) AS RecordDay,
               CAST(AVG(Temperature) AS DECIMAL(5, 2)) AS ColdRmAvgTemp
        FROM Warehouse.ColdRoomTemperatures_Archive
        GROUP BY CAST(RecordedWhen AS DATE)
    ) AS CR
        ON VH.RecordDay = CR.RecordDay;

--Proposition 10
--days where the average vehicle temperature a day
-- is greater than recorded overall average
--Simple
USE WideWorldImporters;

SELECT CAST(w.RecordedWhen AS DATE) AS RecordDay,
       AVG(w.Temperature) AS AvgTemp
FROM Warehouse.VehicleTemperatures w
GROUP BY CAST(RecordedWhen AS DATE)
HAVING AVG(w.Temperature) >
(
    SELECT AVG(Temperature)FROM Warehouse.VehicleTemperatures
)
ORDER BY CAST(RecordedWhen AS DATE) ASC;

--Proposition 11
--Return Email/Password from a person 
--Simple 
USE AdventureWorks2017;

SELECT per.FirstName + ' ' + per.LastName AS name,
       e.EmailAddress,
       p.PasswordHash
FROM Person.Person AS per
    INNER JOIN Person.Password AS p
        ON per.BusinessEntityID = p.BusinessEntityID
    INNER JOIN Person.EmailAddress AS e
        ON per.BusinessEntityID = e.BusinessEntityID;

---Proposition 12
--Total quantity by year for Purchases and Sales
--Medium

USE AdventureWorks2017;

WITH c1
AS (SELECT YEAR(DueDate) AS orderyear,
           SUM(OrderQty) AS TotalOrder
    FROM Purchasing.PurchaseOrderDetail
    GROUP BY YEAR(DueDate))
SELECT c1.*,
       c2.TotalSales
FROM c1,
(
    SELECT YEAR(ModifiedDate) AS orderyear,
           SUM(OrderQty) AS TotalSales
    FROM Sales.SalesOrderDetail
    GROUP BY YEAR(ModifiedDate)
) AS c2
WHERE c1.orderyear = c2.orderyear
ORDER BY c1.orderyear;

--Proposition 13
--List price and order price for most expensive purchase product
--Medium

USE AdventureWorks2017;
DECLARE @maxprice AS FLOAT =
        (
            SELECT MAX(UnitPrice)FROM Purchasing.PurchaseOrderDetail
        );

WITH c1
AS (SELECT YEAR(DueDate) AS orderyear,
           UnitPrice,
           ProductID
    FROM Purchasing.PurchaseOrderDetail
    WHERE UnitPrice = @maxprice)
SELECT DISTINCT
       c1.*,
       p1.ListPrice
FROM c1
    INNER JOIN Production.Product p1
        ON c1.ProductID = p1.ProductID
ORDER BY orderyear;

--Proposition 14
--Returns top 10 biggest customer transaction and order
--Medium
USE WideWorldImporters;

DROP VIEW IF EXISTS Sales.CustTransc;
GO
CREATE VIEW Sales.CustTransc
AS
SELECT ct.CustomerID,
       ct.CustomerTransactionID,
       od.CustomerPurchaseOrderNumber,
       od.OrderID,
       ct.TransactionAmount
FROM Sales.CustomerTransactions AS ct
    INNER JOIN Sales.Orders AS od
        ON ct.CustomerID = od.CustomerID;
GO

SELECT TOP 10
       *
FROM Sales.CustTransc
ORDER BY TransactionAmount DESC;


--Proposition 15
--Returns orders based on selected customer and returns contact info
--Medium

USE WideWorldImportersDW;

DROP FUNCTION IF EXISTS Fact.OrderCust;
GO
CREATE FUNCTION Fact.OrderCust
(
    @cuskey AS INT
)
RETURNS TABLE
AS
RETURN SELECT ord.[Customer Key],
              ord.[Order Key],
              cust.[Primary Contact],
              cust.Customer
       FROM Fact.[Order] AS ord
           INNER JOIN
           (
               SELECT Customer,
                      [Primary Contact],
                      [Customer Key]
               FROM Dimension.Customer
           ) AS cust
               ON ord.[Customer Key] = cust.[Customer Key]
       WHERE @cuskey = ord.[Customer Key];
GO

SELECT TOP 25
       *
FROM Fact.OrderCust(5);

--Proposition 16
--Returns customer, description of product, transaction total inc tax, and profit, only if WWI Invoice ID exists
--Medium
USE WideWorldImportersDW;

WITH Sales
AS (SELECT S.[Sale Key],
           S.[Customer Key] AS [Sales Cust],
           S.[WWI Invoice ID],
           S.[Description] AS [Sales Desc],
           S.[Profit],
           St.[Customer Key] AS [Transaction Cust],
           St.[Total Including Tax] AS [Transaction Total inc Tax]
    FROM Fact.Sale AS S
        INNER JOIN Fact.[Transaction] AS St
            ON S.[WWI Invoice ID] = St.[WWI Invoice ID])
SELECT *
FROM Sales;


--Proposition 17
--Descriptive return of most recent orders
--Complex

USE WideWorldImportersDW;

DROP FUNCTION IF EXISTS Fact.DescOrder;
GO
CREATE FUNCTION Fact.DescOrder
(
    @dateid AS DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT ord.[Order Key],
           ord.[Order Date Key],
           cust.Customer,
           item.[Unit Price],
           city.[City],
           city.[State Province]
    FROM Fact.[Order] AS ord
        INNER JOIN
        (
            SELECT city.[City],
                   city.[City Key],
                   city.[State Province]
            FROM Dimension.City
        ) AS city
            ON ord.[City Key] = city.[City Key]
        INNER JOIN
        (SELECT Customer, [Customer Key] FROM Dimension.Customer) AS cust
            ON cust.[Customer Key] = ord.[Customer Key]
        INNER JOIN
        (
            SELECT [Stock Item Key],
                   [Unit Price]
            FROM Dimension.[Stock Item]
        ) AS item
            ON item.[Stock Item Key] = ord.[Stock Item Key]
    WHERE @dateid = ord.[Order Date Key]
);
GO

DECLARE @MaxDate AS DATE =
        (
            SELECT MAX([Order Date Key])FROM Fact.[Order]
        );

SELECT *
FROM Fact.DescOrder(@MaxDate)
ORDER BY [Unit Price] DESC;

--Proposition 18
--Count of Orders and Sum of transaction total by year
--Complex

USE WideWorldImporters;

DROP VIEW IF EXISTS Sales.InvoiceDetail;
GO
CREATE VIEW Sales.InvoiceDetail
AS
SELECT inv.InvoiceID,
       ct.AmountExcludingTax,
       ct.TransactionDate,
       cust.CustomerID,
       cust.OrderID,
       cust.OrderDate,
       cust.ExpectedDeliveryDate,
       inv.DeliveryInstructions
FROM Sales.Invoices AS inv
    INNER JOIN
    (
        SELECT InvoiceID,
               AmountExcludingTax,
               TransactionDate
        FROM Sales.CustomerTransactions
    ) AS ct
        ON ct.InvoiceID = inv.InvoiceID
    INNER JOIN
    (
        SELECT CustomerID,
               OrderID,
               OrderDate,
               ExpectedDeliveryDate
        FROM Sales.Orders
    ) AS cust
        ON cust.CustomerID = inv.CustomerID;
GO


WITH byyear
AS (SELECT YEAR(OrderDate) AS orderyear,
           OrderID,
           AmountExcludingTax
    FROM Sales.InvoiceDetail),
     summed
AS (SELECT orderyear,
           SUM(AmountExcludingTax) AS sumSales,
           COUNT(DISTINCT OrderID) AS countOrder
    FROM byyear
    GROUP BY orderyear)
SELECT *
FROM summed
ORDER BY orderyear;

--Proposition 19
--Products ordered by total amount of scrapped, with count of different reasons for scrapping
--Complex

USE AdventureWorks2017;

DROP VIEW IF EXISTS Production.Scrapping;
GO
CREATE VIEW Production.Scrapping
AS
SELECT prod.*,
       work.WorkOrderID,
       work.ScrappedQty,
       work.OrderQty,
       work.StockedQty,
       CAST(work.EndDate AS DATE) AS EndDay,
       scrap.*
FROM Production.WorkOrder AS work
    LEFT OUTER JOIN
    (
        SELECT ScrapReasonID,
               [Name] AS ScrapReason
        FROM Production.ScrapReason
    ) AS scrap
        ON scrap.ScrapReasonID = work.ScrapReasonID
    INNER JOIN
    (SELECT ProductID, [Name] AS ProductName FROM Production.Product) AS prod
        ON prod.ProductID = work.ProductID;
GO

WITH scrapped
AS (SELECT *
    FROM Production.Scrapping
    WHERE ScrapReason IS NOT NULL)
SELECT ProductID,
       ProductName,
       SUM(ScrappedQty) AS TotalScrap,
       COUNT(DISTINCT ScrapReasonID) AS ScrapReasons
FROM scrapped
GROUP BY ProductID,
         ProductName
ORDER BY TotalScrap DESC;

--Proposition 20
--All orders from Sven (Employee) and the shipper to contact
--Complex
USE Northwinds2020TSQLV6;

DROP VIEW IF EXISTS dbo.Employee;
GO
CREATE VIEW dbo.Employee
AS
SELECT EmployeeFirstName + ' ' + EmployeeLastName AS Employee,
       EmployeeId
FROM HumanResources.Employee;
GO

DROP FUNCTION IF EXISTS dbo.EmployeeOrders;
GO
CREATE FUNCTION dbo.EmployeeOrders
(
    @eid AS INT
)
RETURNS TABLE
AS
RETURN SELECT od.EmployeeId,
              HR.Employee,
              od.OrderId,
              od.OrderDate,
              od.Freight,
              od.ShipperId
       FROM Sales.[Order] AS od
           INNER JOIN dbo.Employee AS HR
               ON od.EmployeeId = HR.EmployeeId
       WHERE od.EmployeeId = @eid;
GO

SELECT sven.*,
       sp.ShipperCompanyName,
       sp.PhoneNumber
FROM dbo.EmployeeOrders(5) AS sven
    INNER JOIN Sales.Shipper AS sp
        ON sven.ShipperId = sp.ShipperId
ORDER BY OrderDate;