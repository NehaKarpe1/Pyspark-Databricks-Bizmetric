USE AdventureWorks2022;
--DDL
/*1.	Create a customer table having following column with suitable data type
Cust_id  (automatically incremented primary key)
Customer name (only characters must be there)
Aadhar card (unique per customer)
Mobile number (unique per customer)
Date of birth (check if the customer is having age more than15)
Address
Address type code (B- business, H- HOME, O-office and should not accept any other)
State code ( MH – Maharashtra, KA for Karnataka)*/
create database questionBank; 
use questionBank;
create schema ddl;

create table ddl.customer(
cust_id int identity(1,1) primary key,
customerName  varchar(20) not null check(customerName not like '%[^A-za-z]%') ,
AadharCard varchar(10) unique,
mobileNumber varchar(10) unique,
dob datetime not null check(datediff(year,dob,getdate())>15) ,
Address varchar(150),
AddressType char(1) not null check(AddressType in ('B', 'H', 'O')) ,
StateCode varchar(2) not null check(StateCode in ('MH', 'KA' )) 
);


/*Create another table for Address type which is having
Address type code must accept only (B,H,O)
Address type  having the information as  (B- business, H- HOME, O-office)*/


create table ddl.addressType(
AddressType char(1) not null check(AddressType in ('B', 'H', 'O')) ,
AddressInfo varchar(20) not null
);

insert into ddl.addressType values('B','Business');
insert into ddl.addressType values('H','Home');
insert into ddl.addressType values('O','Office');

select * from ddl.addressType;

/*Create table state_info having columns as  
State_id  primary unique
State name 
Country_code char(2)*/

create table ddl.state_info(
StateCode varchar(2) primary key, 
stateName varchar(20),
countryCode varchar(2)
);

-- as the referenced colum must be a primary key - 
ALTER TABLE ddl.addressType
ADD CONSTRAINT pk_addressType 
PRIMARY KEY (AddressType);

--Alter tables to link all tables based on suitable columns and foreign keys.
ALTER TABLE ddl.customer
ADD CONSTRAINT fk_customer_addressType
FOREIGN KEY (AddressType) REFERENCES ddl.addressType(AddressType);

alter table ddl.customer
add constraint fk_customer_state_id
foreign key (StateCode) references ddl.state_info(StateCode)

--Change the column name from customer table customer name as c_name
SELECT 
    CONSTRAINT_NAME,
    CONSTRAINT_TYPE,
    TABLE_NAME
FROM 
    INFORMATION_SCHEMA.TABLE_CONSTRAINTS where TABLE_NAME='customer';

SELECT 
    OBJECT_NAME(c.object_id) AS TableName,
    c.name AS ConstraintName,
    c.definition
FROM sys.check_constraints c
JOIN sys.columns col ON c.parent_object_id = col.object_id AND c.definition LIKE '%customerName%'
WHERE col.name = 'customerName' AND OBJECT_NAME(col.object_id) = 'customer';

ALTER TABLE ddl.customer DROP CONSTRAINT CK__customer__custom__398D8EEE;
EXEC sp_rename 'ddl.customer.customerName', 'c_name', 'COLUMN';  

ALTER TABLE ddl.customer
ADD CONSTRAINT CK_customer_c_name CHECK (c_name NOT LIKE '%[^A-Za-z]%');


--Insert the suitable records into the respective tables

INSERT INTO ddl.state_info (StateCode, stateName, countryCode) VALUES
('MH', 'Maharashtra', 'IN'),
('KA', 'Karnataka', 'IN'),
('GJ', 'Gujarat', 'IN'),
('DL', 'Delhi', 'IN');


INSERT INTO ddl.customer  VALUES
('neha', '1234567890', '9876543210', '2000-05-15', '123, MG Road, Pune', 'H', 'MH'),
('prachi', '2234567891', '8876543211', '1995-08-20', '456, Brigade Road, Bangalore', 'O', 'KA'),
('reva', '3234567892', '7876543212', '1990-12-10', '789, FC Road, Pune', 'B', 'MH'),
('suraj', '4234567893', '6876543213', '1997-03-25', '101, JP Nagar, Bangalore', 'H', 'KA');

--Change the data type of  country_code to varchar(3)

ALTER TABLE ddl.state_info
ALTER COLUMN countryCode VARCHAR(3);

--1) find the average currency rate conversion from USD to Algerian Dinar  and Australian Doller  
select * from Sales.CurrencyRate 
WHERE FromCurrencyCode='USD' AND ToCurrencyCode IN ('AUD' ,'DZD')
SELECT FromCurrencyCode,ToCurrencyCode,AVG(AverageRate) FROM Sales.CurrencyRate
WHERE FromCurrencyCode='USD' AND ToCurrencyCode IN ('AUD' ,'DZD')
GROUP BY FromCurrencyCode,ToCurrencyCode
--ANS USD TO AUD 1.8239

--2) Find the products having offer on it and display product name , safety Stock Level, Listprice,  
--and product model id, type of discount, 
--percentage of discount,  offer start date and offer end date   

SELECT * FROM Production.Product  --p id,P NAME,safety stock table,list price,product model id
SELECT * FROM Sales.SpecialOfferProduct --p id ,SID 
SELECT * FROM Sales.SpecialOffer--ST DATE,END DATE,TYPE OF DISCOUNT,DISCOUNT PCT

SELECT P.ProductID,P.Name,P.SafetyStockLevel,P.ListPrice,P.ProductModelID,SO.Type,SO.DISCOUNTPCT,SO.StartDate,SO.EndDate
FROM Production.Product P,Sales.SpecialOfferProduct SP,Sales.SpecialOffer SO
WHERE P.ProductID=SP.ProductID AND SO.SpecialOfferID=SP.SpecialOfferID
--ANS 538 ROWS 

--3) create  view to display Product name and Product review 
CREATE VIEW  PVIEW AS SELECT P.NAME,PR.Comments FROM Production.ProductReview PR,Production.Product P 
 WHERE P.ProductID=PR.ProductID
 SELECT * FROM PVIEW
--4) find out the vendor for product   paint, Adjustable Race and blade
SELECT * FROM Production.Product  --PID,P NAME
SELECT * FROM Purchasing.Vendor --BID,NAME 
SELECT * FROM Purchasing.ProductVendor--BID,pid 

