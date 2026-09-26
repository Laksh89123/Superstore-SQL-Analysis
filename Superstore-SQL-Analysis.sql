-- ============================
-- -- Project: Superstore SQL Analysis
-- =============================

--Created Database

Create Database Project_Superstores;
USE Project_superstores;

--Q1. Find the total sales, total profit for each region.

Select Region, sum(sales) as Total_Sales
,sum(profit) as Total_Profit
from orders
Group by region;

--Q2. Find the total sales and total profit for 
--each Category

Select category, sum(sales) as Total_sales 
,sum(profit) as Total_Profit
from orders
Group by category;

--Q3. Find the total sales and total profit for each 
--Category and Sub-Category

Select Category, [Sub-Category]
,Sum(Sales) as Total_Sales
,Round(Sum(Profit),2) as Total_Profit
from orders
Group by Category, [Sub-Category]
Order by Sum(Profit) desc;

--Q4. Find the top 5 cities based on total Sales.

Select Top 5 city, Sum(sales) as T_Sales
from orders
Group by city
order by sum(sales) desc;

--Q5. Find the top 3 customers based on their 
--total Sales.

Select Top 3 [customer id], [Customer name]
,Sum(Sales) as T_Sales
from orders
Group by [customer id], [Customer name]
Order by sum(sales) desc;

--Q6. Find the total Sales and total Profit for each 
--Region,but show only those regions where total Profit 
--is greater than 50,000.

Select Region
,sum(sales) as Total_Sales
,sum(profit) as Total_profit
from orders
Group by Region
Having sum(profit)>50000;

--Q7. For each Region, find the customer who generated 
--the highest total Sales.

With Cte as(
Select Region, [Customer ID], [Customer Name]
,sum(sales) as total_sales
,row_number()over(partition by Region 
order by sum(sales) desc) as rn
from orders
Group by Region, [Customer ID], [Customer Name]
)
Select * from cte
Where rn = 1

--Q8. For each Category, find the top 2 Sub-Categories 
--based on Total Sales.

with cte1 as(
Select Category, [sub-category]
,Sum(Sales) as Total_Sales
,Rank()over(partition by category order by
Sum(Sales) desc) as Ranks
from orders
Group by Category, [sub-category]
)
Select * from cte1
Where ranks <3;

--Q9. Find the total Sales for each year.

Select datepart(Year, [Order Date]) as Order_Year
,Sum(sales) as Total_Sales
from orders
Group by datepart(Year, [Order Date])
order by datepart(Year, [Order Date]) desc;

-- Q10. Find the total Sales for each month of 2025.

Select datename(Month, [Order Date]) as Order_Month
,Round(sum(sales),2) as Total_Sales
from Orders
WHERE DATEPART(YEAR, [Order Date]) = 2025
Group by datename(Month, [order date]),
Datepart(month,[order date])
Order by datepart(Month, [order date]) asc

--Q11. Find the top 5 products based on total Profit.

Select Top 5 [Product Name]
,Sum(profit) as Total_profit
from orders
Group by [Product Name]
Order by Sum(profit) desc;

--Q12. Find the total number of orders placed by each 
--Customer in each Region.

Select Region, [Customer Name],count(*) as Total_orders
from orders
Group by Region, [customer Name]
Order by count(*) desc;

--Q13. Find the average Sales for each Sub-Category.

Select [sub-category], AVG(sales) as Average_Sales
from Orders
Group by [Sub-Category]
order by AVG(sales) desc;

--Q14. Find the average Discount for each Sub-category and 
--show only those sub-categories where the average 
--Discount is greater than 20%.

Select [Sub-Category], avg(Discount) as Average_Discount 
from orders
Group by [Sub-Category]
Having avg(Discount)>0.20;

--Q15. Find the total Sales generated in each Region 
--along with the Regional Manager for that Region.

Select o.Region, p.[Regional Manager] 
,round(sum(o.Sales),2) as Total
from orders o
inner join people p on o.region = p.region
Group by o.Region, p.[Regional Manager]
order by sum(o.sales) desc;

--Q16. Find the total Sales for Returned vs Non-Returned 
--orders.

With cte1 as(
Select o.sales,
Case when
 r.Returned is null then 'Non_Returned' 
 else 'Returned'
 End as Return_Status
 from orders o
left join Returns r on o.[Order id] = r.[order id]
)
Select Return_Status
,sum(sales) as Total_Sales
From Cte1
Group by Return_Status;

--Q17. Find the total number of orders and total Sales 
--for each Region, but only for orders that were returned.

Select o.Region, count (o.[order id]) as No_of_orders
,sum(o.sales) as Total_Sales
from orders o
left join Returns r on o.[order id] = r.[order id]
where r.returned = 'Yes'
Group by o.Region;

--Q18. Find the Region with the highest total 
--Profit Margin.

