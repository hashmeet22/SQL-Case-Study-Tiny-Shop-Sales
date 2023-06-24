show databases;
create database data_in_motion;
use data_in_motion;

CREATE TABLE customers (
    customer_id integer PRIMARY KEY,
    first_name varchar(100),
    last_name varchar(100),
    email varchar(100)
);

CREATE TABLE products (
    product_id integer PRIMARY KEY,
    product_name varchar(100),
    price decimal
);

CREATE TABLE orders (
    order_id integer PRIMARY KEY,
    customer_id integer,
    order_date date
);

CREATE TABLE order_items (
    order_id integer,
    product_id integer,
    quantity integer
);

INSERT INTO customers (customer_id, first_name, last_name, email) VALUES
(1, 'John', 'Doe', 'johndoe@email.com'),
(2, 'Jane', 'Smith', 'janesmith@email.com'),
(3, 'Bob', 'Johnson', 'bobjohnson@email.com'),
(4, 'Alice', 'Brown', 'alicebrown@email.com'),
(5, 'Charlie', 'Davis', 'charliedavis@email.com'),
(6, 'Eva', 'Fisher', 'evafisher@email.com'),
(7, 'George', 'Harris', 'georgeharris@email.com'),
(8, 'Ivy', 'Jones', 'ivyjones@email.com'),
(9, 'Kevin', 'Miller', 'kevinmiller@email.com'),
(10, 'Lily', 'Nelson', 'lilynelson@email.com'),
(11, 'Oliver', 'Patterson', 'oliverpatterson@email.com'),
(12, 'Quinn', 'Roberts', 'quinnroberts@email.com'),
(13, 'Sophia', 'Thomas', 'sophiathomas@email.com');

INSERT INTO products (product_id, product_name, price) VALUES
(1, 'Product A', 10.00),
(2, 'Product B', 15.00),
(3, 'Product C', 20.00),
(4, 'Product D', 25.00),
(5, 'Product E', 30.00),
(6, 'Product F', 35.00),
(7, 'Product G', 40.00),
(8, 'Product H', 45.00),
(9, 'Product I', 50.00),
(10, 'Product J', 55.00),
(11, 'Product K', 60.00),
(12, 'Product L', 65.00),
(13, 'Product M', 70.00);

INSERT INTO orders (order_id, customer_id, order_date) VALUES
(1, 1, '2023-05-01'),
(2, 2, '2023-05-02'),
(3, 3, '2023-05-03'),
(4, 1, '2023-05-04'),
(5, 2, '2023-05-05'),
(6, 3, '2023-05-06'),
(7, 4, '2023-05-07'),
(8, 5, '2023-05-08'),
(9, 6, '2023-05-09'),
(10, 7, '2023-05-10'),
(11, 8, '2023-05-11'),
(12, 9, '2023-05-12'),
(13, 10, '2023-05-13'),
(14, 11, '2023-05-14'),
(15, 12, '2023-05-15'),
(16, 13, '2023-05-16');

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 2),
(1, 2, 1),
(2, 2, 1),
(2, 3, 3),
(3, 1, 1),
(3, 3, 2),
(4, 2, 4),
(4, 3, 1),
(5, 1, 1),
(5, 3, 2),
(6, 2, 3),
(6, 1, 1),
(7, 4, 1),
(7, 5, 2),
(8, 6, 3),
(8, 7, 1),
(9, 8, 2),
(9, 9, 1),
(10, 10, 3),
(10, 11, 2),
(11, 12, 1),
(11, 13, 3),
(12, 4, 2),
(12, 5, 1),
(13, 6, 3),
(13, 7, 2),
(14, 8, 1),
(14, 9, 2),
(15, 10, 3),
(15, 11, 1),
(16, 12, 2),
(16, 13, 3);

-- Case Study Questions

#1) Which product has the highest price? Only return a single row.
    Select * from products order by price desc limit 1;
    
    Select product_name from products where price = (Select Max(price) from products) ;

