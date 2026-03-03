/*
Lecture 03: MYSQL Datatypes and Various Constraints Used in MySQL 
Objective: Learn various data types and constraints to build effective database 
Author : Chandan Chaudhari
*/

/*

-- PART 1: MySQL DATA TYPES - Complete Examples

-- 1.1 NUMERIC DATA TYPES EXAMPLE
CREATE DATABASE IF NOT EXISTS Lecture03_Demo;
USE Lecture03_Demo;

-- Drop tables if they exist (for clean re-run)
DROP TABLE IF EXISTS salary_example;
DROP TABLE IF EXISTS string_example;
DROP TABLE IF EXISTS datetime_example;
DROP TABLE IF EXISTS binary_example;

-- Numeric Types Demonstration
CREATE TABLE salary_example (
emp_id INT,
monthly_salary DECIMAL(10,2), -- Total 10 digits, 2 after decimal (e.g., 12345678.99)
tax_percentage FLOAT, -- Approximate: 5.25%
annual_bonus DECIMAL(8,2) -- e.g., 50000.00
);

-- Insert sample data for numeric types
INSERT INTO salary_example VALUES
(1, 75000.50, 5.25, 100000.00),
(2, 45000.75, 7.50, 50000.00),
(3, 120000.00, 10.00, 150000.00);

SELECT * FROM salary_example;

-- 1.2 STRING DATA TYPES EXAMPLE
CREATE TABLE string_example (
emp_code CHAR(10), -- Fixed: 'EMP0012345'
emp_name VARCHAR(100), -- Variable: 'Chandan Chaudhari'
emp_bio TEXT, -- Long description
gender ENUM('M', 'F', 'Other'), -- Single choice only
skills SET('Java', 'SQL', 'Python', 'AWS') -- Multiple choices
);

-- Insert sample data for string types
INSERT INTO string_example VALUES
('EMP001', 'Chandan Chaudhari', 'Senior Database Expert', 'M', 'SQL,Java'),
('EMP002', 'Vidisha Sharma', 'Data Analyst with 5 years experience', 'F', 'SQL,Python'),
('EMP003', 'Sanoj Patel', 'Full Stack Developer', 'M', 'Java,Python,AWS');

SELECT * FROM string_example;

-- 1.3 DATE AND TIME DATA TYPES EXAMPLE
CREATE TABLE datetime_example (
emp_id INT,
birth_date DATE, -- '1990-05-15'
shift_start TIME, -- '09:00:00'
last_login DATETIME, -- '2026-01-17 14:30:00'
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
joining_year YEAR -- '2026'
);

-- Insert sample data for date/time types
INSERT INTO datetime_example (emp_id, birth_date, shift_start, last_login, joining_year) VALUES
(1, '1990-05-15', '09:00:00', '2026-03-03 10:30:00', 2026),
(2, '1988-12-20', '14:00:00', '2026-03-03 09:15:00', 2025),
(3, '1995-08-10', '18:00:00', '2026-03-02 23:45:00', 2026);

SELECT * FROM datetime_example;

-- 1.4 BINARY AND OTHER DATA TYPES EXAMPLE
CREATE TABLE binary_example (
profile_pic BLOB, -- Profile image
contract_doc MEDIUMBLOB, -- PDF document
preferences JSON, -- {"theme": "dark", "language": "en"}
is_active BOOLEAN DEFAULT TRUE, -- TRUE = 1, FALSE = 0
location POINT -- GPS coordinates
);

-- Insert sample data for binary/other types
INSERT INTO binary_example (preferences, is_active) VALUES
('{"theme": "dark", "language": "en", "notifications": true}', TRUE),
('{"theme": "light", "language": "hi", "notifications": false}', FALSE);

SELECT preferences, is_active FROM binary_example;


-- PART 2: MySQL CONSTRAINTS - Complete Examples

-- Drop tables if they exist (for clean re-run)
DROP TABLE IF EXISTS employees_notnull;
DROP TABLE IF EXISTS employees_unique;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS employees_check;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS employees_default;
DROP TABLE IF EXISTS employees_auto;
DROP TABLE IF EXISTS departments_auto;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS order_items;

-- 2.3.1 NOT NULL Constraint
CREATE TABLE employees_notnull (
emp_id INT PRIMARY KEY,
emp_name VARCHAR(100) NOT NULL, -- Must provide name
email VARCHAR(100) NOT NULL, -- Must provide email
salary DECIMAL(10,2) -- Can be NULL
);

-- Insert valid data
INSERT INTO employees_notnull VALUES (1, 'Chandan Chaudhari', 'chandan@email.com', 75000.00);
INSERT INTO employees_notnull VALUES (2, 'Vidisha Sharma', 'vidisha@email.com', NULL); -- Salary can be NULL

-- This will fail - try uncommenting to see error
-- INSERT INTO employees_notnull VALUES (3, NULL, 'test@email.com', 50000.00); -- Name cannot be NULL

SELECT * FROM employees_notnull;

-- 2.3.2 UNIQUE Constraint
CREATE TABLE employees_unique (
emp_id INT PRIMARY KEY,
emp_name VARCHAR(100),
email VARCHAR(100) UNIQUE, -- No duplicate emails
pan_card VARCHAR(20) UNIQUE -- No duplicate PAN cards
);

-- Insert valid data
INSERT INTO employees_unique VALUES (1, 'Chandan Chaudhari', 'chandan@email.com', 'ABCDE1234F');
INSERT INTO employees_unique VALUES (2, 'Vidisha Sharma', 'vidisha@email.com', 'XYZPD7890K');

-- This will fail - try uncommenting to see error
-- INSERT INTO employees_unique VALUES (3, 'Sanoj Patel', 'chandan@email.com', 'LMNOP5678R'); -- Duplicate email

SELECT * FROM employees_unique;

-- 2.3.3 PRIMARY KEY Constraint
-- Single column primary key
CREATE TABLE departments (
dept_id INT PRIMARY KEY, -- Unique and NOT NULL
dept_name VARCHAR(100) NOT NULL
);

-- Insert valid data
INSERT INTO departments VALUES (1, 'Human Resources');
INSERT INTO departments VALUES (2, 'Information Technology');
INSERT INTO departments VALUES (3, 'Finance');

-- This will fail - try uncommenting to see error
-- INSERT INTO departments VALUES (1, 'Marketing'); -- Duplicate primary key

SELECT * FROM departments;

-- Composite primary key example
CREATE TABLE course_enrollment (
student_id INT,
course_id INT,
enrollment_date DATE,
PRIMARY KEY (student_id, course_id) -- Combined uniqueness
);

-- Insert valid data
INSERT INTO course_enrollment VALUES (1, 101, '2026-01-15');
INSERT INTO course_enrollment VALUES (1, 102, '2026-01-16'); -- Same student, different course
INSERT INTO course_enrollment VALUES (2, 101, '2026-01-15'); -- Different student, same course

-- This will fail - try uncommenting to see error
-- INSERT INTO course_enrollment VALUES (1, 101, '2026-01-20'); -- Duplicate combination

SELECT * FROM course_enrollment;

-- 2.3.4 FOREIGN KEY Constraint
CREATE TABLE customers (
customer_id INT PRIMARY KEY,
customer_name VARCHAR(100) NOT NULL,
email VARCHAR(100) UNIQUE,
city VARCHAR(50)
);

INSERT INTO customers VALUES
(1, 'Rahul Singh', 'rahul@email.com', 'Mumbai'),
(2, 'Priya Patel', 'priya@email.com', 'Delhi'),
(3, 'Amit Kumar', 'amit@email.com', 'Bangalore');

CREATE TABLE orders (
order_id INT PRIMARY KEY,
customer_id INT,
order_date DATE,
amount DECIMAL(10,2),
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id)
ON DELETE CASCADE -- Delete orders if customer deleted
ON UPDATE CASCADE -- Update orders if customer ID changes
);

-- Insert valid data
INSERT INTO orders VALUES
(1001, 1, '2026-03-01', 1500.50),
(1002, 2, '2026-03-02', 2750.00),
(1003, 1, '2026-03-03', 500.25);

-- This will fail - try uncommenting to see error
-- INSERT INTO orders VALUES (1004, 99, '2026-03-03', 1000.00); -- Customer 99 doesn't exist

SELECT * FROM orders;

-- Demonstrate CASCADE
UPDATE customers SET customer_id = 10 WHERE customer_id = 1;
SELECT * FROM customers;
SELECT * FROM orders; -- Order customer_id also updated to 10

-- 2.3.5 CHECK Constraint
CREATE TABLE employees_check (
emp_id INT PRIMARY KEY,
emp_name VARCHAR(100),
age INT CHECK (age >= 18 AND age <= 65), -- Age between 18-65
salary DECIMAL(10,2) CHECK (salary > 0), -- Salary must be positive
joining_date DATE CHECK (joining_date <= CURDATE()) -- Cannot join in future
);

-- Insert valid data
INSERT INTO employees_check VALUES (1, 'Chandan Chaudhari', 35, 75000.00, '2026-03-01');

-- This will fail - try uncommenting to see error
-- INSERT INTO employees_check VALUES (2, 'Young Employee', 17, 50000.00, '2026-03-01'); -- Age < 18

SELECT * FROM employees_check;

-- Named CHECK constraints
CREATE TABLE products (
product_id INT PRIMARY KEY,
product_name VARCHAR(100),
price DECIMAL(10,2),
discount DECIMAL(10,2),
CONSTRAINT valid_price CHECK (price > 0),
CONSTRAINT valid_discount CHECK (discount >= 0 AND discount <= price)
);

-- Insert valid data
INSERT INTO products VALUES (1, 'Laptop', 50000.00, 5000.00);
INSERT INTO products VALUES (2, 'Mouse', 500.00, 50.00);

-- This will fail - try uncommenting to see error
-- INSERT INTO products VALUES (3, 'Invalid', -100, 10); -- Negative price
-- INSERT INTO products VALUES (4, 'Invalid Discount', 1000, 1500); -- Discount > price

SELECT * FROM products;

-- 2.3.6 DEFAULT Constraint
CREATE TABLE employees_default (
emp_id INT PRIMARY KEY AUTO_INCREMENT,
emp_name VARCHAR(100) NOT NULL,
joining_date DATE DEFAULT (CURRENT_DATE), -- Today's date
is_active BOOLEAN DEFAULT TRUE, -- Active by default
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Auto timestamp
vacation_days INT DEFAULT 20 -- Default 20 days
);

-- Insert without specifying default columns
INSERT INTO employees_default (emp_name) VALUES ('Chandan Chaudhari');
INSERT INTO employees_default (emp_name) VALUES ('Vidisha Sharma');
INSERT INTO employees_default (emp_name, vacation_days) VALUES ('Sanoj Patel', 25); -- Override default

SELECT * FROM employees_default;

-- 2.3.7 AUTO_INCREMENT Constraint
CREATE TABLE employees_auto (
emp_id INT AUTO_INCREMENT PRIMARY KEY, -- Starts from 1
emp_name VARCHAR(100) NOT NULL,
emp_code VARCHAR(20) UNIQUE
);

INSERT INTO employees_auto (emp_name, emp_code) VALUES
('Chandan Chaudhari', 'EMP001'),
('Vidisha Sharma', 'EMP002'),
('Sanoj Patel', 'EMP003');

SELECT * FROM employees_auto;

-- Start from different number
CREATE TABLE departments_auto (
dept_id INT AUTO_INCREMENT PRIMARY KEY,
dept_name VARCHAR(100)
) AUTO_INCREMENT = 1000; -- Start from 1000

INSERT INTO departments_auto (dept_name) VALUES
('Human Resources'),
('Information Technology'),
('Finance');

SELECT * FROM departments_auto;


-- PART 3: COMBINING CONSTRAINTS - COMPLETE PRACTICAL EXAMPLES

-- Drop tables if they exist (with proper order due to foreign keys)
DROP TABLE IF EXISTS employees_complete;
DROP TABLE IF EXISTS departments_complete;

-- First create departments table (parent)
CREATE TABLE departments_complete (
dept_id INT AUTO_INCREMENT PRIMARY KEY,
dept_name VARCHAR(100) NOT NULL UNIQUE,
location VARCHAR(100),
budget DECIMAL(15,2) CHECK (budget > 0)
);

INSERT INTO departments_complete (dept_name, location, budget) VALUES
('Engineering', 'Bangalore', 1000000.00),
('Marketing', 'Mumbai', 500000.00),
('Sales', 'Delhi', 750000.00);

-- Example 1: Complete Employee Table with all constraints
CREATE TABLE employees_complete (
emp_id INT AUTO_INCREMENT PRIMARY KEY,
emp_code VARCHAR(20) UNIQUE NOT NULL,
emp_name VARCHAR(100) NOT NULL,
email VARCHAR(100) UNIQUE NOT NULL,
phone VARCHAR(15) UNIQUE,
gender ENUM('Male', 'Female', 'Other') NOT NULL,
birth_date DATE,
hire_date DATE NOT NULL DEFAULT (CURRENT_DATE),
salary DECIMAL(10,2) CHECK (salary >= 0),
dept_id INT,
status ENUM('Active', 'Inactive', 'Suspended') DEFAULT 'Active',
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

CONSTRAINT valid_hire_date CHECK (hire_date >= birth_date OR birth_date IS NULL),
CONSTRAINT valid_age CHECK (birth_date IS NULL OR TIMESTAMPDIFF(YEAR, birth_date, hire_date) >= 18),
FOREIGN KEY (dept_id) REFERENCES departments_complete(dept_id)
ON DELETE SET NULL
ON UPDATE CASCADE
);

-- Insert valid data
INSERT INTO employees_complete (emp_code, emp_name, email, phone, gender, birth_date, salary, dept_id) VALUES
('EMP001', 'Chandan Chaudhari', 'chandan@company.com', '9876543210', 'Male', '1990-05-15', 85000.00, 1),
('EMP002', 'Vidisha Sharma', 'vidisha@company.com', '9876543211', 'Female', '1992-08-22', 75000.00, 2),
('EMP003', 'Sanoj Patel', 'sanoj@company.com', '9876543212', 'Male', '1988-12-10', 95000.00, 1);

SELECT * FROM employees_complete;

-- Example 2: E-Commerce Database with Constraints
-- Drop tables in correct order (child first, then parent)
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- Customers table
CREATE TABLE customers (
customer_id INT AUTO_INCREMENT PRIMARY KEY,
customer_name VARCHAR(100) NOT NULL,
email VARCHAR(100) UNIQUE NOT NULL,
phone VARCHAR(15) UNIQUE,
city VARCHAR(50),
membership_level ENUM('Bronze', 'Silver', 'Gold', 'Platinum') DEFAULT 'Bronze',
registration_date DATE DEFAULT (CURRENT_DATE),
is_active BOOLEAN DEFAULT TRUE
);

-- Products table
CREATE TABLE products (
product_id INT AUTO_INCREMENT PRIMARY KEY,
product_name VARCHAR(200) NOT NULL,
category VARCHAR(50),
price DECIMAL(10,2) CHECK (price > 0),
stock_quantity INT DEFAULT 0 CHECK (stock_quantity >= 0),
reorder_level INT DEFAULT 10,
discontinued BOOLEAN DEFAULT FALSE,
CONSTRAINT valid_price_stock CHECK (price > 0 OR discontinued = TRUE)
);

-- Orders table
CREATE TABLE orders (
order_id INT AUTO_INCREMENT PRIMARY KEY,
customer_id INT NOT NULL,
order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
total_amount DECIMAL(12,2) DEFAULT 0.00,
status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled')
DEFAULT 'Pending',
payment_method ENUM('Credit Card', 'Debit Card', 'UPI', 'Net Banking'),
shipping_address TEXT NOT NULL,

FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
ON DELETE RESTRICT,

CONSTRAINT valid_amount CHECK (total_amount >= 0)
);

-- Order Items table (composite primary key)
CREATE TABLE order_items (
order_id INT,
product_id INT,
quantity INT NOT NULL CHECK (quantity > 0),
unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
discount DECIMAL(5,2) DEFAULT 0.00 CHECK (discount BETWEEN 0 AND 100),

PRIMARY KEY (order_id, product_id),
FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT
);

-- Insert sample data for e-commerce database
INSERT INTO customers (customer_name, email, phone, city, membership_level) VALUES
('Rahul Singh', 'rahul@email.com', '9876500001', 'Mumbai', 'Gold'),
('Priya Patel', 'priya@email.com', '9876500002', 'Delhi', 'Silver'),
('Amit Kumar', 'amit@email.com', '9876500003', 'Bangalore', 'Bronze');

INSERT INTO products (product_name, category, price, stock_quantity, reorder_level) VALUES
('Laptop', 'Electronics', 55000.00, 50, 10),
('Smartphone', 'Electronics', 25000.00, 100, 20),
('Headphones', 'Accessories', 2000.00, 200, 30),
('Mouse', 'Accessories', 500.00, 150, 25);

INSERT INTO orders (customer_id, shipping_address) VALUES
(1, '123, MG Road, Mumbai'),
(2, '456, Connaught Place, Delhi');

-- Update total amount (normally done via triggers or application)
UPDATE orders SET total_amount = 57500.00 WHERE order_id = 1;
UPDATE orders SET total_amount = 25000.00 WHERE order_id = 2;

INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount) VALUES
(1, 1, 1, 55000.00, 0),
(1, 3, 2, 2000.00, 10),
(2, 2, 1, 25000.00, 5);

-- View the data
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;

-- PART 4: CONSTRAINT MANAGEMENT COMMANDS

-- Create a test table for constraint management examples
DROP TABLE IF EXISTS constraint_test;
CREATE TABLE constraint_test (
id INT,
name VARCHAR(100),
age INT,
email VARCHAR(100)
);

-- Adding constraints to existing table

-- Add PRIMARY KEY
ALTER TABLE constraint_test ADD PRIMARY KEY (id);

-- Add UNIQUE constraint
ALTER TABLE constraint_test ADD UNIQUE (email);

-- Add CHECK constraint (MySQL 8.0.16+)
ALTER TABLE constraint_test ADD CONSTRAINT check_age CHECK (age >= 18);

-- Add DEFAULT value
ALTER TABLE constraint_test ALTER name SET DEFAULT 'Unknown';

-- Add NOT NULL constraint
ALTER TABLE constraint_test MODIFY name VARCHAR(100) NOT NULL;

-- Insert test data
INSERT INTO constraint_test (id, name, age, email) VALUES
(1, 'Test User', 25, 'test@email.com');

-- This will fail due to constraints - try uncommenting
-- INSERT INTO constraint_test VALUES (1, 'Duplicate', 30, 'dup@email.com'); -- Duplicate PK
-- INSERT INTO constraint_test VALUES (2, 'Too Young', 16, 'young@email.com'); -- Age < 18

-- View constraints
SHOW CREATE TABLE constraint_test;
SELECT * FROM constraint_test;

-- Removing constraints

-- Drop PRIMARY KEY (if no FK dependencies)
-- ALTER TABLE constraint_test DROP PRIMARY KEY;

-- Drop UNIQUE constraint
-- ALTER TABLE constraint_test DROP INDEX email;

-- Drop CHECK constraint
-- ALTER TABLE constraint_test DROP CONSTRAINT check_age;

-- Drop DEFAULT value
-- ALTER TABLE constraint_test ALTER name DROP DEFAULT;

-- Remove NOT NULL
-- ALTER TABLE constraint_test MODIFY name VARCHAR(100) NULL;

-- View all constraints in database
SELECT * FROM information_schema.table_constraints
WHERE constraint_schema = 'Lecture03_Demo';

-- View indexes (including unique constraints)
SHOW INDEX FROM employees_complete;

-- PART 5: COMMON MISTAKES AND BEST PRACTICES

-- BAD Example of Desgin Database: Using wrong data types
DROP TABLE IF EXISTS bad_example;
CREATE TABLE bad_example (
age TEXT, -- Waste of space
price FLOAT, -- Precision issues with money
is_active INT -- Boolean should be BOOLEAN/TINYINT
);

-- GOOD Example of Design Database: Proper data types
DROP TABLE IF EXISTS good_example;
CREATE TABLE good_example (
age TINYINT UNSIGNED, -- 0-255
price DECIMAL(10,2), -- Exact for money
is_active BOOLEAN -- True/False
);

-- BAD Example: Missing foreign key constraint
DROP TABLE IF EXISTS orders_bad;
CREATE TABLE orders_bad (
order_id INT PRIMARY KEY,
customer_id INT -- No link to customers table
);

-- GOOD Example: With foreign key
DROP TABLE IF EXISTS orders_good;
CREATE TABLE orders_good (
order_id INT PRIMARY KEY,
customer_id INT,
FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- BAD Example: Using NULL in important columns
DROP TABLE IF EXISTS employees_bad;
CREATE TABLE employees_bad (
emp_id INT PRIMARY KEY,
emp_name VARCHAR(100), -- NULL allowed - BAD!
email VARCHAR(100) -- NULL allowed - BAD!
);

-- GOOD Example: NOT NULL for required fields
DROP TABLE IF EXISTS employees_good;
CREATE TABLE employees_good (
emp_id INT PRIMARY KEY,
emp_name VARCHAR(100) NOT NULL,
email VARCHAR(100) NOT NULL
);

-- PART 6: PRACTICE EXERCISE - Library Management System

-- Library Management System with proper constraints
DROP TABLE IF EXISTS loans;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS members;

CREATE TABLE books (
book_id INT AUTO_INCREMENT PRIMARY KEY,
title VARCHAR(255) NOT NULL,
author VARCHAR(100) NOT NULL,
isbn VARCHAR(20) UNIQUE NOT NULL,
published_year YEAR,
category VARCHAR(50),
copies_available INT DEFAULT 1 CHECK (copies_available >= 0)
);

CREATE TABLE members (
member_id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(100) NOT NULL,
email VARCHAR(100) UNIQUE NOT NULL,
phone VARCHAR(15) UNIQUE,
membership_date DATE DEFAULT (CURRENT_DATE),
membership_type ENUM('Student', 'Faculty', 'Public') DEFAULT 'Public',
is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE loans (
loan_id INT AUTO_INCREMENT PRIMARY KEY,
book_id INT NOT NULL,
member_id INT NOT NULL,
loan_date DATE DEFAULT (CURRENT_DATE),
due_date DATE NOT NULL,
return_date DATE,
status ENUM('Active', 'Returned', 'Overdue') DEFAULT 'Active',

FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE RESTRICT,
FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE RESTRICT,

CONSTRAINT valid_dates CHECK (due_date >= loan_date),
CONSTRAINT valid_return CHECK (return_date IS NULL OR return_date >= loan_date)
);

-- Insert sample library data
INSERT INTO books (title, author, isbn, published_year, category, copies_available) VALUES
('MySQL Basics', 'John Smith', '978-1234567890', 2020, 'Database', 5),
('Advanced SQL', 'Jane Doe', '978-0987654321', 2021, 'Database', 3),
('Data Science Handbook', 'Bob Wilson', '978-1122334455', 2022, 'Data Science', 2);

INSERT INTO members (name, email, phone, membership_type) VALUES
('Alice Brown', 'alice@email.com', '9876512345', 'Student'),
('Bob Martin', 'bob@email.com', '9876512346', 'Faculty'),
('Carol White', 'carol@email.com', '9876512347', 'Public');

INSERT INTO loans (book_id, member_id, due_date) VALUES
(1, 1, DATE_ADD(CURDATE(), INTERVAL 14 DAY)),
(2, 2, DATE_ADD(CURDATE(), INTERVAL 30 DAY));

-- View library data
SELECT * FROM books;
SELECT * FROM members;
SELECT * FROM loans;

-- PART 7: SUMMARY - Complete Reference Example

-- Complete reference table with all data types and constraints
DROP TABLE IF EXISTS reference_table;
DROP TABLE IF EXISTS departments_ref;

-- Parent table for foreign key reference
CREATE TABLE departments_ref (
dept_id INT AUTO_INCREMENT PRIMARY KEY,
dept_name VARCHAR(100) NOT NULL
);

INSERT INTO departments_ref (dept_name) VALUES ('Engineering'), ('Marketing'), ('Sales');

-- Complete reference table
CREATE TABLE reference_table (
-- Numeric types
id INT AUTO_INCREMENT PRIMARY KEY,
age TINYINT UNSIGNED CHECK (age >= 18 AND age <= 100),
salary DECIMAL(10,2) NOT NULL CHECK (salary > 0),

-- String types
name VARCHAR(100) NOT NULL,
emp_code CHAR(10) UNIQUE,
description TEXT,
status ENUM('Active', 'Inactive', 'Pending') DEFAULT 'Active',
skills SET('Java', 'SQL', 'Python', 'AWS'),

-- Date/Time types
birth_date DATE,
hire_date DATE DEFAULT (CURRENT_DATE),
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

-- Boolean
is_verified BOOLEAN DEFAULT FALSE,

-- Foreign key
dept_id INT,

-- Named constraints
CONSTRAINT valid_hire CHECK (hire_date >= birth_date OR birth_date IS NULL),
CONSTRAINT valid_age CHECK (birth_date IS NULL OR TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) >= 18),
FOREIGN KEY (dept_id) REFERENCES departments_ref(dept_id) ON DELETE SET NULL
);

-- Insert sample data
INSERT INTO reference_table (age, salary, name, emp_code, status, skills, birth_date, dept_id) VALUES
(35, 85000.00, 'Chandan Chaudhari', 'EMP001', 'Active', 'SQL,Java,Python', '1990-05-15', 1),
(28, 65000.00, 'Vidisha Sharma', 'EMP002', 'Active', 'SQL,Python', '1995-08-22', 2),
(42, 120000.00, 'Sanoj Patel', 'EMP003', 'Active', 'Java,AWS', '1983-12-10', 1);

-- View the complete reference table
SELECT * FROM reference_table;

-- Show table structure with all constraints
SHOW CREATE TABLE reference_table;

-- Key Takeaways:
-- 1. Choose appropriate data types for columns
-- 2. Always use PRIMARY KEY for unique identification
-- 3. Use FOREIGN KEY to maintain referential integrity
-- 4. Add CHECK constraints for business rules
-- 5. Use NOT NULL for required fields
-- 6. Apply UNIQUE to prevent duplicates
-- 7. Use DEFAULT for common values
-- 8. Name your constraints for easier management
*/
