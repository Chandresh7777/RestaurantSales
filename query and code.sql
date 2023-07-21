 CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
 ('A', '2021-01-07'),
  ('B', '2021-01-09'), 
  ('C', '2021-01-11')
  SELECT * FROM members

  
  /* What is the total amount each customer spent at the restaurant? */
  SELECT product_id, product_name, price from menu
  order by price DESC
  limit 5;
  
 /* How many days has each customer visited the restaurant? */
 SELECT customer_id , count(order_date) as day from sales
  GROUP by customer_id
  order by day DESC;
  /* What was the first item from the menu purchased by each customer? */ */
SELECT 
    m.product_id,
    m.product_name,
    m.price,
    s.customer_id,
    s.order_date
FROM
    menu AS m
JOIN
    sales AS s ON m.product_id = s.product_id
JOIN
    members AS mb ON s.customer_id = mb.customer_id
WHERE
    s.order_date = (
        SELECT 
            MIN(order_date) 
        FROM 
            sales AS s2 
        WHERE 
            s2.customer_id = s.customer_id
    );
  /*What is the most purchased item on the menu and how many times was it purchased by all customers? */
  SELECT 
    m.product_id,
    m.product_name,
    m.price,
    COUNT(s.product_id) AS total_purchases
FROM
    menu AS m
JOIN
    sales AS s ON m.product_id = s.product_id
GROUP BY
    m.product_id,
    m.product_name,
    m.price
ORDER BY
    total_purchases DESC;
  
 /* Which item was the most popular for each customer? */ 
 WITH ranksale as (
 SELECT 
   customer_id,
   product_id,
   rank() over(partition by customer_id order by count(*) DESC ) as purchased_rank
   from sales
   GROUP by customer_id, 
   product_id
 )
   
   SELECT rs.product_id,
  rs.purchased_rank,
  rs.customer_id,
  menu.product_name,
  menu.price
   from ranksale as rs
   join menu on rs.product_id = menu.product_id  
   where rs.purchased_rank = 1
   order by price DESC;
   /*Which item was purchased first by the customer after they became a member?*/
   WITH firstpurchase as (
     SELECT 
   members.customer_id, 
   members.join_date,
   menu.product_name,
   menu.product_id,
   sales.order_date,
   ROW_NUMBER() OVER (PARTITION BY members.customer_id ORDER BY sales.order_date) AS purchase_rank
   from menu
     
   join sales on menu.product_id= sales.product_id
   join members on sales.customer_id =members.customer_id
  WHERE sales.order_date >= members.join_date
     )
     SELECT
     customer_id,
     product_id,
     join_date,
     order_date,
     product_name
   from firstpurchase 
   WHERE 
    purchase_rank = 1;
/*Which item was purchased just before the customer became a member? */
 WITH firstpurchase as (
     SELECT 
   members.customer_id, 
   members.join_date,
   menu.product_name,
   menu.product_id,
   sales.order_date,
   ROW_NUMBER() OVER (PARTITION BY members.customer_id ORDER BY sales.order_date) AS purchase_rank
   from menu
     
   join sales on menu.product_id= sales.product_id
   join members on sales.customer_id =members.customer_id
  WHERE sales.order_date <= members.join_date
     )
     SELECT
     customer_id,
     product_id,
     join_date,
     order_date,
     product_name
   from firstpurchase 
   WHERE 
    purchase_rank = 1;
    
  /*  What is the total items and amount spent for each member before they became a member? */
 
  with prepurchasingmeaber as 
  (
    SELECT 
    sales.customer_id,
    count(DISTINCt sales.product_id) as totalitems,
    sum(menu.price) as totalspent
    from sales 
    JOIN menu on menu.product_id= sales.product_id
    join members on members.customer_id = sales.customer_id
    WHERE sales.order_date < members.join_date
    GROUP by sales.customer_id
   )
   SELECT 
    prepurchasingmeaber.customer_id,
    prepurchasingmeaber.totalitems,
    prepurchasingmeaber.totalspent,
    members.join_date
FROM 
   prepurchasingmeaber 
JOIN 
    members  ON prepurchasingmeaber.customer_id = members.customer_id;
    