CREATE TABLE SUPPLIERS (
    supplier_id INT PRIMARY KEY,
    first_name VARCHAR2(30) NOT NULL,
    last_name VARCHAR2(30) NOT NULL,
    email VARCHAR(30) UNIQUE NOT NULL,
    phone_number VARCHAR2(20)
); 
CREATE TABLE PRODUCTS (
    flower_id INT PRIMARY KEY,
    flower_name VARCHAR2(50) NOT NULL,
    price NUMBER(10, 2) NOT NULL,
    supplier_id INT NOT NULL,
    FOREIGN KEY (supplier_id) REFERENCES SUPPLIERS(supplier_id)
); 
CREATE TABLE FLOWER_CUSTOMERS (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(30) UNIQUE NOT NULL,
    phone_number VARCHAR2(15),
    join_date DATE NOT NULL
);  
CREATE TABLE SALES (
    sales_id INT PRIMARY KEY,
    flower_id INT NOT NULL,
    customer_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity INT NOT NULL,
    price NUMBER(10, 2) NOT NULL,
    FOREIGN KEY (flower_id) REFERENCES PRODUCTS(flower_id),
    FOREIGN KEY (customer_id) REFERENCES FLOWER_CUSTOMERS(customer_id)
);  
CREATE TABLE ORDER_HISTORY (
    flower_id INT NOT NULL,
    supplier_id INT NOT NULL,
    supply_date DATE NOT NULL,
    quantity INT NOT NULL,
    price NUMBER(10, 2) NOT NULL,
    PRIMARY KEY (flower_id, supplier_id, supply_date),
    FOREIGN KEY (flower_id) REFERENCES PRODUCTS(flower_id),
    FOREIGN KEY (supplier_id) REFERENCES SUPPLIERS(supplier_id)
);  
CREATE TABLE STOCK (
    stock_id INT PRIMARY KEY,
    flower_id INT NOT NULL,
    stock_change INT NOT NULL,
    change_date DATE NOT NULL,
    FOREIGN KEY (flower_id) REFERENCES PRODUCTS(flower_id)
);  
CREATE TABLE REVIEWS (
    review_id NUMBER PRIMARY KEY,
    customer_id NUMBER NOT NULL,
    flower_id NUMBER NOT NULL,
    flower_name VARCHAR2(20),
    rating NUMBER CHECK (rating BETWEEN 1 AND 5)
   
); 
 

ALTER TABLE PRODUCTS ADD stock NUMBER DEFAULT 0;
  
ALTER TABLE STOCK DROP COLUMN stock_change;
 
ALTER TABLE FLOWER_CUSTOMERS MODIFY phone_number VARCHAR2(20);
 
CREATE TABLE PRODUCTS_BACKUP AS SELECT * FROM PRODUCTS;
 
DROP TABLE PRODUCTS_BACKUP;
 
ALTER TABLE CUSTOMERS ADD join_date DATE DEFAULT SYSDATE;
	
ALTER TABLE REVIEWS ADD review_text VARCHAR2(400);
 
INSERT INTO SUPPLIERS (supplier_id, first_name, last_name, email, phone_number)
VALUES (108, 'John', 'Smith', 'john.smith@yahoo.com', '1234567890');

  INSERT INTO PRODUCTS (flower_id, flower_name,  price, supplier_id, stock)
VALUES (3, 'Lily', 4.00, 103, 50);

INSERT INTO PRODUCTS (flower_id, flower_name, description, price, supplier_id)
VALUES (1, 'Rose', 'Red rose, fresh and beautiful', 2.50, 101);

UPDATE PRODUCTS
SET price = 19, stock= 50
WHERE flower_id = 1;
 
UPDATE SALES
SET quantity=10
WHERE customer_id=1002;
 
INSERT INTO REVIEWS (review_id, customer_id, flower_id, flower_name, rating)
VALUES (5, 1005, 3, 'Lily', 2);  
DELETE FROM REVIEWS
WHERE rating < 5;
 

--Add a new customer or update their phone number if they already exist.
MERGE INTO flower_customers fc
USING (
    SELECT 1020 AS customer_id, 'Wow' AS first_name, 'Martinez' AS last_name, 
           'wowm@yahoo.com' AS email, '1234567888' AS phone_number
    FROM dual
) src
ON (fc.customer_id = src.customer_id)
WHEN MATCHED THEN
    UPDATE SET fc.phone_number = src.phone_number
WHEN NOT MATCHED THEN
    INSERT (customer_id, first_name, last_name, email, phone_number, join_date)
    VALUES (src.customer_id, src.first_name, src.last_name, src.email, src.phone_number, SYSDATE);
 

--Change the phone number of the customer with the id=1009 to 1010101010.
UPDATE flower_customers
SET phone_number = 1010101010
WHERE customer_id = 1009;
 


