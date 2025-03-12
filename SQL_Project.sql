create database pizzahut;

USE pizzahut;
SELECT count(order_id) FROm orders;

create table orders (
order_id int not null,
order_date date not null, 
order_time time not null,
primary key (order_id) );

create table orders_details (
order_details_id int not null,
order_id int not null,
pizza_id text not null, 
quantity int not null,
primary key (order_details_id) );
 
-- Retrieve the total number of orders placed.
SELECT COUNT(order_id) AS total_orders  
FROM orders; 

-- Calculate the total revenue generated from pizza sales.
SELECT ROUND(SUM(orders_details.quantity * pizzas.price), 2) AS total_sales  
FROM orders_details  
JOIN pizzas ON pizzas.pizza_id = orders_details.pizza_id;



-- Identify the highest-priced pizza.
SELECT pizza_types.name, pizzas.price
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT pizzas.size, COUNT(orders_details.order_details_id) AS order_count
FROM pizzas JOIN orders_details
ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size 
ORDER BY order_count DESC;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT pizza_types.name, SUM(orders_details.quantity) AS quantity
FROM pizza_types 
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name 
ORDER BY quantity DESC 
LIMIT 5;


-- Join the necessary tables to find the total quantity of each pizza category category.
SELECT pizza_types.category,
SUM(orders_details.quantity) AS quantity
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN orders_details
ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category 
ORDER BY quantity DESC;

-- Determine the distribution of orders by hour of the day.
SELECT HOUR (order_time) AS HOUR, COUNT(order_id) AS order_count
FROM orders
GROUP BY HOUR(order_time);


-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT category, COUNT(NAME) 
FROM pizza_types
GROUP BY category; 

-- the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(quantity),0) AS avg_pizza_order_per_day FROM 
(SELECT orders.order_date, SUM(orders_details.quantity) AS quantity 
FROM orders 
JOIN orders_details
ON orders.order_id = orders_details.order_id
GROUP BY orders.order_date) AS order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT pizza_types.NAME,
SUM(orders_details.quantity* pizzas.price )AS revenue
FROM pizza_types 
JOIN pizzas
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN orders_details
ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.NAME ORDER BY revenue DESC LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT pizza_types.category,
ROUND(SUM(orders_details.quantity * pizzas.price) / 
(SELECT SUM(orders_details.quantity * pizzas.price) 
FROM orders_details 
JOIN pizzas ON pizzas.pizza_id = orders_details.pizza_id) * 100, 2) AS revenue_percentage
FROM pizza_types 
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id 
JOIN orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category 
ORDER BY revenue_percentage DESC;


-- Analyze the cumulative revenue generated over time.
 SELECT order_date,
 SUM(revenue) over(ORDER BY order_date) AS cum_revenue
 FROM
 (SELECT orders.order_date,
 SUM(orders_details.quantity * pizzas.price) AS revenue
 FROM order_details JOIN pizzas
 ON orders_details.pizza_id = pizzas.pizza_id
 JOIN orders
 ON orders.order_id = orders_details.order_id 
 GROUP BY orders.order_date) AS sales;
 
 -- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT name, revenue 
FROM 
(SELECT category, name, revenue,
RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rn
FROM 
(SELECT pizza_types.category, pizza_types.name,
SUM(orders_details.quantity * pizzas.price) AS revenue
FROM pizza_types 
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category, pizza_types.name) AS a
) AS b 
WHERE rn <= 3;