select * from Production.Product p ,Purchasing.Vendor v , Purchasing.ProductVendor pv where pv.ProductID=p.ProductID and v.BusinessEntityID=pv.BusinessEntityID
select * from Production.Product p join Purchasing.ProductVendor pv on  pv.ProductID=p.productid 
join Purchasing.Vendor v on v.BusinessEntityID=pv.BusinessEntityID  

SELECT pv.BusinessEntityID,Name,(SELECT name FROM Production.Product p where p.ProductID=pv.ProductID) as prductname
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

SELECT PO.OrderDate,SO.ShipDate,so.TaxAmt
FROM Sales.SalesOrderHeader SO,Purchasing.PurchaseOrderHeader PO
WHERE DAY(PO.OrderDate)=DAY(SO.ShipDate)


SELECT * 
FROM Purchasing.PurchaseOrderHeader
WHERE OrderDate=ShipDate

--7)find the average days required to ship the product based on shipment type.
USE AdventureWorks2022
SELECT * FROM PURCHASING.SHIPMETHOD
SELECT * FROM Sales.SalesOrderHeader where ShipMethodID in (2,3,4)

SELECT ShipMethodID,AVG(T.DD) FROM (
SELECT ShipMethodID,DATEDIFF(DAY,OrderDate,ShipDate) AS DD
FROM Sales.SalesOrderHeader) AS T
GROUP BY ShipMethodID  

SELECT ShipMethodID,AVG(T.DD) FROM (
SELECT ShipMethodID,DATEDIFF(DAY,OrderDate,ShipDate) AS DD
FROM Purchasing.PurchaseOrderHeader) AS T
GROUP BY ShipMethodID  


select * from  Purchasing.PurchaseOrderHeader p ,Purchasing.ShipMethod s where s.ShipMethodID=p.ShipMethodID
select * from  sales.SalesOrderHeader p ,Purchasing.ShipMethod s where s.ShipMethodID=p.ShipMethodID



--8) find the name of employees working in day shift 
SELECT * FROM Person.Person
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

--13)--find the 1st 20 emps who joined very early in the company 

select   top 20 * from HumanResources.Employee
order by HireDate
--STAR 
--14) find most trending product based on sales and purchase 

select ProductID,count(*)  as s_count from Sales.SalesOrderDetail
group by ProductID
order by s_count desc

select ProductID,count(*) as s_count
from Purchasing.PurchaseOrderDetail
group by ProductID
order by s_count desc 


--15)display EMP name, territory name, saleslastyear salesquota and bonus
SELECT * FROM Sales.SalesOrderDetail
USE AdventureWorks2022
--16)display EMP name, territory name, saleslastyear salesquota and bonus from Germany and United Kingdom

SELECT * FROM Person.Person --BID,NAME
SELECT * FROM Sales.SalesPerson--BID,TID,SALES QUOTA,SALES LAST YR ,BONUS 
SELECT * FROM Sales.SalesTerritoryHistory
SELECT * FROM Sales.SalesTerritory--TID,T NAME
SELECT * FROM Sales.SalesOrderHeader--TERRITORY ID,SALES PERSON ID,SALED O ID

SELECT P.FirstName,ST.Name,SP.SalesLastYear,SP.SalesQuota,SP.Bonus
FROM Person.Person P,Sales.SalesPerson SP,Sales.SalesTerritory ST
WHERE ST.TerritoryID=SP.TerritoryID AND SP.BusinessEntityID=P.BusinessEntityID 
AND ST.[Name] IN ('GERMANY','UNITED KINGDOM')



--17)Find all employees who worked in all North America territory
--18)find all products in the cart
--19)find all the products with special offer 
--20)20. find all employees name , job title, card details whose credit card expired 
--in the month 11 and year as 2008

--21)  Find the employee whose payment might be revised  (Hint : Employee payment history) 

SELECT * FROM HumanResources.EmployeePayHistory  

SELECT BUSINESSENTITYID,COUNT(*)
FROM HumanResources.EmployeePayHistory
GROUP BY BusinessEntityID
HAVING COUNT(*)>1

--EMPS WHOSE SALARY IS NOT REVISED EVEN ONCE

SELECT * 
FROM  HumanResources.Employee 
WHERE BusinessEntityID NOT IN 
(SELECT BusinessEntityID 
FROM HumanResources.EmployeePayHistory
)

--EMPS WHOSE SALARY IS NOT REVISED ONLY ONCE

SELECT * 
FROM  HumanResources.Employee 
WHERE BusinessEntityID NOT IN 
(SELECT BusinessEntityID 
FROM HumanResources.EmployeePayHistory
GROUP BY BusinessEntityID
HAVING COUNT(*)>1
)

--22)Find total standard cost for the active Product. (Product cost history)
SELECT  ProductID,SUM(STANDARDCOST) AS SUM_STD_COST FROM Production.Product
WHERE SellEndDate IS NULL OR SellEndDate>GETDATE()
GROUP BY ProductID

--23)Find the personal details with address and address type(hint: Business Entiry Address , Address, Address type) 


SELECT * FROM Person.Person
SELECT DISTINCT BusinessEntityID  FROM Person.Person--BID
SELECT * FROM Person.BusinessEntityAddress -- BID,ADDRESSID,ADDRESTYPEID
SELECT * FROM Person.Address -- ADDRESSID,ADDRESSLINE 1,ADRESS LINE 2 
SELECT * FROM Person.AddressType--ADRESSTYPE ID,NAME

 

SELECT (SELECT BusinessEntityID FROM Person.Person P WHERE P.BusinessEntityID=BEA.BusinessEntityID) AS BID,
(SELECT CONCAT(FirstName,LastName) FROM Person.Person P WHERE P.BusinessEntityID=BEA.BusinessEntityID) AS FULLNAME,
(SELECT CONCAT(AddressID,ADDRESSLINE1) FROM Person.Address A WHERE A.AddressID=BEA.AddressID) AS ADRESSIDLINE1,
(SELECT AddressTypeID FROM Person.AddressTYPE AT WHERE AT.AddressTypeID=BEA.AddressTypeID) AS ADRESSTYPEID,
(SELECT NAME FROM Person.AddressTYPE AT WHERE AT.AddressTypeID=BEA.AddressTypeID) AS ADRESSNAME
FROM Person.BusinessEntityAddress BEA 

