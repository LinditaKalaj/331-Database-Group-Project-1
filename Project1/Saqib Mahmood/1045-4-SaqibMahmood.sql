--*(Worst) Simple: Show me the BusinessEntityID of people living in Ballard

USE AdventureWorks2017;

SELECT City,
       BusinessEntityID
FROM Person.Address
    INNER JOIN Person.BusinessEntityAddress
        ON Address.AddressID = BusinessEntityAddress.AddressID
WHERE City = 'Ballard'
ORDER BY City;

---------------------------------------------------------------------------------------------

--Simple: Show me transactions over $10,000 after 2015's stock market crash

USE WideWorldImporters;

SELECT CustomerID,
       TransactionAmount,
       FinalizationDate
FROM Sales.CustomerTransactions
WHERE TransactionAmount > '10000'
      AND FinalizationDate > '2015-08-18'
ORDER BY CustomerID;
-----------------------------------------------------------------------------------------------

--*(improved)Simple: Show me the name of the products with the most quantity

USE AdventureWorks2017;

SELECT TOP 10
       Name,
       Quantity
FROM Production.Product
    INNER JOIN Production.ProductInventory
        ON Product.ProductID = ProductInventory.ProductID
ORDER BY Quantity DESC;
--------------------------------------------------------------------------------------------------

--*(Best)Simple: Show me which Cities employee #6 has packed for

USE Northwinds2020TSQLV6;

SELECT EmployeeId,
       CustomerCity
FROM Sales.[Order]
    INNER JOIN Sales.Customer
        ON [Order].CustomerId = Customer.CustomerID
WHERE EmployeeId = 6
ORDER BY CustomerCity;
------------------------------------------------------------------------------------------------

--Simple: Show me how many products have been sold for over $1000

USE AdventureWorks2017;

SELECT DISTINCT
       COUNT(1)
FROM Sales.SalesOrderDetail
    INNER JOIN Production.Product
        ON SalesOrderDetail.ProductID = Product.ProductID
WHERE Product.ListPrice > 1000;

--------------------------------------------------------------------------------------------------

--* (Worst) Medium: Show me Full Name of customers who's credit cards expire after Feburary 2007

USE AdventureWorks2017;

SELECT FirstName,
       LastName,
       ExpMonth,
       ExpYear
FROM Person.[Person]
    INNER JOIN(Sales.PersonCreditCard
    INNER JOIN Sales.CreditCard
        ON CreditCard.CreditCardID = PersonCreditCard.CreditCardID)
        ON PersonCreditCard.BusinessEntityID = Person.BusinessEntityID
WHERE ExpMonth > '2'
      AND ExpYear >= '2007'
ORDER BY ExpYear,
         ExpMonth;

----------------------------------------------------------------------------------------------------

--*(Improved) Medium: Show me the largest to smallest orders along with the weight of the order

USE AdventureWorks2017;

SELECT PersonID,
       SubTotal,
       a.total_weight
FROM Sales.SalesOrderHeader
    JOIN Sales.Customer
        ON SalesOrderHeader.CustomerID = Customer.CustomerID
    JOIN
    (
        SELECT SalesOrderDetail.SalesOrderID,
               SUM(Product.Weight * SalesOrderDetail.OrderQty) AS total_weight
        FROM Production.Product
            JOIN Sales.SalesOrderDetail
                ON Product.ProductID = SalesOrderDetail.ProductID
        GROUP BY SalesOrderID
    ) AS a
        ON SalesOrderHeader.SalesOrderID = a.SalesOrderID
ORDER BY SalesOrderHeader.SubTotal DESC;

-------------------------------------------------------------------------------------------------------

--*(Best) Medium: Show me the total order amount and amunt spent from January 1 2012 to January 1 2013

USE AdventureWorks2017;

WITH OrderDetail (OrderID, OrderDetailQty, OrderDetailAmt)
AS (SELECT PurchaseOrderID,
           OrderQty,
           LineTotal
    FROM Purchasing.PurchaseOrderDetail),
     Orders (OrderID, OrderDate)
AS (SELECT PurchaseOrderID,
           OrderDate
    FROM Purchasing.PurchaseOrderHeader h
    WHERE OrderDate > '2012 - 1- 1'
          AND OrderDate < '2013 - 1 - 1')
