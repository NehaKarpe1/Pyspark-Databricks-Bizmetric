USE AdventureWorks2022;

--1) find the average currency rate conversion from USD to Algerian Dinar  and Australian Doller  
SELECT FromCurrencyCode,ToCurrencyCode,AVG(AverageRate) FROM Sales.CurrencyRate
WHERE FromCurrencyCode='USD' AND ToCurrencyCode IN ('AUD' ,'DZD')
GROUP BY FromCurrencyCode,ToCurrencyCode
--ANS USD TO AUD 1.8239

--2) Find the products having offer on it and display product name , safety Stock Level, Listprice,  and product model id, type of discount, 
--   percentage of discount,  offer start date and offer end date 

SELECT * FROM Production.Product  --p id,P NAME,safety stock table,list price,product model id
SELECT * FROM Sales.SpecialOfferProduct --p id  
SELECT * FROM Production.ProductModel
SELECT * FROM Sales.SpecialOffer--ST DATE,END DATE,TYPE OF DISCOUNT,DISCOUNT PCT

SELECT P.ProductID,P.Name,P.SafetyStockLevel,P.ListPrice,P.ProductModelID,SO.Type,SO.DISCOUNTPCT,SO.StartDate,SO.EndDate
FROM Production.Product P,Sales.SpecialOfferProduct SP,Sales.SpecialOffer SO
WHERE P.ProductID=SP.ProductID AND SO.SpecialOfferID=SP.SpecialOfferID
--ANS 538 ROWS 

--3) create  view to display Product name and Product review 

--4) find out the vendor for product   paint, Adjustable Race and blade
SELECT * FROM Production.Product  --PID,P NAME
SELECT * FROM Purchasing.Vendor --BID,NAME 
SELECT * FROM Purchasing.ProductVendor--BID


SELECT * 
FROM Purchasing.Vendor V, Purchasing.ProductVendor PV
WHERE V.BusinessEntityID=PV.BusinessEntityID  AND 
ProductID IN (SELECT ProductID FROM  Production.Product WHERE NAME LIKE '%Paint%' OR NAME LIKE '%Adjustable Race%' OR NAME LIKE '%blade%')
--NS 11 ROWS

--5) find product details shipped through ZY - EXPRESS 
SELECT * FROM Production.Product --PRODUCT ID,P NAME
SELECT * FROM Purchasing.ShipMethod--SHIPMETHOD ID,NAME
SELECT * FROM Sales.SalesOrderHeader --SALESORDERID,SHIP METHOD ID
SELECT * FROM Sales.SalesOrderDetail
SELECT * FROM Purchasing.PurchaseOrderDetail--PURCHASEORDERID,PRODUCT ID
select * from Purchasing.PurchaseOrderHeader--purchaseorderid,shiomethodid

SELECT * 
FROM Purchasing.ShipMethod SP,Purchasing.PurchaseOrderHeader PO ,Purchasing.PurchaseOrderDetail SOD
WHERE PO.ShipMethodID=SP.ShipMethodID AND SOD.PurchaseOrderID=PO.PurchaseOrderID AND NAME='ZY - EXPRESS'


SELECT * 
FROM Production.Product
WHERE  ProductID IN (SELECT ProductID
FROM Purchasing.ShipMethod SP,Purchasing.PurchaseOrderHeader PO ,Purchasing.PurchaseOrderDetail SOD
WHERE PO.ShipMethodID=SP.ShipMethodID AND SOD.PurchaseOrderID=PO.PurchaseOrderID  AND NAME='ZY - EXPRESS') 


-- 6)find the tax amt for products where order date and ship date are on the same day 

SELECT * FROM Sales.SalesOrderHeader

SELECT PO.OrderDate,SO.ShipDate
FROM Sales.SalesOrderHeader SO,Purchasing.PurchaseOrderHeader PO
WHERE DAY(PO.OrderDate)=DAY(SO.ShipDate)


SELECT * 
FROM Purchasing.PurchaseOrderHeader
WHERE OrderDate=ShipDate

--7)find the average days required to ship the product based on shipment type.

--8) find the name of employees working in day shift 
SELECT * FROM HumanResources.EmployeeDepartmentHistory
SELECT * FROM HumanResources.Shift

SELECT FirstName,LastName FROM Person.Person 
WHERE BusinessEntityID IN 
(SELECT BusinessEntityID FROM HumanResources.EmployeeDepartmentHistory
WHERE ShiftID =(SELECT ShiftID FROM HumanResources.Shift WHERE NAME='DAY'))
--ANS 176 ROWS 

--9) based on product and product cost history find the name , service provider time and average Standardcost   

SELECT * FROM Production.Product

SELECT * FROM Production.ProductCostHistory 

SELECT pc.ProductID,name,AVG(PC.StandardCost) as avg_std_cost
FROM Production.Product P,Production.ProductCostHistory PC
WHERE P.ProductID=PC.ProductID
GROUP BY PC.ProductID,Name
--ANS 293 ROWS

-- 10)find products with average cost more than 500 
SELECT * FROM Production.ProductCostHistory 

SELECT NAME,ProductID
FROM Production.Product
WHERE ProductID IN(
SELECT ProductID
FROM Production.ProductCostHistory PC
GROUP  BY ProductID 
HAVING AVG(StandardCost)>500
)  
--ANS 84 ROWS

--11) find the employee who worked in multiple territory 
SELECT * FROM Sales.SalesTerritory
SELECT * FROM Sales.SalesTerritoryHistory

SELECT * FROM HumanResources.Employee
WHERE BusinessEntityID IN(
SELECT BusinessEntityID
FROM Sales.SalesTerritoryHistory
GROUP BY BusinessEntityID
HAVING COUNT(DISTINCT TerritoryID)>1)

--12) find out the Product model name,  product description for culture as Arabic 

SELECT * FROM Production.ProductModel--PID,NAME
 --CID,CNAME
SELECT * FROM Production.ProductDescription--PDESCID,DESC
SELECT * FROM Production.ProductModelProductDescriptionCulture--Productmodelid,pdescid,cid

SELECT (SELECT Name FROM Production.ProductModel pm WHERE PM.ProductModelID=PDC.ProductModelID) AS P_NAME,
(SELECT Description FROM Production.ProductDescription pd WHERE PD.ProductDescriptionID=PDC.ProductDescriptionID) AS P_DESCRIPTION
FROM Production.ProductModelProductDescriptionCulture PDC  
WHERE CultureID=(SELECT CultureID FROM Production.Culture WHERE NAME='Arabic')


SELECT (SELECT Name FROM Production.ProductModel pm WHERE PM.ProductModelID=PDC.ProductModelID) AS P_NAME,
(SELECT Description FROM Production.ProductDescription pd WHERE PD.ProductDescriptionID=PDC.ProductDescriptionID) AS P_DESCRIPTION,
(SELECT CultureID FROM Production.Culture C WHERE C.CultureID=PDC.CultureID)
FROM Production.ProductModelProductDescriptionCulture PDC  
WHERE CultureID=(SELECT CultureID FROM Production.Culture WHERE NAME='Arabic')