SELECT P.FirstName,P.LastName,P.BusinessEntityID,A.AddressLine1,A.AddressLine2,AT.AddressTypeID,AT.Name
FROM Person.BusinessEntityAddress BEA ,
Person.Person P,Person.Address A,Person.AddressTYPE AT
WHERE P.BusinessEntityID=BEA.BusinessEntityID AND
AT.AddressTypeID=BEA.AddressTypeID AND
A.AddressID=BEA.AddressID

--24)Find the name of employees working in group of North America territory
SELECT * FROM Sales.SalesTerritory--TERRITORYID,TERRITORY NAME,NAME,COUNTRYRGNCODE,GROUP
SELECT * FROM SALES.SalesTerritoryHistory-----BID,TERRITIRYID
SELECT * FROM HumanResources.Employee--BID
SELECT * FROM Person.Person--BID,NAME 

SELECT P.*
FROM Person.Person P
WHERE BusinessEntityID IN (SELECT BusinessEntityID FROM Sales.SalesTerritoryHistory STH WHERE STH.TerritoryID IN 
(SELECT TerritoryID FROM Sales.SalesTerritory ST  WHERE ST.[Group]='North America'))
ORDER BY BusinessEntityID

SELECT *
FROM  SALES.SalesTerritoryHistory STH,Sales.SalesTerritory ST,Person.Person P,HumanResources.Employee E
WHERE P.BusinessEntityID=E.BusinessEntityID 
AND ST.TerritoryID=STH.TerritoryID
AND sth.BusinessEntityID=E.BusinessEntityID 
AND ST.[Group]='North America'
--NOW THIS GIVES DUPLICATE FOR BID 275 CAUSE IT WORKS IN NORTH AMERICA BUT IN THAT IT WORKS IN Northeast Central BOTH  THEREFORE USE DISTINCT 

SELECT DISTINCT P.BusinessEntityID,P.FirstName,P.LastName
FROM  SALES.SalesTerritoryHistory STH,Sales.SalesTerritory ST,Person.Person P,HumanResources.Employee E
WHERE P.BusinessEntityID=E.BusinessEntityID 
AND ST.TerritoryID=STH.TerritoryID
AND sth.BusinessEntityID=E.BusinessEntityID 
AND ST.[Group]='North America'

--25) Find the employee whose payment is revised for more than once
SELECT * FROM HumanResources.Employee
SELECT H.*
FROM HumanResources.Employee H WHERE H.BusinessEntityID IN (
SELECT BUSINESSENTITYID
FROM HumanResources.EmployeePayHistory
GROUP BY BusinessEntityID
HAVING COUNT(*)>1)



--26) display the personal details of  employee whose payment is revised for more than once. 
SELECT p.BusinessEntityID,p.FirstName,p.LastName 
FROM Person.Person P WHERE P.BusinessEntityID IN (
SELECT BUSINESSENTITYID
FROM HumanResources.EmployeePayHistory
GROUP BY BusinessEntityID
HAVING COUNT(*)>1)
--27)Which shelf is having maximum quantity (product inventory)
SELECT  TOP 1 SHELF,SUM(Quantity)  AS TOTAL_QTY FROM Production.ProductInventory
GROUP BY Shelf
ORDER BY TOTAL_QTY DESC

--28)Which shelf is using maximum bin(product inventory)
SELECT * FROM Production.ProductInventory
--STAR

--29)Which location is having minimum bin (product inventory)
SELECT * FROM Production.ProductInventory
GROUP BY ProductID
--30)Find out the product available in most of the locations (product inventory)
SELECT PRODUCTID,COUNT(DISTINCT LOCATIONID) AS L_COUNT
FROM Production.ProductInventory
GROUP BY ProductID
ORDER BY L_COUNT DESC

--31)Which sales order is having most order quantity.
SELECT SalesOrderID,SUM(ORDERQTY)  AS SOD FROM  Sales.SalesOrderDetail
GROUP BY SalesOrderID
ORDER BY SOD DESC


--32) find the duration of payment revision on every interval 
--(inline view) Output must be as given format 

SELECT BUSINESSENTITYID,DATEDIFF(DAY,T1.P2,T1.P1) FROM
(select BusinessEntityID,
CASE WHEN T.R=3 THEN RateChangeDate END AS P1,
T.P2
FROM (SELECT BusinessEntityID,RATECHANGEDATE,ROW_NUMBER() OVER (PARTITION BY BUSINESSENTITYID ORDER BY RATECHANGEDATE) as r,
LAG(RATECHANGEDATE,1) OVER (PARTITION BY BUSINESSENTITYID ORDER BY RATECHANGEDATE) as P2
FROM HumanResources.EmployeePayHistory ) as t
where t.r>1   AND T.P2 IS NOT NULL ) AS T1  
WHERE T1.P2 IS NOT NULL AND T1.P1 IS NOT NULL

SELECT P.FirstName,P.LastName,
 T1.BusinessEntityID,DATEDIFF(DAY,T1.P2,T1.P1) FROM
(select BusinessEntityID,
CASE WHEN T.R=3 THEN RateChangeDate END AS P1,
LAG(RATECHANGEDATE,1) OVER (PARTITION BY BUSINESSENTITYID ORDER BY RATECHANGEDATE) as P2
FROM (SELECT BusinessEntityID,RATECHANGEDATE,ROW_NUMBER() 
OVER (PARTITION BY BUSINESSENTITYID ORDER BY RATECHANGEDATE) as r
FROM HumanResources.EmployeePayHistory ) as t
where t.r>1  ) AS T1 ,Person.Person P  
WHERE  P.BusinessEntityID=T1.BusinessEntityID AND T1.P2 IS NOT NULL AND T1.P1 IS NOT NULL


SELECT P.FirstName,P.LastName,
 T1.BusinessEntityID ,DATEDIFF(MONTH,T1.P2,T1.P1)/12 AS YEAR , DATEDIFF(MONTH,T1.P2,T1.P1)%12  AS MONTH FROM
(select BusinessEntityID,    
CASE WHEN T.R=3 THEN RateChangeDate END AS P1,
LAG(RATECHANGEDATE,1) OVER (PARTITION BY BUSINESSENTITYID ORDER BY RATECHANGEDATE) as P2
FROM (SELECT BusinessEntityID,RATECHANGEDATE,ROW_NUMBER() 
OVER (PARTITION BY BUSINESSENTITYID ORDER BY RATECHANGEDATE) as r
FROM HumanResources.EmployeePayHistory ) as t
where t.r>1  ) AS T1 ,Person.Person P  
WHERE  P.BusinessEntityID=T1.BusinessEntityID AND T1.P2 IS NOT NULL AND T1.P1 IS NOT NULL


