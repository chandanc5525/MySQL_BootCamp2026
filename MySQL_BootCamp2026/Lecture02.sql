/*
==================== INSERTING DATA INTO TABLES ====================

1. INSERT SINGLE ROW
--------------------
Syntax:
INSERT INTO table_name (column1, column2, column3, ...)
VALUES (value1, value2, value3, ...);

Example:
INSERT INTO Employees (emp_id, emp_name, email, joining_date, salary)
VALUES (1, 'Chandan Chaudhari', 'chandan@example.com', '2026-01-17', 50000.00);

Note:
- Always specify column names for clarity and safety
- Values must match the datatype of columns
- NOT NULL columns cannot be skipped
- UNIQUE and PRIMARY KEY columns must be unique
--------------------------------------------------------------------

2. INSERT MULTIPLE ROWS
-----------------------
Syntax:
INSERT INTO table_name (column1, column2, ...)
VALUES
(value1a, value2a, ...),
(value1b, value2b, ...),
(value1c, value2c, ...);

Example:
INSERT INTO Employees (emp_id, emp_name, email, joining_date, salary)
VALUES
(2, 'Vidisha Sharma', 'vidisha@example.com', '2026-01-18', 55000.00),
(3, 'Sanoj Patel', 'sanoj@example.com', '2026-01-19', 60000.00);

Note:
- More efficient than single row inserts
- Useful for bulk data insertion
--------------------------------------------------------------------

3. INSERT WITH DEFAULT VALUES
-----------------------------
Syntax:
INSERT INTO table_name (column1, column2, column3)
VALUES (value1, DEFAULT, value3);

Example:
INSERT INTO Employees (emp_id, emp_name, salary)
VALUES (4, 'Rahul Singh', DEFAULT);

Note:
- Works if the column has a DEFAULT constraint
- AUTO_INCREMENT columns can be skipped if you want MySQL to auto-generate
--------------------------------------------------------------------

4. INSERT IGNORING DUPLICATES
-----------------------------
Syntax:
INSERT IGNORE INTO table_name (columns...)
VALUES (...);

Note:
- Ignores errors like duplicate PRIMARY KEY or UNIQUE values
- Useful for importing large datasets safely
--------------------------------------------------------------------

5. INSERT OR UPDATE (UPSERT)
-----------------------------
Syntax:
INSERT INTO table_name (columns...)
VALUES (...)
ON DUPLICATE KEY UPDATE column1 = value1, column2 = value2;

Example:
INSERT INTO Employees (emp_id, emp_name, salary)
VALUES (1, 'Chandan Chaudhari', 52000)
ON DUPLICATE KEY UPDATE salary = 52000;

Note:
- Handles scenarios where the record may already exist
- Common in corporate ETL pipelines
--------------------------------------------------------------------

6. BEST PRACTICES FOR INSERTS
-----------------------------
- Always validate data types before inserting
- Test on **staging/test database** before production
- Avoid inserting NULLs into mandatory columns
- Bulk insert multiple rows wherever possible
- Document inserts using comments for corporate standards
- Use transactions (START TRANSACTION; ... COMMIT;) for multiple dependent inserts
====================================================================
*/

-- INSERT DATA INTO STUDENTS
INSERT INTO Students (student_id, student_name, email, enrollment_date)
VALUES
(1, 'Chandan Chaudhari', 'chandan@student.com', '2026-01-17'),
(2, 'Vidisha Sharma', 'vidisha@student.com', '2026-01-18'),
(3, 'Sanoj Patel', 'sanoj@student.com', '2026-01-19'),
(4, 'Rahul Singh', 'rahul@student.com', '2026-01-20'),
(5, 'Anita Desai', 'anita@student.com', '2026-01-21'),
(6, 'Priya Nair', 'priya@student.com', '2026-01-22');

-- INSERT DATA INTO COURSES
INSERT INTO Courses (course_id, course_name, duration_weeks)
VALUES
(1, 'MySQL Basics', 4),
(2, 'Advanced SQL', 6),
(3, 'Data Analysis with SQL', 5),
(4, 'Database Design', 6),
(5, 'SQL for Data Science', 8),
(6, 'Performance Tuning in MySQL', 3);

-- INSERT DATA INTO TRAINERS
INSERT INTO Trainers (trainer_id, trainer_name, experience_years)
VALUES
(1, 'Ramesh Kumar', 5),
(2, 'Amit Joshi', 7),
(3, 'Neha Sharma', 4),
(4, 'Vikram Joshi', 6),
(5, 'Priya Mehta', 5),
(6, 'Rohan Verma', 8);

-- INSERT DATA INTO ENROLLMENTS
INSERT INTO Enrollments (enrollment_id, student_id, course_id, enrollment_date)
VALUES
(1, 1, 1, '2026-01-17'),
(2, 2, 2, '2026-01-18'),
(3, 3, 3, '2026-01-19'),
(4, 4, 4, '2026-01-20'),
(5, 5, 5, '2026-01-21'),
(6, 6, 6, '2026-01-22');

/*
====================================================================
        SQL BOOTCAMP – REVISION & THINKING QUESTIONS
        (Based on Today’s Session)
====================================================================

1. Why is it important to use PRIMARY KEY in every table? Give examples.
2. Explain the role of FOREIGN KEY in the Enrollments table. Why is it necessary?
3. How would you prevent a student from enrolling in the same course twice?
4. If two trainers have the same name, how can the database distinguish them?
5. How would you write a SQL query to list all students in a specific course?
6. Describe the consequences of inserting data without specifying column names.
7. How can AUTO_INCREMENT and DEFAULT values simplify inserting new records?
8. What would happen if you try to insert an enrollment with a non-existing student_id?
9. Write a SQL query to find all courses assigned to a particular trainer.
10. Explain steps to maintain data integrity when deleting a student who has enrollments.

LOGISTICS COMPANY DATABASE EXERCISE

Suggested Tables and Columns:

1. Customers
   - customer_id
   - customer_name
   - contact_email
   - city

2. Drivers
   - driver_id
   - driver_name
   - license_no
   - experience_years

3. Vehicles
   - vehicle_id
   - vehicle_type
   - capacity_tons
   - driver_id (assigned driver)

4. Shipments
   - shipment_id
   - customer_id (who requested the shipment)
   - shipment_date
   - origin
   - destination

5. Deliveries
   - delivery_id
   - shipment_id
   - vehicle_id
   - delivery_date
   - status (Delivered, Pending, In Transit)

Note: Add Minimum 10 records
====================================================================
*/