-- Power BI source view: one row per order line, with customer, product line, sales office,
-- sales value (quantity * price) and cost of sales (quantity * buy price).

create or replace view sales_data_for_power_bi as

select 
orderDate, 
ord.orderNumber, 
p.productName,
p.productLine, 
c.customerName, 
c.country as customer_country,
o.country as office_country,
buyPrice, 
priceEach, 
quantityOrdered,
quantityOrdered * priceEach as sales_value,
quantityOrdered * buyPrice as cost_of_sales
from orders ord
inner join orderdetails orddet
on ord.orderNumber = orddet.orderNumber
inner join customers c
on ord.customerNumber = c.customerNumber
inner join products p
on orddet.productCode = p.productCode
inner join employees e
on c.salesRepEmployeeNumber = e.employeeNumber
inner join offices o
on e.officeCode = o.officeCode;
