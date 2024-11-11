
Create table Cosmet_Products 
(ProductID Int PRIMARY KEY, 
Prod_Category Varchar(50), 
Prod_Brand Varchar(50),
Prod_Price Decimal(5,2),
Prod_Vegan Varchar(50),
);

-- Bulk Insert data
BULK
INSERT Cosmet_Products

FROM 'C:\Users\User\Desktop\Cosmetics\Cosmetics_products.csv'

WITH
(FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n',
FIRSTROW = 2
);   

Select * From Cosmet_Products

Create table Cosmet_Sales 
(SaleID Int PRIMARY KEY, 
ProductID Int FOREIGN KEY REFERENCES Cosmet_Products(ProductID), 
SaleDate Date, 
Quantity Varchar(50), 
Total_Sales Decimal (6,2), 
Store_Location Varchar(50), 
);

DROP table Cosmet_Sales

-- Bulk Insert data into
BULK
INSERT Cosmet_Sales

FROM 'C:\Users\User\Desktop\Cosmetics\Cosmetics_sales.csv'

WITH
(FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n',
FIRSTROW = 2
);

Select * from Cosmet_Sales


--Retrieve TOP 20 Cosmetic Products by Total Sales 
SELECT TOP 20 ProductID, Total_Sales
FROM Cosmet_Sales
Group by ProductID, Total_Sales
Order by Total_Sales DESC

--Retrieve Sales Data for a Specific Month (October 2024).

SELECT ProductID, SaleDate, Total_Sales
FROM Cosmet_Sales
WHERE SaleDate BETWEEN '2024-10-01' AND '2024-10-31'
ORDER BY SaleDate DESC;

--Retrieve Sales Data by a Specific Location (Boston).
SELECT ProductID, Total_Sales, Store_Location 
FROM Cosmet_Sales 
Where Store_Location LIKE '%Boston%';

SELECT * FROM Cosmet_Products
SELECT * FROM Cosmet_Sales



Create table Cosmet_Reviews 
(ReviewID Int PRIMARY KEY, 
ProductID Int FOREIGN KEY REFERENCES Cosmet_Products(ProductID), 
CustomerID Int,
Customer_Rating Int,
);

-- Bulk Insert data
BULK
INSERT Cosmet_Reviews

FROM 'C:\Users\User\Desktop\Cosmetics\Cosmetics_reviews.csv'

WITH
(FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n',
FIRSTROW = 2
); 

SELECT * FROM Cosmet_Reviews

--Total Number of Reviews for Each Product
SELECT ProductID, COUNT(ReviewID) AS Total_Reviews
FROM Cosmet_Reviews
GROUP BY ProductID
ORDER BY Total_Reviews DESC;

--Highest Customer Rating for Each Product
SELECT ProductID, MAX(Customer_Rating) AS Highest_Rating
FROM Cosmet_Reviews
GROUP BY ProductID
ORDER BY Highest_Rating DESC;

--Average Rating for All Products 
SELECT ProductID, AVG(Customer_Rating) AS Average_Rating
FROM Cosmet_Reviews
GROUP BY ProductID
ORDER BY Average_Rating DESC;


-- Get Products with No Sales
SELECT p.ProductID, p.Prod_Brand, p.Prod_Category
FROM Cosmet_Products p
LEFT JOIN Cosmet_Sales s ON p.ProductID = s.ProductID
WHERE s.SaleID IS NULL;

--Get Average Rating and Total Sales for Each Product
SELECT 
    p.ProductID, 
    p.Prod_Brand, 
    p.Prod_Category, 
    AVG(r.Customer_Rating) AS Average_Rating, 
    SUM(s.Total_Sales) AS Total_Sales
FROM Cosmet_Products p
LEFT JOIN Cosmet_Reviews r ON p.ProductID = r.ProductID
LEFT JOIN Cosmet_Sales s ON p.ProductID = s.ProductID
GROUP BY p.ProductID, p.Prod_Brand, p.Prod_Category
ORDER BY Total_Sales DESC;

--Find Products with the Highest Average Rating
SELECT p.ProductID, p.Prod_Brand, p.Prod_Category, AVG(r.Customer_Rating) AS Average_Rating
FROM Cosmet_Products p
JOIN Cosmet_Reviews r ON p.ProductID = r.ProductID
GROUP BY p.ProductID, p.Prod_Brand, p.Prod_Category
ORDER BY Average_Rating DESC;

--Find Products with No Sales in the Last 6 Months
SELECT p.ProductID, p.Prod_Brand, p.Prod_Category
FROM Cosmet_Products p
LEFT JOIN Cosmet_Sales s ON p.ProductID = s.ProductID
WHERE s.SaleID IS NULL OR s.SaleDate < DATEADD(MONTH, -6, GETDATE());

--Find Products with the Highest Total Sales in Each Store
WITH RankedSales AS (
  SELECT s.Store_Location, s.ProductID, 
   SUM(s.Total_Sales) AS Total_Sales,
   ROW_NUMBER() OVER (PARTITION BY s.Store_Location ORDER BY SUM(s.Total_Sales) DESC) AS Rank
  FROM Cosmet_Sales s
  GROUP BY s.Store_Location, s.ProductID
)
SELECT Store_Location, ProductID, Total_Sales
FROM RankedSales
WHERE Rank = 1;