--FINAL ANSWER WITH DESIRES COL NAMES
SELECT T2.FIRSTNAME,T2.LASTNAME,T2.REVISEDTIME,CONCAT(T2.YEAR,' ','.',T2.MONTH,' YRS') AS DURATION 
FROM 
(SELECT T1.BusinessEntityID,P.FirstName,P.LastName,T1.r AS REVISEDTIME,
  DATEDIFF(MONTH,T1.P2,T1.P1)/12 AS YEAR , DATEDIFF(MONTH,T1.P2,T1.P1)%12  AS MONTH FROM
(select BusinessEntityID,  T.R ,
CASE WHEN T.R>1 THEN RateChangeDate END AS P1,
LAG(RATECHANGEDATE,1) OVER (PARTITION BY BUSINESSENTITYID ORDER BY RATECHANGEDATE) as P2
FROM (SELECT BusinessEntityID,RATECHANGEDATE,ROW_NUMBER() 
OVER (PARTITION BY BUSINESSENTITYID ORDER BY RATECHANGEDATE) as r 
FROM HumanResources.EmployeePayHistory  ) as t
 where t.r>1 ) AS T1 ,Person.Person P  
WHERE  P.BusinessEntityID=T1.BusinessEntityID AND T1.P2 IS NOT NULL AND T1.P1 IS NOT NULL ) AS T2







--33) check if any employee from jobcandidate table is having any payment revisions 
SELECT * FROM HumanResources.EmployeePayHistory
SELECT * FROM HumanResources.JobCandidate

SELECT *
FROM HumanResources.JobCandidate WHERE BusinessEntityID IN 
(SELECT BusinessEntityID 
FROM HumanResources.EmployeePayHistory
GROUP BY BusinessEntityID
HAVING COUNT(*) >0)


 
--34)check the department having more salary revision
 SELECT * FROM HumanResources.Department
 SELECT * FROM HumanResources.EmployeeDepartmentHistory 
 SELECT * FROM HumanResources.EmployeePayHistory

SELECT  *
FROM HumanResources.Department D,HumanResources.EmployeeDepartmentHistory EDH ,HumanResources.EmployeePayHistory EPH
WHERE D.DepartmentID=EDH.DepartmentID AND EPH.BusinessEntityID=EDH.BusinessEntityID


SELECT  d.Name,COUNT(*)
FROM HumanResources.Department D,HumanResources.EmployeeDepartmentHistory EDH ,HumanResources.EmployeePayHistory EPH
WHERE   EPH.BusinessEntityID=EDH.BusinessEntityID AND D.DepartmentID=EDH.DepartmentID
GROUP BY d.NAME 
ORDER BY COUNT(*) DESC 

--35) check the employee whose payment is not yet revised

SELECT *
FROM HumanResources.Employee 
WHERE BUSINESSEntityID NOT IN (SELECT BusinessEntityID FROM HumanResources.EmployeePayHistory)

--36) find the job title having more revised payments 
SELECT * FROM HumanResources.Employee 
SELECT * FROM HumanResources.EmployeePayHistory


SELECT * 
FROM HumanResources.Employee E,HumanResources.EmployeePayHistory EP
WHERE E.BusinessEntityID=EP.BusinessEntityID
GROUP BY e.JobTitle,e.BusinessEntityID


SELECT T.JOBTITLE,COUNT(T.R) FROM 
(SELECT e.jobtitle,e.BusinessEntityID,count(*) AS R 
FROM HumanResources.Employee E,HumanResources.EmployeePayHistory EP
WHERE E.BusinessEntityID=EP.BusinessEntityID
GROUP BY e.JobTitle,e.BusinessEntityID
HAVING count(*)>1
) AS T
GROUP BY T.JobTitle

--37) find the employee whose payment is revised in shortest duration (inline view) 

SELECT * FROM HumanResources.EmployeePayHistory   

SELECT T.BUSINESSENTITYID,RATECHANGEDATE,R,LAG(T.RateChangeDate) OVER (PARTITION BY T.BUSINESSENTITYID ORDER BY T.RATECHANGEDATE) AS AAA 
FROM 
(SELECT BusinessEntityID,RATECHANGEDATE,ROW_NUMBER() 
OVER (PARTITION BY BUSINESSENTITYID ORDER BY RATECHANGEDATE) as r 
FROM HumanResources.EmployeePayHistory ) AS T 

SELECT P.FIRSTNAME,P.LASTNAME ,
T.BUSINESSENTITYID,T.RATECHANGEDATE,DATEDIFF(MONTH,T.LLL,T.RATECHANGEDATE) AS MONTHS
FROM 
(SELECT BusinessEntityID,RATECHANGEDATE,ROW_NUMBER() 
OVER (PARTITION BY BUSINESSENTITYID ORDER BY RATECHANGEDATE) as r,
LAG(RateChangeDate) OVER (PARTITION BY BUSINESSENTITYID ORDER BY RATECHANGEDATE) AS LLL
FROM HumanResources.EmployeePayHistory ) AS T,Person.Person P
WHERE  P.BUSINESSENTITYID=T.BusinessEntityID AND T.LLL IS NOT NULL   
ORDER BY MONTHS
 





--38)find the colour wise count of the product (tbl: product)
SELECT * FROM Production.Product
where color is null

SELECT COLOR,COUNT(*) AS P_COUNT
FROM Production.Product
GROUP BY Color

--39) find out the product who are not in position to sell (hint: check the sell start and end date) 
SELECT * FROM Production.Product
SELECT *
FROM Production.Product
WHERE SellStartDate IS NOT NULL OR SellEndDate IS NOT NULL 
AND GETDATE()>SellEndDate

--40) find the class wise, style wise average standard cost 
select Class,Style,AVG(StandardCost) as avgstandardcost
from Production.Product
GROUP BY Class,Style
ORDER BY avgstandardcost DESC

select Class,Style,AVG(StandardCost) as avgstandardcost
from Production.Product
WHERE CLASS IS NOT NULL AND STYLE IS NOT NULL
GROUP BY Class,Style
ORDER BY avgstandardcost DESC

--41) check colour wise standard cost 
SELECT * FROM Production.Product

SELECT color,SUM(StandardCost) as totalstdcost
FROM Production.Product
GROUP BY Color

SELECT color,SUM(StandardCost) as totalstdcost
FROM Production.Product
WHERE COLOR IS NOT NULL
GROUP BY Color
ORDER BY totalstdcost