SELECT o.OrderDate,
       SUM(od.OrderDetailQty) AS TotalOrderQty,
       SUM(od.OrderDetailAmt) AS TotalOrderAmt
FROM Orders o
    INNER JOIN OrderDetail od
        ON o.OrderID = od.OrderID
GROUP BY o.OrderDate
ORDER BY o.OrderDate;

-----------------------------------------------------------------------------------------------------------------
--Medium: Show me when the customer's Credit cards expire
USE AdventureWorks2017;

SELECT FirstName,
       LastName,
       ExpMonth,
       ExpYear
FROM Person.[Person]
    INNER JOIN(Sales.PersonCreditCard
    INNER JOIN Sales.CreditCard
        ON CreditCard.CreditCardID = PersonCreditCard.CreditCardID)
        ON PersonCreditCard.BusinessEntityID = Person.BusinessEntityID
ORDER BY ExpYear,
         ExpMonth;
-----------------------------------------------------------------------------------------------------------------

--Medium: Show me total from each order number

USE AdventureWorks2017;

SELECT so.SalesOrderID,
       sh.SubTotal,
       SUM(so.OrderQty * so.UnitPrice),
       SUM(so.OrderQty * Product.ListPrice)
FROM Sales.SalesOrderHeader AS sh
    JOIN Sales.SalesOrderDetail AS so
        ON sh.SalesOrderID = so.SalesOrderID
    JOIN Production.Product
        ON so.ProductID = Product.ProductID
GROUP BY so.SalesOrderID,
         sh.SubTotal
ORDER BY SubTotal DESC;
--------------------------------------------------------------------------------------------------------------------
--Medium: Show me the prodcut description for culture en

USE AdventureWorks2017;

SELECT Product.ProductID,
       ProductDescription.Description
FROM Production.ProductDescription
    JOIN Production.ProductModelProductDescriptionCulture
        ON ProductDescription.ProductDescriptionID = ProductModelProductDescriptionCulture.ProductDescriptionID
    JOIN Production.ProductModel
        ON ProductModelProductDescriptionCulture.ProductModelID = ProductModel.ProductModelID
    JOIN Production.Product
        ON ProductModel.ProductModelID = Product.ProductModelID
WHERE CultureID = 'en';
---------------------------------------------------------------------------------------------------------------------
-- Medium: Show me which customer paid the most taxes in purchases

USE WideWorldImporters;

SELECT CustomerID,
       TaxAmount
FROM Sales.InvoiceLines AS il
    INNER JOIN Sales.Invoices AS i
        ON il.InvoiceID = i.InvoiceID
ORDER BY TaxAmount DESC;
----------------------------------------------------------------------------------------------------------------------

--*(Worst) Complex: Show me which customers ordered a Front Derailleur for their bikes

USE AdventureWorks2017;

SELECT Product.ProductModelID,
       Product.Name,
       Customer.PersonID,
       SalesOrderDetail.OrderQty
FROM Production.Product
    JOIN Sales.SalesOrderDetail
        ON Product.ProductID = SalesOrderDetail.ProductID
    JOIN Sales.SalesOrderHeader
        ON SalesOrderDetail.SalesOrderID = SalesOrderHeader.SalesOrderID
    JOIN Sales.Customer
        ON SalesOrderHeader.CustomerID = Customer.CustomerID
WHERE Product.ProductModelID =
(
    SELECT ProductModelID
    FROM Production.ProductModel
    WHERE Name = 'Front Derailleur'
)
ORDER BY OrderQty DESC;

-------------------------------------------------------------------------------------------------------------------------------
-- Complex: Show me the running totals for the employees for each year

USE TSQLV4;

DROP VIEW IF EXISTS Sales.VEmpOrders;
GO
CREATE VIEW Sales.VEmpOrders
AS
SELECT empid,
       YEAR(orderdate) AS year,
       SUM(qty) AS qty
FROM Sales.Orders
    INNER JOIN Sales.OrderDetails
        ON Orders.orderid = Orderdetails.orderid
GROUP BY YEAR(orderdate),
         empid;