#2) Which customer has made the most orders?
	
    with get_detail as (
    select c.customer_id, count(*) as Orders
    from customers c
    inner join orders o
    on c.customer_id = o.customer_id
    group by 1
    )
   ,max_order_details as ( 
   select max(Orders) as Max_Order from get_detail 
   )
    select a.* 
    from get_detail a inner join max_order_details b
    on a.Orders = b.Max_order
    order by a.customer_id; 
    
#3) What’s the total revenue per product?
     
      With db as (
         select product_id, sum(quantity) as quantity from order_items group by product_id
)
     select p.product_id, p.product_name, p.price, d.quantity, (d.quantity * p.price ) AS PRICE from db d inner join products p
     on d.product_id = p.product_id
     order by 1;
     
 #4) Find the day with the highest revenue.
	
	select o.order_date, max(oi.quantity * p.price) as revenue from orders o 
	join order_items oi on o.order_id = oi.order_id
	join products p on p.product_id = oi.product_id
    group by o.order_date
    order by revenue desc limit 2;
    
#5) Find the first order (by date) for each customer.
      
     with db as (
     select c.*, o.order_date,
     Dense_rank () OVER ( partition by customer_id order by order_date) as Rank_order
     from customers c 
      inner join orders o 
      on c.customer_id = o.customer_id
      order by 1
     )
 select *
 from db
 where Rank_order = 1;
            
#6) Find the top 3 customers who have ordered the most distinct products
    select c.customer_id, c.first_name, c.last_name,  count(distinct(oi.product_id)) as Orders
    from customers c
    inner join orders o
    inner join order_items oi
    on c.customer_id = o.customer_id
    and o.order_id = oi.order_id
  group by c.customer_id
order by Orders desc limit 3;   
    
#7) Which product has been bought the least in terms of quantity?

     with db as (select p.product_id,p.product_name, sum(quantity) as quantity_sold
     from products p
     inner join order_items o
     on p.product_id = o.product_id
     group by product_id 
     order by quantity_sold )
     
     , db2 as ( select min(quantity_sold) as min_qs from db)
     
     select product_id,product_name, min_qs
     from db a
     inner join db2 b
     on a.quantity_sold = b.min_qs;

#8) What is the median order total?

with db as (select o.order_id, sum(p.price* o.quantity) as revenue 
from order_items o inner join products p on o.product_id = p.product_id 
group by 1)

, ranked_data as(SELECT revenue,
	ROW_NUMBER() OVER (ORDER BY revenue) AS row_num,
    COUNT(*) OVER () AS total_rows
 FROM db)
 
SELECT AVG(revenue) AS Median
FROM ranked_data
WHERE row_num IN ((total_rows + 1) / 2, (total_rows + 2) / 2);  

#9) For each order, determine if it was ‘Expensive’ (total over 300), ‘Affordable’ (total over 100), or ‘Cheap’.

with db as (select o.order_id, sum(p.price* o.quantity) as revenue
from order_items o inner join products p on o.product_id = p.product_id 
group by 1
order by 2)

select d.*, Case 
when revenue > 300 then "Expensive"
when revenue > 100 then "Affordable"
Else "Cheap"
end as Type_of_order 
from db d;

#10) Find customers who have ordered the product with the highest price

with db as (
select a.customer_id, b.order_id, d.product_id, d.product_name,  sum(c.quantity* d.price) as Total,
dense_rank () over (order by sum(c.quantity* d.price) desc) as Rankk
from customers a inner join orders b inner join order_items c inner join products d
on a.customer_id = b.customer_id
and b.order_id = c.order_id
and c.product_id = d.product_id
group by a.customer_id, b.order_id, 
	d.product_id, 
	d.product_name)
    
    select d.customer_id, d.order_id, d.product_id, d.product_name, d.Total, d.Rankk, concat(c.first_name, " ", c.last_name) as Name
    from db d
    inner join customers c
    on d.customer_id = c.customer_id
    order by d.Rankk limit 2;