--42) find the product line wise standard cost 
SELECT * FROM Production.Product
SELECT ProductLine,SUM(StandardCost) as totalstdcost
FROM Production.Product
GROUP BY ProductLine

SELECT ProductLine,SUM(StandardCost) as totalstdcost
FROM Production.Product
WHERE ProductLine IS NOT NULL
GROUP BY ProductLine

--43)Find the state wise tax rate (hint: Sales.SalesTaxRate, Person.StateProvince) 

select * from Sales.SalesTaxRate  
select * from Person.StateProvince

select p.name,sum(taxrate) as totaltaxrate
from Sales.SalesTaxRate s,
Person.StateProvince p where s.StateProvinceID=p.StateProvinceID
group by p.name

--44) Find the department wise count of employees 

SELECT * FROM HumanResources.Department
SELECT * FROM HumanResources.EmployeeDepartmentHistory

SELECT  D.DEPARTMENTID,D.NAME ,COUNT(DISTINCT BusinessEntityID)
FROM HumanResources.Department D,HumanResources.EmployeeDepartmentHistory E
WHERE D.DepartmentID=E.DepartmentID
GROUP BY D.DEPARTMENTID,D.NAME 


SELECT  D.DEPARTMENTID,D.NAME ,COUNT( BusinessEntityID)
FROM HumanResources.Department D,HumanResources.EmployeeDepartmentHistory E
WHERE D.DepartmentID=E.DepartmentID
GROUP BY D.DEPARTMENTID,D.NAME 

--45)Find the department which is having more employees 

SELECT  D.DEPARTMENTID,D.NAME ,COUNT(DISTINCT BusinessEntityID) AS EMPCOUNT
FROM HumanResources.Department D,HumanResources.EmployeeDepartmentHistory E
WHERE D.DepartmentID=E.DepartmentID
GROUP BY D.DEPARTMENTID,D.NAME 
ORDER BY EMPCOUNT DESC

--46) Find the job title having more employees 
SELECT * FROM HumanResources.Employee
SELECT * FROM HumanResources.EmployeeDepartmentHistory

SELECT JOBTITLE,COUNT(E.BusinessEntityID) AS EMPCOUNT
FROM HumanResources.Employee E ,HumanResources.EmployeeDepartmentHistory EDH
WHERE EDH.BusinessEntityID=E.BusinessEntityID  
GROUP BY JobTitle 
ORDER BY EMPCOUNT DESC     

SELECT JOBTITLE ,COUNT(BUSINESSENTITYID) AS C
FROM HumanResources.Employee
GROUP BY JobTitle
ORDER BY C DESC  

--47)Check if there is mass hiring of employees on single day 

select HireDate,COUNT(BusinessEntityID) HIRECOUNT
from  HumanResources.Employee
GROUP  BY HireDate
ORDER BY HIRECOUNT DESC

--48)Which product is purchased more? (purchase order details) 

SELECT * FROM Production.Product
SELECT * FROM Purchasing.PurchaseOrderDetail

SELECT PurchaseOrderID,P.NAME,SUM(ORDERQTY) AS SUM_QTY
FROM Purchasing.PurchaseOrderDetail POD,Production.Product P
WHERE P.ProductID=POD.ProductID
GROUP BY PurchaseOrderID,NAME
ORDER BY SUM_QTY DESC

SELECT P.NAME,SUM(ORDERQTY) AS SUM_QTY
FROM Purchasing.PurchaseOrderDetail POD,Production.Product P
WHERE P.ProductID=POD.ProductID
GROUP BY NAME
ORDER BY SUM_QTY DESC







--49)Find the territory wise customers count   (hint: customer) 

SELECT  CustomerID FROM Sales.Customer
SELECT * FROM Sales.SalesTerritory


SELECT TERRITORYID,COUNT(CUSTOMERID) AS CC
FROM Sales.Customer
GROUP BY TerritoryID
ORDER BY CC DESC

SELECT T.TERRITORYID,T.NAME,COUNT(CUSTOMERID) AS CC
FROM Sales.Customer C,Sales.SalesTerritory T
WHERE C.TerritoryID=T.TerritoryID
GROUP BY T.TerritoryID,NAME
ORDER BY CC DESC

--50)Which territory is having more customers (hint: customer) 

SELECT * FROM Sales.Customer

SELECT T.TerritoryID,T.NAME,COUNT(CUSTOMERID) AS CUST_COUNT
FROM  Sales.Customer C,Sales.SalesTerritory T
WHERE C.TerritoryID=T.TerritoryID
GROUP BY T.TerritoryID,NAME
ORDER BY CUST_COUNT DESC
--51)Which territory is having more stores (hint: customer)
SELECT * FROM Sales.SalesTerritoryHistory
SELECT * FROM Sales.Store  
SELECT C.TerritoryID,COUNT(DISTINCT STOREID) AS STORE_COUNT
FROM Sales.Customer C,Sales.SalesTerritory ST 
WHERE C.TerritoryID=ST.TerritoryID
GROUP BY C.TerritoryID
ORDER BY STORE_COUNT DESC  

--52) Is there any person having more than one credit card (hint: PersonCreditCard) 

SELECT * FROM Sales.PersonCreditCard

SELECT BUSINESSEntityID,COUNT(DISTINCT CREDITCARDID) AS CC
FROM Sales.PersonCreditCard
GROUP BY BusinessEntityID
HAVING COUNT(DISTINCT CREDITCARDID) >1

--53)Find the product wise sale price (sales order details) 
select ProductID from sales.SalesOrderDetail where ProductID=873 and OrderQty=1

select ProductID,avg(unitprice)
from Sales.SalesOrderDetail
where OrderQty=1 and UnitPriceDiscount=0 and ProductID=873
group by ProductID
select * 
from Sales.SalesOrderDetail
group by

SELECT * FROM  Sales.SalesOrderDetail 
SELECT UnitPrice FROM Sales.SalesOrderDetail WHERE ProductID=873
group by UnitPrice

SELECT DISTINCT (ProductID),UnitPrice
FROM Sales.SalesOrderDetail
WHERE OrderQty=1

--FEELS WRONG 
SELECT PRODUCTID,SUM(UNITPRICE) AS PRICE
FROM Sales.SalesOrderDetail
GROUP BY ProductID
ORDER BY PRICE

