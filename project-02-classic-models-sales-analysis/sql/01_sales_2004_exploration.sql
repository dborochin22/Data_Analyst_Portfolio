-- Exploration: order-line detail for 2004, joined across orders, orderdetails, products and customers.
-- Used to check the joins and the shape of the data before building the Power BI view.

select t1.orderDate, t1.orderNumber, quantityOrdered, priceEach, productName, productLine, buyPrice, city, country
from orders t1
inner join orderdetails t2
on t1.orderNumber = t2.orderNumber
inner join products t3
on t2.productCode = t3.productCode
inner join customers t4
on t1.customerNumber = t4.customerNumber
where year(orderDate) = 2004
;