SELECT * FROM SUPPLIERS ;  
--1.shows the flowers which have the flower_id 2,3,4 or 5.

SELECT flower_id, flower_name FROM PRODUCTS WHERE flower_id IN (2, 3, 4, 5);
 
--2.Changes the stock with 30 where the flower_id is 5.
UPDATE PRODUCTS
SET stock = 30
WHERE flower_id = 5;
 
--3.Changes the email of the person with  the customer_id 1005, when is michael@yahoo.com .
UPDATE FLOWER_CUSTOMERS
SET email = 'michael@yahoo.com'
WHERE customer_id = 1005;
 
--4.Show all the cutomers that bought at least 5 products 
SELECT f.*
FROM flower_customers f, sales s
WHERE f.customer_id = s.customer_id AND s.quantity>=5 ;
 
--5.select the customers that have the letter a in their first_name
SELECT customer_id, first_name, last_name
FROM flower_customers
WHERE first_name LIKE '%a%';
 
--6.select the flower_name with the price >= 1 and price <= 10
SELECT flower_name
FROM products
WHERE price BETWEEN 1 AND 10;
 
--7.Show the customers that do not have a phone number inserted
SELECT *
FROM flower_customers
WHERE phone_number IS NULL;
 
--8.Show the total number of suppliers that supplied each product
SELECT supplier_id, COUNT(supplier_id) AS total_products
FROM PRODUCTS
GROUP BY supplier_id;
 
 --9. Select the flowers with an average rating bigger than 3
SELECT p.flower_id,p.flower_name, AVG(r.rating) AS avg_rating
FROM REVIEWS r,products p
GROUP BY p.flower_id,p.flower_name
HAVING AVG(r.rating) > 3;
 
--10.Select the first 5 characters from the email section for the customers
SELECT SUBSTR(email, 1, 5) AS email_prefix
FROM FLOWER_CUSTOMERS;
 
--11.Show the expensive flowers(price >19), moderate flowers( price > = 4 and price < = 19) and the affordable flowers(the rest)
SELECT flower_name,
       CASE 
         WHEN price > 19 THEN 'Expensive' 
         WHEN price BETWEEN 4 AND  19 THEN 'Moderate' 
         ELSE 'Affordable' 
       END AS price_category
FROM PRODUCTS;
 
--12. select the customers that bought a product later than 01 jan 2025, but sooner than 10 feb 2025
SELECT * 
FROM sales
WHERE sale_date BETWEEN TO_DATE('01 JAN 2025', 'DD MON YYYY') AND TO_DATE('10 FEB 2025', 'DD MON YYYY');
 



--13. Select the flower name and supplier ID from the PRODUCTS table, for the supplier whose supplier ID matches that of the person with the first name 'Iulia'
SELECT flower_name , supplier_id
FROM products
WHERE supplier_id = (SELECT supplier_id FROM suppliers WHERE first_name = 'Iulia');
 
--14. Create a new table who prints the flower name and the average rating >= to 4
CREATE TABLE Top_Rated_Products AS
SELECT p.flower_name, AVG(r.rating) AS avg_rating
FROM products p,reviews r
WHERE p.flower_id = r.flower_id
GROUP BY p.flower_name
HAVING AVG(r.rating) >= 4;
 
--15. Raise with 110% the price of the product with the supplier_id=102;
UPDATE products
SET price = price * 1.1
WHERE supplier_id = 102;
 
--Indexing the price column improves the performance of queries that frequently filter or sort by this column
--16. create an index for the price of the flowers
CREATE INDEX idx_flower_price ON PRODUCTS(price);
 
--17.customers who have spent more than the average spending of all customers.
SELECT customer_id, SUM(price * quantity) AS total_spent
FROM sales s
GROUP BY customer_id
HAVING SUM(price * quantity) > (
    SELECT AVG(SUM(price * quantity))
    FROM sales
    GROUP BY customer_id
);
 
--18.suppliers who have supplied more than 60 items.
SELECT supplier_id, SUM(quantity) AS total_supplied
FROM order_history
GROUP BY supplier_id
HAVING SUM(quantity) > 60;
 
--19. Create a synonym for the suppliers table.
CREATE SYNONYM supp FOR suppliers;
 
--20. Select the supplier with the supplier_id=101 from the suppliers table using the synonym.
SELECT *
FROM supp
WHERE supplier_id = 101;
  

select * from products;
select * from flower_customers;
select * from reviews;
select * from sales;
select * from stock;
select * from suppliers;
select * from order_history;

INSERT INTO REVIEWS (review_id, customer_id, flower_id, flower_name, rating)
VALUES (1, 1003, 5, 'Sunflower', 3);