select * from Production.Product
--54)Find the total values for line total product having maximum order
--53)Find the product wise sale price (sales order details) 
SELECT PRODUCTID, specialofferid,sum(OrderQty),
	sum(UnitPrice+ unitprice*UnitPriceDiscount)
FROM Sales.SalesOrderDetail
GROUP BY ProductID,SpecialOfferID
ORDER BY ProductID --prblm 

select * from Production.Product

select p.ProductModelID,sd.UnitPrice from
Production.Product p,
Sales.SalesOrderDetail sd
where p.ProductID=sd.ProductID
and p.ProductID=776
group by p.ProductModelID,sd.UnitPrice

SELECT PRODUCTID,UNITPRICE*OrderQty
FROM Sales.SalesOrderDetail
WHERE ProductID=873
GROUP BY ProductID,UNITPRICE,OrderQty 

SELECT PRODUCTID,UNITPRICE AS PRICE,OrderQty
FROM Sales.SalesOrderDetail
GROUP BY ProductID,UNITPRICE,OrderQty
ORDER BY PRICE 

--this below results give total sales done by each product 
SELECT A.PRODUCTID,SUM(A.CC) AS SALEPRICE
FROM 
 (SELECT PRODUCTID,UNITPRICE*OrderQty AS CC
FROM Sales.SalesOrderDetail             
GROUP BY ProductID,UNITPRICE,OrderQty  )AS A 
GROUP BY A.ProductID 
--STAR
--54)Find the total values for line total product having maximum order 

select * from production.product

--55)Calculate the age of employees 

select * from HumanResources.Employee --290 rows
select distinct businessentityid from HumanResources.Employee--290 rows implies no need of group by 
select businessentityid,nationalidnumber,
concat( DATEDIFF(month,birthdate,GETDATE())/12,' yrs and  ',DATEDIFF(month,birthdate,GETDATE())%12,'months') as age
from HumanResources.Employee


--56) Calculate the year of experience of the employee based on hire date 
SELECT * FROM HumanResources.Employee
SELECT BusinessEntityID,DATEDIFF(MONTH,HIREDATE,GETDATE())
FROM  HumanResources.Employee                         

SELECT E.BusinessEntityID,CONCAT(P.FIRSTNAME,' ',P.LASTNAME) AS FULLNAME,DATEDIFF(MONTH,HIREDATE,GETDATE())/12 AS YRS,DATEDIFF(MONTH,HIREDATE,GETDATE())%12 AS MONTHS
FROM  HumanResources.Employee E,Person.Person P 
WHERE E.BusinessEntityID=P.BusinessEntityID  

SELECT E.BusinessEntityID,CONCAT(P.FIRSTNAME,' ',P.LASTNAME) AS FULLNAME,E.HireDate,
CONCAT(DATEDIFF(MONTH,HIREDATE,GETDATE())/12 ,' YRS AND ',DATEDIFF(MONTH,HIREDATE,GETDATE())%12,' MONTHS') AS DURN
FROM  HumanResources.Employee E,Person.Person P 
WHERE E.BusinessEntityID=P.BusinessEntityID  
ORDER BY BUSINESSENTITYID,HireDate,FULLNAME


--57)Find the age of employee at the time of joining 

select * from HumanResources.Employee 

select businessentityid,CONCAT(datediff(month,birthdate,HireDate)/12,' YRS AND ',datediff(month,birthdate,HireDate)%12,'MONTHS') AS HIRED_at_age
from HumanResources.Employee

--58)Find the average age of male and female 

select * from HumanResources.Employee


select t.gender,avg(t.age) as avg_age
from
(select businessentityid,nationalidnumber,gender,
 DATEDIFF(month,birthdate,GETDATE())/12 as age
from HumanResources.Employee) as t
group by t.gender --                      

--output male avg age is 45 and female is 46


--59)Which product is the oldest product as on the date (refer  the product sell start date) 

select * from production.product
select  distinct productid  from Production.Product
--no dubplicate records 

select productid
from Production.Product where SellStartDate =(
select min(sellstartdate)  as sss
from Production.Product) --211 rows 
---211 records with lowest date 


select productid,min(sellstartdate) as mindate
from Production.Product
group by ProductID
order by mindate

--60). Display the product name, standard cost, and time duration for the same cost. (Product cost history)
--STAR
SELECT ProductID,StandardCost,COUNT(StandardCost) FROM Production.Product
GROUP BY ProductID,StandardCost
--61)Find the purchase id where shipment is done 1 month later of order date
select * from Purchasing.PurchaseOrderDetail
select * from Sales.SalesOrderDetail
select * from Sales.SalesOrderHeader

select sod.SalesOrderID,orderdate,ShipDate,datediff(month,orderdate,shipdate) as ddf
from Sales.SalesOrderHeader soh ,sales.salesorderdetail sod
where soh.salesorderid=sod.salesorderid and 
datediff(month,orderdate,shipdate)>=1 
order by ddf desc 

--61)Find the sum of total due where shipment is done 1 month later of order date ( purchase order header)

select * from Sales.SalesOrderDetail  

select *,datediff(DAY,orderdate,shipdate) as ddf,SUM(TOTALDUE) OVER (ORDER BY SOD.SALESORDERID)
from Sales.SalesOrderHeader soh ,sales.salesorderdetail sod
where soh.salesorderid=sod.salesorderid and 
datediff(DAY,orderdate,shipdate)>=30
order by ddf desc 

--62)Find the sum of total due where shipment is done 1 month later of order date ( purchase order header)


--63)Find the average difference in due date and ship date based on  online order flag
SELECT T. ONLINEORDERFLAG ,AVG(T.DDF)
FROM
(select *,DATEDIFF(month,DueDate,ShipDate) AS DDF
from Sales.SalesOrderHeader) AS T
GROUP BY T.OnlineOrderFlag

--64)Display business entity id, marital status, gender, vacationhr, average vacation based on marital status
SELECT BusinessEntityID,MARITALSTATUS,GENDER,VacationHours,
AVG(VacationHours) OVER (PARTITION BY MARITALSTATUS ) AS AVG_VACAY_HRS
FROM HumanResources.Employee    


--65.Display business entity id, marital status, gender, vacationhr, average vacation based on gender

SELECT BusinessEntityID,MARITALSTATUS,GENDER,VacationHours,
AVG(VacationHours) OVER (PARTITION BY GENDER ) AS AVG_VACAY_HRS
FROM HumanResources.Employee    

