/*
==================== DATABASE DESIGN PRINCIPLES ====================
1. Understand Business Requirements
   → Identify entities, attributes, and relationships clearly
   → Know what data to store and why

2. Identify Proper Entities (Tables)
   → One table = one real-world object (Student, Course, Order, etc.)
   → Avoid mixing multiple concepts in one table

3. Choose Correct Datatypes
   → INT for IDs, VARCHAR for text, DATE/TIMESTAMP for dates
   → Avoid using TEXT when VARCHAR is sufficient

4. Define Primary Keys
   → Every table must have a PRIMARY KEY
   → Use surrogate keys (id) where natural keys are complex

5. Normalize the Database
   → Remove redundant data
   → Follow 1NF, 2NF, and 3NF
   → Split repeating or dependent columns into separate tables

6. Plan Relationships
   → Identify One-to-One, One-to-Many, Many-to-Many relationships
   → Use FOREIGN KEYS to maintain data integrity

7. Avoid Redundancy
   → Do not duplicate columns across tables unnecessarily
   → Store data only once and reference using keys

8. Use Meaningful Naming Conventions
   → Table names: plural nouns (Students, Orders)
   → Column names: snake_case and self-explanatory
   → Avoid reserved keywords

9. Handle NULL Values Carefully
   → Allow NULL only when data is truly optional
   → Use NOT NULL where data is mandatory

10. Think About Scalability & Performance
    → Index columns used in JOIN, WHERE, GROUP BY
    → Avoid over-indexing

11. Security & Data Sensitivity
    → Separate sensitive data (passwords, PII)
    → Use proper access control and encryption where required

12. Plan for Future Changes
    → Design flexible schema
    → Avoid hard-coded or derived data storage
===================================================================
*/



-- Create Database
CREATE DATABASE IF NOT EXISTS SQLBootCamp;

-- Show all databases
SHOW DATABASES;

/*
Drop AirAsia Database
This will permanently delete the database and all its objects
*/

-- Drop AirAsia Database from system (safe drop)
DROP DATABASE IF EXISTS AirAsia;

-- Use the database
USE SQLBootCamp;

/*
==================== MySQL Datatypes Used ====================

INT              → Stores whole numbers
VARCHAR(n)       → Stores variable-length text (max n characters)
DATE             → Stores date (YYYY-MM-DD)
DECIMAL(p,s)     → Stores exact numeric values (p = precision, s = scale)
FLOAT / DOUBLE   → Stores approximate decimal values
BOOLEAN          → Stores TRUE / FALSE (internally TINYINT)
TIMESTAMP        → Stores date & time with auto update support

==============================================================
*/

-- Use the database
USE SQLBootCamp;

/*
==================== RULES TO BE FOLLOWED BEFORE CREATING TABLES ====================
1. Finalize Table Purpose
   → Each table should represent a single entity
   → Do not mix multiple business concepts in one table

2. Decide Primary Key
   → Every table must have a PRIMARY KEY
   → Primary key should be unique, NOT NULL, and stable

3. Choose Correct Datatypes
   → Use INT for IDs
   → Use VARCHAR with appropriate length for text
   → Use DATE / TIMESTAMP for date-time values
   → Avoid using TEXT unless really required

4. Define Column Constraints
   → Use NOT NULL for mandatory fields
   → Use UNIQUE where duplicate values are not allowed
   → Set DEFAULT values where applicable

5. Plan Relationships
   → Identify foreign keys before table creation
   → Decide one-to-many or many-to-many relationships

6. Avoid Redundant Columns
   → Do not store calculated or repeated data
   → Follow normalization principles

7. Use Proper Naming Conventions
   → Table names: plural, meaningful (students, orders)
   → Column names: lowercase, snake_case
   → Avoid SQL reserved keywords

8. Decide Index Requirements
   → Index columns used in JOIN, WHERE, ORDER BY
   → Do not over-index small tables

9. Handle NULLs Carefully
   → Allow NULL only if the value can be unknown or optional

10. Think About Data Growth
    → Estimate row growth
    → Choose datatypes and keys accordingly
=====================================================================
*/

-- Create Students table
CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50),
    email VARCHAR(100),
    enrollment_date DATE
);

-- Create Courses table
CREATE TABLE Courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(50),
    duration_weeks INT
);

-- Create Trainers table
CREATE TABLE Trainers (
    trainer_id INT PRIMARY KEY,
    trainer_name VARCHAR(50),
    experience_years INT
);

-- Create Batches table
CREATE TABLE Batches (
    batch_id INT PRIMARY KEY,
    batch_name VARCHAR(20),
    trainer_id INT
);

-- Create Enrollments table
CREATE TABLE Enrollments (
    enrollment_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    enrollment_date DATE
);

-- Show all tables
SHOW TABLES;

-- Drop one table out of five
DROP TABLE IF EXISTS Batches;

-- Verify remaining tables
SHOW TABLES;

/*
====================================================================
        SQL BOOTCAMP – REVISION & THINKING QUESTIONS
        (Based on Today’s Session)
====================================================================
DATABASE CONCEPTS
-----------------
1. What is a database?
2. Why do we use CREATE DATABASE IF NOT EXISTS?
3. What is the difference between USE database_name and CREATE DATABASE?
4. Can two databases have tables with the same name? Why?

COMMENTS IN SQL
---------------
5. What is the difference between single-line and multi-line comments?
6. When should multi-line comments be preferred in corporate SQL scripts?
7. Are comments executed by the SQL engine? Explain.

DATATYPES (MySQL)
-----------------
8. Why is INT preferred for primary keys?
9. Difference between VARCHAR and CHAR.
10. Why should salary be stored using DECIMAL instead of FLOAT?
11. What happens if VARCHAR length is kept very large?

RULES BEFORE CREATING TABLES
----------------------------
12. Why should every table have a primary key?
13. What problems occur if primary key is missing?
14. Why should we avoid storing derived or calculated columns?
15. Why is normalization important before table creation?
16. Why should table and column names be meaningful?

CREATE TABLE
------------
17. What is the purpose of NOT NULL constraint?
18. Why should UNIQUE constraint be used carefully?
19. What happens if two rows have the same primary key value?
20. Can a table be created without any data? Explain.

SHOW & DROP
-----------
21. What is the difference between SHOW DATABASES and SHOW TABLES?
22. Why should DROP commands always use IF EXISTS?
23. What happens when a table is dropped?
24. Can we recover a table after DROP? Why or why not?

CORPORATE SCENARIO QUESTIONS
----------------------------
25. Why should DROP commands never be executed directly in production?
26. Who should have permission to drop databases or tables?
27. Why is documentation (comments) mandatory in corporate SQL projects?
28. What is the risk of poor database design in real projects?
====================================================================
END OF QUESTIONS – BASED ON TODAY’S SESSION
====================================================================
*/