GO

SELECT empid,
       year,
       qty,
       (
           SELECT SUM(qty)
           FROM Sales.VEmpOrders
           WHERE Sales.VEmpOrders.empid = VEmpOrders.empid
                 AND Sales.VEmpOrders.year <= VEmpOrders.year
       ) AS runqty
FROM Sales.VEmpOrders
ORDER BY year,
         empid;

-------------------------------------------------------------------------------------------------------------------------

--*(Improved)Complex: Show customer 30, see if they belong to the US region and show which employee helped.

USE Northwinds2020TSQLV6;

DROP FUNCTION IF EXISTS Sales.custwho;
GO
CREATE FUNCTION Sales.custwho
(
    @custid AS INT
)
RETURNS TABLE
AS
RETURN SELECT CustomerId,
              OrderId,
              EmployeeId,
              ShipToCountry
       FROM Sales.[Order]
       WHERE @custid = CustomerId;
GO

DROP VIEW IF EXISTS Sales.country;
GO
CREATE VIEW Sales.country
AS
SELECT ShipToCountry
FROM Sales.[Order]
WHERE ShipToCountry = 'USA';

GO

;WITH EMP
 AS (SELECT EmployeeId
     FROM HumanResources.Employee)
SELECT DISTINCT
       c.CustomerId,
       EMP.EmployeeId
FROM Sales.custwho(65) AS c
    LEFT OUTER JOIN EMP AS EMP
        ON EMP.EmployeeId = c.employeeid
    INNER JOIN Sales.country AS r
        ON c.ShipToCountry = r.ShipToCountry;

-------------------------------------------------------------------------------------------------------------------------

--Complex: find out which vendor ordered more than 1000 and give the name of the shopping method
USE AdventureWorks2017;


DROP FUNCTION IF EXISTS whoOrderqty;
GO
CREATE FUNCTION whoOrderqty
(
    @qty AS INT
)
RETURNS TABLE
AS
RETURN SELECT ProductID,
              OrderQty,
              PurchaseOrderID
       FROM Purchasing.PurchaseOrderDetail
       WHERE OrderQty > @qty;
GO

SELECT poh.PurchaseOrderID,
       poh.VendorID,
       sm.Name
FROM Purchasing.PurchaseOrderHeader AS poh
    INNER JOIN dbo.whoOrderqty(1000) AS w
        ON w.PurchaseOrderID = poh.PurchaseOrderID
    INNER JOIN Purchasing.ShipMethod AS sm
        ON sm.ShipMethodID = poh.ShipMethodID;

-----------------------------------------------------------------------------------------------------------------------------

--Complex: find all the employees who sold chocolate in april 2016
USE WideWorldImportersDW;

WITH chocolate042016
AS (SELECT [Salesperson Key]
    FROM Fact.Sale
    WHERE Description LIKE '%chocolate%'
          AND EXISTS
    (
        SELECT [Invoice Date Key]
        FROM Fact.Sale
        WHERE YEAR([Invoice Date Key]) = '2016'
              AND MONTH([Invoice Date Key]) = '04'
    ))
SELECT e.[Preferred Name]
FROM chocolate042016
    INNER JOIN Dimension.Employee AS e
        ON e.[Employee Key] = chocolate042016.[Salesperson Key]
GROUP BY e.[Preferred Name];

----------------------------------------------------------------------------------------------------------------------------------------

--(Best)Complex: find who ordered the shark slippers, get the customer and their phone number. Only get customers who arent buisnesses 
USE WideWorldImporters;

WITH sharkslipper
AS (SELECT Description,
           StockItemID,
           OrderID
    FROM Sales.OrderLines
    WHERE Description LIKE '%shark slippers%')
SELECT DISTINCT
       c.CustomerID,
       c.CustomerName,
       c.PhoneNumber
FROM Sales.Orders AS o
    INNER JOIN sharkslipper AS s
        ON s.OrderID = o.OrderID
    INNER JOIN Sales.Customers AS c
        ON c.CustomerID = o.CustomerID
WHERE c.BuyingGroupID IS NULL
ORDER BY c.CustomerID;

----------------------------------------------------------------------------------------------------------------------------------------------------