--66.Display business entity id, marital status, gender, vacationhr, 
--average vacation based on organizational level
SELECT BusinessEntityID,MARITALSTATUS,GENDER,VacationHours,ORGANIZATIONLEVEL,
AVG(VacationHours) OVER (PARTITION BY ORGANIZATIONLEVEL ) AS AVG_VACAY_HRS
FROM HumanResources.Employee    


--67.Display entity id, hire date, department name and department wise count of employee 
--and count based on organizational level in each dept

SELECT BusinessEntityID,MARITALSTATUS,GENDER,VacationHours,ORGANIZATIONLEVEL,
COUNT(BusinessEntityID) OVER (PARTITION BY  ) AS AVG_VACAY_HRS
FROM HumanResources.Employee    






























--EXTRA QUESTION 

--DISPLAY BUSINESS ENITY ID MARITAL STATUS GENDER VACN HR, AVG VACN BASED ON MARITAL STATUS 

SELECT BusinessEntityID,MaritalStatus,GENDER,VacationHours,
AVG(vacationhours) over (partition by maritalstatus) as avgvcnhrs
FROM HumanResources.Employee

--display BUSINESS ENITY ID MARITAL STATUS GENDER VACN HR, AVG VACN BASED ON organizational level

select * from HumanResources.Employee where OrganizationLevel=1
SELECT BusinessEntityID,MaritalStatus,GENDER,VacationHours,OrganizationLeveL,
AVG(vacationhours) over (partition by organizationlevel) as avgo
FROM HumanResources.Employee


--display entityid,hiredate,dept name, dept wise count of employee and count based on organization level
--in each department

select * from HumanResources.Employee  --enityid,hiredate,
select * from HumanResources.Department  -- deptid,dname
select * from HumanResources.EmployeeDepartmentHistory --bid,did

select e.BusinessEntityID,hiredate,d.name,e.organizationlevel,
count(e.BusinessEntityID) over (partition by d.departmentid)as dwise_avg_count_emp,
count(e.BusinessEntityID) over (partition by d.departmentid,organizationlevel)as orga_deptwise_e_count
from  HumanResources.Employee e,HumanResources.EmployeeDepartmentHistory edh,HumanResources.Department d
where e.BusinessEntityID=edh.BusinessEntityID and edh.DepartmentID=d.DepartmentID  


--display depname,average sick leave, and sick leave per dept,
 
use adventureworks2022 
select * from HumanResources.Employee --290 rows
select * from HumanResources.EmployeeDepartmentHistory --296 rows

select D.DepartmentID,D.NAME,( SELECT AVG(SICKLEAVEHOURS) FROM HumanResources.Employee),
AVG(SICKLEAVEHOURS) OVER (PARTITION BY D.DEPARTMENTID)
from HumanResources.Employee  e ,HumanResources.EmployeeDepartmentHistory edh,HumanResources.Department D
where edh.BusinessEntityID=e.BusinessEntityID AND D.DepartmentID=EDH.DepartmentID
--296 rows  

select DISTINCT D.DepartmentID,D.NAME,( SELECT AVG(SICKLEAVEHOURS) FROM HumanResources.Employee),
AVG(SICKLEAVEHOURS) OVER (PARTITION BY D.DEPARTMENTID)
from HumanResources.Employee  e ,HumanResources.EmployeeDepartmentHistory edh,HumanResources.Department D
where edh.BusinessEntityID=e.BusinessEntityID AND D.DepartmentID=EDH.DepartmentID


--THIS QUERY GIVES PERDEPTPERPERSON WISE AVG SICK LEAVE HRS AND THEN PER DEP AVG SICKLEAVE HRS
select D.DepartmentID, D.NAME,(SELECT AVG(SICKLEAVEHOURS) FROM HumanResources.Employee E WHERE E.BusinessEntityID=EDH.BusinessEntityID) AS T_AVG,
AVG(SICKLEAVEHOURS) OVER (PARTITION  BY D.DEPARTMENTID) AS P_AVG
from HumanResources.Employee  e ,HumanResources.EmployeeDepartmentHistory edh,HumanResources.Department D
where edh.BusinessEntityID=e.BusinessEntityID  AND D.DepartmentID=EDH.DepartmentID--296 rows   

--display deptname,count based on gender

select D.DepartmentID,D.NAME,e.gender,
count(*) OVER (PARTITION BY e.Gender)
from HumanResources.Employee  e ,HumanResources.EmployeeDepartmentHistory edh,HumanResources.Department D
where edh.BusinessEntityID=e.BusinessEntityID AND D.DepartmentID=EDH.DepartmentID

--check the person details with total count of various shift done 
--by the person and shifts count per dept 
select * from HumanResources.Employee
select * from Person.Person 
select * from HumanResources.EmployeeDepartmentHistory  

count(edh.shiftid) over (partition by edh.departmentid)

select p.BusinessEntityID,edh.departmentid,
count(distinct ShiftID) from Person.Person p, HumanResources.EmployeeDepartmentHistory edh
where p.BusinessEntityID=edh.BusinessEntityID
group by p.BusinessEntityID,edh.DepartmentID

select * from HumanResources.Employee e,humanwhere BusinessEntityID=2

--find different shift ids for each department 

select d.DepartmentID,count(distinct shiftid)
from HumanResources.EmployeeDepartmentHistory edh , HumanResources.Department d
where edh.departmentid=d.DepartmentID
group by d.DepartmentID 

--display countryregioncode,group ,avg sales quota based on territory id

select distinct CountryRegionCode,st.[group] ,st.TerritoryID,
avg(sp.salesquota) over (partition by st.territoryid)
from sales.SalesPerson sp,Sales.SalesTerritory st 
where sp.TerritoryID=st.TerritoryID

select distinct st.TerritoryID, CountryRegionCode,st.[group] ,
avg(sp.salesquota) over (partition by st.territoryid)
from sales.SalesPerson sp,Sales.SalesTerritory st 
where sp.TerritoryID=st.TerritoryID 



--diplay special offer description,category and avg discount pct as per the category 
select * from sales.specialoffer 

select  category,description,
avg(discountpct) over (partition by category)
from sales.specialoffer


--diplay special offer description,category and avg discount pct as per the month
use AdventureWorks2022
select  month(startdate),category,description,
avg(discountpct) over (partition by month(startdate))
from sales.specialoffer
order by Description

