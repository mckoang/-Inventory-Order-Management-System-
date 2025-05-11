--creating Product tableCreate Table products (
     product_id SERIAL PRIMARY KEY,
	 name VARCHAR(100),
	 category VARCHAR(50),
	 price DECIMAL(10,2),
	 stock_quantity int,
	 reorder_level int 
);

--changing a column name using Alter

ALTER TABLE products
rename column name to product_name

select * from products

--Inserting into Products

INSERT INTO products(name,category,price,stock_quantity,reorder_level)
VALUES
('Wireless Mouse', 'Electronics', 25.50, 100, 20),
('Laptop Sleeve', 'Accessories', 15.00, 50, 10),
('USB-C Cable', 'Electronics', 10.99, 200, 30);


--Creating Customers Table

Create Table Customers(
             customer_id SERIAL PRIMARY KEY,
			 customer_name VARCHAR(100),
			 email VARCHAR(100),
			 phone_number VARCHAR(100)
);

--Inserting into Customers table
INSERT INTO customers(customer_name, email, phone_number)
VALUES
('Abigail Johnson', 'alice@gmail.com', '1234567890'),
('Bob Smith', 'bob@yahoo.com', '0987654321'),
('Kelvin Adam', 'kevadam@gmail.com', '0234567987');

--Creating 0rders table

CREATE Table Orders(
            order_id SERIAL PRIMARY KEY,
			customer_id int REFERENCES customers(customer_id),
			order_date DATE,
			total_amount DECIMAL(10,2)
);

--Inserting into Orders table

INSERT INTO orders (customer_id, order_date, total_amount)
VALUES 
(1, CURRENT_DATE, 36.49),
(2, CURRENT_DATE, 45.38),
(3, CURRENT_DATE, 28.39);


--Creating order_details

CREATE Table order_details(
            order_detail_id SERIAL PRIMARY KEY,
            order_id INT REFERENCES orders(order_id),
            product_id INT REFERENCES products(product_id),
            quantity INT,
            price DECIMAL(10, 2)
);

--Inserting into order_details table
INSERT INTO order_details(order_id, product_id, quantity, price)
VALUES
(1, 1, 1, 25.50),
(1, 3, 1, 10.99),
(1, 2, 2, 11.81);

--Creating table inventory_logs

CREATE TABLE inventory_logs (
    log_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(product_id),
    change_type VARCHAR(50),  -- 'order' or 'replenishment'
    quantity_changed INT,     -- positive or negative change
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

--Inserting into inventory_logs
INSERT INTO inventory_logs (product_id, change_type, quantity_changed)
VALUES 
(1, 'order', -2),
(2, 'restock', 10),
(3, 'order', -1);

select * from orders
BEGIN;
-- Insert a new order
INSERT INTO orders (customer_id, order_date, total_amount)
VALUES (1, CURRENT_DATE, (2 * 25.50) + (1 * 10.99))
RETURNING order_id;

-- Step 2: Insert into order_details
INSERT INTO order_details (order_id, product_id, quantity, price)
VALUES 
(1, 1, 2, 25.50),
(2, 3, 1, 10.99);

-- Step 3: Update product stock
UPDATE products SET stock_quantity = stock_quantity - 2 WHERE product_id = 1;
UPDATE products SET stock_quantity = stock_quantity - 1 WHERE product_id = 3;

-- Step 4: Log inventory changes
INSERT INTO inventory_logs (product_id, change_type, quantity_changed)
VALUES 
(1, 'Order', -2),
(3, 'Order', -1);

COMMIT;

-- Query to track stock change history for a product
SELECT * FROM inventory_logs
WHERE product_id = 1 
ORDER BY change_date DESC;


--Viewing all orders placed by a customer with id =1
SELECT 
    o.order_id,
    o.order_date,
    o.total_amount,
    SUM(od.quantity) AS total_items
FROM 
    orders o
JOIN 
    order_details od ON o.order_id = od.order_id
WHERE 
    o.customer_id = 1
GROUP BY 
    o.order_id, o.order_date, o.total_amount;

--Identifying low stock products
SELECT 
    product_id,
    product_name,
    stock_quantity,
    reorder_level
FROM 
    products
WHERE 
    stock_quantity < reorder_level;

--Categorizing customers based on spending
SELECT 
    c.customer_id,
    c.customer_name,
    SUM(o.total_amount) AS total_spent,
    CASE 
        WHEN SUM(o.total_amount) >= 1000 THEN 'Gold'
        WHEN SUM(o.total_amount) >= 500 THEN 'Silver'
        ELSE 'Bronze'
    END AS customer_tier
FROM 
    customers c
JOIN 
    orders o ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id, c.customer_name;


--Applying discount on bulk purchases
SELECT 
    product_id,
    quantity,
    price,
    CASE 
        WHEN quantity >= 10 THEN price * 0.90  -- 10% discount
        WHEN quantity >= 5 THEN price * 0.95   -- 5% discount
        ELSE price
    END AS discounted_price
FROM 
    order_details;

--STOCK REPLENISH SYSTEM
--Identifying low stock products
	SELECT 
    product_id, product_name, stock_quantity, reorder_level
FROM
    products
WHERE 
    stock_quantity < reorder_level;

--Replenish stock

UPDATE products
SET stock_quantity = stock_quantity + 50
WHERE product_id = 2;  -- example product


--Logging

INSERT INTO inventory_logs (product_id, change_type, quantity_changed)
VALUES (2, 'replenishment', 50);


--Auto uodate stock after an order
CREATE OR REPLACE FUNCTION deduct_stock()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE products
  SET stock_quantity = stock_quantity - NEW.quantity
  WHERE product_id = NEW.product_id;

  INSERT INTO inventory_logs (product_id, change_type, quantity_changed)
  VALUES (NEW.product_id, 'sale', -NEW.quantity);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_deduct_stock
AFTER INSERT ON order_details
FOR EACH ROW
EXECUTE FUNCTION deduct_stock();

-- Auto calculate order amount
SELECT SUM(quantity * price)
FROM order_details
WHERE order_id = 1;

--Updating orders
UPDATE orders
SET total_amount = 55.99
WHERE order_id = 1;

--Creating Views
CREATE VIEW order_summary AS
SELECT 
    o.order_id,
    c.customer_name AS customer_name,
    o.order_date,
    o.total_amount,
    SUM(od.quantity) AS total_items
FROM 
    orders o
JOIN 
    customers c ON o.customer_id = c.customer_id
JOIN 
    order_details od ON o.order_id = od.order_id
GROUP BY 
    o.order_id, c.customer_name, o.order_date, o.total_amount;

--Orders that need restocking
CREATE VIEW low_stock_products AS
SELECT 
    product_id,
    product_name,
    stock_quantity,
    reorder_level
FROM 
    products
WHERE 
    stock_quantity < reorder_level;


--Optimizing queries

-- Index on foreign key columns
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_order_details_order_id ON order_details(order_id);
CREATE INDEX idx_order_details_product_id ON order_details(product_id);

-- Index on stock_quantity to speed up low stock queries
CREATE INDEX idx_products_stock_quantity ON products(stock_quantity);