With Cte3 as(
Select o.region
,Sum(o.sales) as Total_Sales
,Sum(o.Profit) as Total_profit 
,(sum(o.profit)/sum(o.sales))*100.0 as profit_margin
,Row_number()over(
order by (sum(o.profit)/sum(o.sales))*100.0 desc) as rn 
from orders o
Group by o.Region
)
Select * from Cte3
Where rn = 1;

--Q19. Find the total sales for each year and 
--calculate the percentage change in sales compared 
--with the previous year.

with cte1 as(
Select datepart(year, [order date]) as Year 
,Sum(sales) as Total_Sales
from orders
Group by datepart(year, [order date])
),
Cte2 as(
Select Year, Total_Sales,
lag(Total_sales) over (order by year) 
as previous_Year_Sales
from Cte1
)
Select *,
Round(
(Total_Sales - Previous_Year_Sales)/
Previous_Year_Sales * 100.0,2) as Sales_Growth
from Cte2
Where Previous_Year_sales is not Null
order by Year desc;

--Q20. Category-wise Yearly Sales

Select Datepart(Year, [Order Date]) as Yearly
,Category, Sum(Sales) as Category_wise_Sales
from orders
Group by Category,Datepart(Year, [Order Date])
Order by Datepart(Year, [Order Date]), sum(sales) desc;

--Q21. Best-Selling Sub-Category in Each Year

With Cte1 as(
Select datepart(Year, [Order date]) as yearly
,[Sub-Category],sum(sales) as Sub_Category_wise_Sales
,Row_number()over
	(partition by datepart(Year,[Order date]) 
		order by sum(sales) desc)as RN
from orders
Group by datepart(Year, [Order date]), [Sub-Category]
)
Select * from cte1
Where RN = 1;

--Q22. Top 2 Customers by Sales in Each Region

With Cte1 as(
Select Region, [customer name]
,Sum(sales) as Total_Sales
,RANK() over(partition by region 
	order by sum(sales) desc) as RN
from orders
Group by [Customer Name], Region
)
Select * from Cte1
Where RN < 3;

--Q23. Find the total sales for each month of each year.

Select Datepart(Year,[Order Date]) as Year
,Datepart(Month , [Order Date]) as Month_N
,Datename(Month, [Order Date]) as Month
,Sum(sales) as Total_Sales
from orders
Group By Datepart(Year,[Order Date]),
Datepart(Month , [Order Date]),
Datename(Month, [Order Date])
Order by Datepart(Year,[Order Date]) desc,
Datepart(Month , [Order Date]);

--Q24. Most Profitable Sub-Category in Each Category

With cte1 as(
Select Category, [sub-category],sum(profit) as Total
,Row_Number()over(partition by Category 
	order by sum(profit) desc) as RN
From orders
Group by category,[Sub-category]
)
Select * from Cte1 
Where rn = 1;


--Q25. Classify each order into three discount categories 
--and find the total Sales for each category.

Select sum(sales) as Total_sales,
case when discount = 0 Then 'No Discount'
When discount > 0 and discount<=0.20 then 'Low Discount'
	else 'High Discount'
end as Discount_Category
from orders
Group by case when discount = 0 Then 'No Discount'
When discount > 0 and discount<=0.20 then 'Low Discount'
	else 'High Discount'
End;

--Q26. Find the total Sales and total Profit for each 
--Customer Segment, and calculate the Profit Margin for 
--each Segment.

Select segment, sum(Sales) as Total_Sales
,Sum(profit) as profit
,Round(
(sum(profit)/Sum(sales))*100.0 ,2) as Profit_Margin
from orders
Group by segment
order by sum(sales) desc,sum(profit) desc

--Q27. Find the total Sales and total number of returned 
--orders for each Category.

Select o.category, sum(o.sales) as Total_Sales
,count(r.returned) as Returned_order
from orders o
left join returns r on o.[order id] = r.[order id]
Where r.returned = 'Yes'
Group by o.category
order by sum(o.sales) desc, count(r.returned);

--Q28. Find customers who have placed more than 5 orders 
--and calculate their total sales.

Select [Customer id], [Customer Name], 
count([order id]) as No_of_orders
,Sum(sales) as Total_Sales
from orders
Group by [Customer id], [Customer Name]
Having count([order id])>5
Order by count([order id]);

--Q29. Find the total number of orders and total sales 
--for each Category where the order value is more than 
--1,000.

Select category
,Count([Order ID]) as Total_Order_Category
,Sum (Sales) as [Total Sales]
from orders
Where Sales > 1000
Group by Category

--Q30. Find all Products where the total Profit 
--is negative.

Select [Product Name],Sum(sales) as Total_Sales
,sum(profit) as Total_Profit
from orders
Group by [Product Name]
Having sum(profit)<0;


