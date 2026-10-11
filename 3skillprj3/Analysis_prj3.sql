CREATE DATABASE supply_chain_project;
USE supply_chain_project;

CREATE TABLE supply_chain_inventory (
    Product_ID INT,
    Product_Name VARCHAR(100),
    Category VARCHAR(50),
    Supplier_Name VARCHAR(100),
    Order_Date DATE,
    Delivery_Date DATE,
    Stock_Quantity INT,
    Reorder_Level INT,
    Units_Sold INT,
    Purchase_Cost DECIMAL(10,2),
    Selling_Price DECIMAL(10,2),
    Warehouse_Location VARCHAR(50),
    Shipping_Time_Days INT
);


-- STEP 3: REMOVE DUPLICATES
CREATE TABLE cleaned_data AS
SELECT DISTINCT * FROM supply_chain_inventory;

-- STEP 4: HANDLE NEGATIVE VALUES
UPDATE cleaned_data
SET Stock_Quantity = 0
WHERE Stock_Quantity < 0;

UPDATE cleaned_data
SET Units_Sold = 0
WHERE Units_Sold < 0;

-- STEP 5: ADD DELIVERY DELAY COLUMN
ALTER TABLE cleaned_data
ADD Delivery_Delay INT;

UPDATE cleaned_data
SET Delivery_Delay = DATEDIFF(Delivery_Date, Order_Date);

-- STEP 6: CORE ANALYSIS

-- Total Units Sold
SELECT SUM(Units_Sold) AS Total_Units_Sold
FROM cleaned_data;

-- Total Revenue
SELECT 
SUM(Units_Sold * Selling_Price) AS Total_Revenue
FROM cleaned_data;

-- Total Profit
SELECT 
SUM((Selling_Price - Purchase_Cost) * Units_Sold) AS Total_Profit
FROM cleaned_data;

-- Average Shipping Time
SELECT AVG(Shipping_Time_Days) AS Avg_Shipping_Time
FROM cleaned_data;

-- STEP 7: BUSINESS LOGIC

-- Inventory Status
SELECT *,
CASE 
    WHEN Stock_Quantity < Reorder_Level THEN 'Understock'
    WHEN Stock_Quantity > Reorder_Level * 1.5 THEN 'Overstock'
    ELSE 'Optimal'
END AS Inventory_Status
FROM cleaned_data;

-- Fast vs Slow Moving
SELECT *,
CASE 
    WHEN Units_Sold > (SELECT AVG(Units_Sold) FROM cleaned_data)
    THEN 'Fast Moving'
    ELSE 'Slow Moving'
END AS Movement_Type
FROM cleaned_data;

-- STEP 8: ADVANCED ANALYSIS

-- Top 10 Selling Products
SELECT Product_Name,
SUM(Units_Sold) AS Total_Sales
FROM cleaned_data
GROUP BY Product_Name
ORDER BY Total_Sales DESC
LIMIT 10;

-- Supplier Performance (Delivery Delay)
SELECT Supplier_Name,
AVG(Delivery_Delay) AS Avg_Delay
FROM cleaned_data
GROUP BY Supplier_Name
ORDER BY Avg_Delay DESC;

-- Product Profitability
SELECT Product_Name,
SUM((Selling_Price - Purchase_Cost) * Units_Sold) AS Profit
FROM cleaned_data
GROUP BY Product_Name
ORDER BY Profit DESC;

-- STEP 9: BUSINESS QUESTIONS

-- 1. Frequently Out of Stock Products
SELECT Product_Name, COUNT(*) AS Out_Of_Stock_Count
FROM cleaned_data
WHERE Stock_Quantity < Reorder_Level
GROUP BY Product_Name
ORDER BY Out_Of_Stock_Count DESC;

-- 2. Suppliers with Highest Delays
SELECT Supplier_Name,
AVG(Delivery_Delay) AS Avg_Delay
FROM cleaned_data
GROUP BY Supplier_Name
ORDER BY Avg_Delay DESC;

-- 3. Highest Profit Products
SELECT Product_Name,
SUM((Selling_Price - Purchase_Cost) * Units_Sold) AS Profit
FROM cleaned_data
GROUP BY Product_Name
ORDER BY Profit DESC
LIMIT 10;

-- 4. Inventory Optimization Summary
SELECT 
Inventory_Status,
COUNT(*) AS Product_Count
FROM (
    SELECT *,
    CASE 
        WHEN Stock_Quantity < Reorder_Level THEN 'Understock'
        WHEN Stock_Quantity > Reorder_Level * 1.5 THEN 'Overstock'
        ELSE 'Optimal'
    END AS Inventory_Status
    FROM cleaned_data
) t
GROUP BY Inventory_Status;

-- 5. Impact of Delivery Delay on Sales
SELECT 
CASE 
    WHEN Delivery_Delay <= 3 THEN 'Low Delay'
    WHEN Delivery_Delay <= 7 THEN 'Medium Delay'
    ELSE 'High Delay'
END AS Delay_Category,
AVG(Units_Sold) AS Avg_Sales
FROM cleaned_data
GROUP BY Delay_Category;

-- STEP 10: EXTRA INSIGHT (FOR POWER BI SCATTER)
SELECT 
Delivery_Delay,
Units_Sold
FROM cleaned_data;