select  format(startdate,'yyyy-MM'),category,description,
avg(discountpct) over (partition by format(startdate,'yyyy-MM') ) AS AVG_DIS
from sales.specialoffer
order by Description

--73.Display special offer description, category and avg(discount pct) per the year
SELECT sp.Description, sp.Category, YEAR(sp.StartDate) _year,
       AVG(sp.DiscountPct) OVER (PARTITION BY YEAR(sp.StartDate)) _avgdiscountpct
FROM Sales.SpecialOffer sp; 



select t.Description,t.Category,avg(t.DiscountPct),t._month from
(select sf.SpecialOfferID,
	   sf.Description,
	   sf.Category,
	   sf.DiscountPct,
	   year(sf.StartDate) _month
from Sales.SpecialOffer sf) as t 
group by t.Description,t.Category,t._month

--74.Display special offer description, category and avg(discount pct) per the type
SELECT sp.Description, sp.Category, sp.Type,
       AVG(sp.DiscountPct) OVER (PARTITION BY sp.Type) _avgdiscountpct
FROM Sales.SpecialOffer sp;


--75.Using rank and dense rand find territory wise top sales person

SELECT s.BusinessEntityID, st.TerritoryID, s.SalesYTD,
       RANK() OVER (PARTITION BY st.TerritoryID ORDER BY s.SalesYTD DESC) AS SalesRank,
       DENSE_RANK() OVER (PARTITION BY st.TerritoryID ORDER BY s.SalesYTD DESC) AS DenseSalesRank
FROM Sales.SalesPerson s
JOIN Sales.SalesTerritory st ON s.TerritoryID = st.TerritoryID;








---find the duration of payment revision on every interval  (inline view) Output must be as given format 
--revised time – count of revised salries 
--duration – last duration of revision e.g there are two revision date 01-01-2022 and revised in 01-01-2024   so duration here is 2years   
select * from HumanResources.EmployeePayHistory

select t1.BusinessEntityID,p.firstname,p.lastname,ranks as revised_time,
concat( datediff(month,t1.lagged,t1.ratechangedate)/12,' yrs ',datediff(month,t1.lagged,t1.ratechangedate)%12,' months')  as duration 
from
(select * from (
SELECT h.BusinessEntityID,h.ratechangedate,ranks,
lag(ratechangedate) over (partition by businessentityid order by ratechangedate) as lagged
FROM
(select BusinessEntityID,ratechangedate,
row_number()  over (partition by  businessentityid order by ratechangedate ) as ranks
from HumanResources.EmployeePayHistory  )as h  
WHERE ranks>1 ) as t
where t.lagged is not null ) as t1,person.person p
where p.BusinessEntityID=t1.businessentityid

--A "Single Item Order" is a customer order where only one item is ordered. 
--Show the SalesOrderID and the UnitPrice for every Single Item Order.

select * from Sales.SalesOrderDetail


--Where did the racing socks go? 
--List the product name and the CompanyName for all Customers who ordered ProductModel 'Racing Socks'.
select * from Production.Product
select * from Production.ProductModelIllustration
--From the following tables write a query in SQL to calculate and display 
--the latest weekly salary of each employee.
--Return RateChangeDate, full name (first name, middle name and last name) 
--and weekly salary (40 hours in a week) of employees Sort the output in ascending order on NameInFull.

select * from HumanResources.EmployeePayHistory
--From the following table write a query in SQL to find the sum, average, count, minimum,
--and maximum order quentity for those orders whose id are 43659 and 43664. Return SalesOrderID, 
--ProductID, OrderQty, sum, average, count, max, and min order quantity.

select * from Sales.SalesOrderDetail 
































































































select * 
FROM HumanResources.Employee E,HumanResources.EmployeePayHistory EP
WHERE E.BusinessEntityID=EP.BusinessEntityID    

--

--date things q 24

(SELECT BusinessEntityID,RateChangeDate,MAX(RatechangeDate) FROM HumanResources.EmployeePayHistory
GROUP BY BusinessEntityID,RateChangeDate)    
 
 SELECT * FROM HumanResources.EmployeePayHistory
GROUP BY BusinessEntityID,RateChangeDate  
--unknowm question 
SELECT * FROM Purchasing.ShipMethod

SELECT *,
CASE WHEN ShipRate<=0.99 THEN 'LOW'
WHEN ShipRate <=2 THEN 'MED'
ELSE 'HIGH'
END AS 'CATEGORY'
FROM Purchasing.ShipMethod

--IS NULL(FILLS WITH VALUE GIVEN WHERE NULL VALUES PRESENT),COALESCE  

SELECT * FROM Sales.SalesOrderHeader

SELECT TERRITORYID,COALESCE(CurrencyRateID,0)
FROM Sales.SalesOrderHeader  

--LIKE OPERATOR WITH OR
SELECT * 
FROM Person.Person
WHERE FirstName LIKE 'A%' OR FirstName LIKE 'P%'
--ABOVE CAN BE SOLVED AS BELOW 
SELECT * 
FROM Person.Person
WHERE FirstName LIKE '[AP]%' -- START WITH A OR P 

SELECT * 
FROM Person.Person
WHERE FirstName LIKE '[A-D]%' 

--MATH FUNCTION 
--SELECT CURRENT_TIMESTAMP
--SELECT ABS() 
--CIELING 
--FLOOR ,TAN COS SIN ,
--EXP(1),LOG(0)
--POWER(2,4) 2 RAISED TO 4 
--RADIAN(90)  
--ROUND(132.555,2) ROUND OF TWO DECIMAL   
--RAND() 
--CHAR(65) 

SELECT CHAR(65),
CHARINDEX('H','AGHORA'),
'ABC'+'COM',
DATALENGTH('BIZ'),
DIFFERENCE('EBC','ABCDE')SCORE,'BIZMTERIC ',
LEFT('BIS',2),
RIGHT('BIS',2),

DIFFERENCE('EBC1','1')

--
LEN,LTRIM,RTRIM,LOWER,UPPER,

SELECT SUBSTRING(' BIZTMETRIC  ',6,3),
SUBSTRING(' BIZTMETRIC  ',6,1) ;

 SELECT CHARINDEX('R','RARANDINT')  



SELECT TRANSLATE('TODAY IS MON','O','U')
SELECT TRANSLATE('TODAY IS MON','MO','SU')
SELECT TRANSLATE('TODAY IS MON','MON','SUN')
SELECT TRANSLATE('MY,TODAY IS MONDAY','MONDAY','SUNDAY')  