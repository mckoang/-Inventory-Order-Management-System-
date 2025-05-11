Inventory & Order Management System
A relational database project built to simulate and manage the operations of an e-commerce business. This system enables the management of products, customers, and orders while tracking inventory changes and generating insightful business metrics.

📌 Problem Statement
Managing inventory and orders efficiently is crucial for any e-commerce business. Companies face challenges ensuring accurate stock levels, processing multi-product orders, tracking changes, and generating business insights in real-time. This project solves these issues by implementing a database-driven system that ensures data integrity, automates key processes, and provides actionable insights into customer and inventory behavior.

🚀 Features
📦 Product and inventory tracking

🧾 Order and multi-product order processing

👥 Customer data management

🔄 Stock replenishment and inventory change logging

📊 Business insights and customer spending categorization

🧠 Views for simplified access to summarized order and stock data

⚙️ Automation of order calculations and stock updates

🛠️ Technologies Used
PostgreSQL

SQL (DDL & DML)

Relational database design principles

🧮 Schema Overview
Products: Stores product details (ID, name, category, price, quantity, reorder level)

Customers: Basic customer info (ID, name, email, phone)

Orders: Captures each order (ID, customer, date, total amount)

Order_Details: Item-level details per order

Inventory_Logs: Records all inventory changes with timestamps

📈 Business Logic & Automation
Deducts stock automatically when orders are placed

Updates inventory logs in real time

Calculates total order amounts dynamically

Applies bulk discounts based on quantity

Flags products below reorder levels

Categorizes customers into Bronze, Silver, or Gold tiers based on spending

📋 Example Views
order_summary_view: Summarizes orders with customer name, total items, and order value

low_stock_view: Highlights products needing restocking

📊 Sample Insights Generated
Total spending per customer

Low-stock products and replenishment needs

Customer purchase behavior and discount eligibility
