/*
Lecture 04: MYSQL DDL Commands and use cases 
Objective: Learn DDL Commands to build effective database with constraints 
Author : Chandan Chaudhari

DDL (Data Definition Language) Commands covered:
- CREATE       : Create database/table objects
- ALTER        : Modify database/table structure
- DROP         : Remove database/table objects
- TRUNCATE     : Remove all records from table
- RENAME       : Rename database objects

Constraints covered:
- PRIMARY KEY  : Uniquely identifies each record
- FOREIGN KEY  : Ensures referential integrity
- UNIQUE       : Ensures all values are different
- NOT NULL     : Ensures column cannot have NULL value
- CHECK        : Ensures condition is satisfied
- DEFAULT      : Sets default value for column
*/

-- =====================================================
-- SECTION 1: DATABASE OPERATIONS
-- =====================================================

-- 1.1 CREATE DATABASE
-- Create a new database for our University Management System
CREATE DATABASE IF NOT EXISTS UniversityDB;
USE UniversityDB;

-- 1.2 SHOW DATABASES
-- Display all available databases
SHOW DATABASES;

-- 1.3 SELECT CURRENT DATABASE
-- Display currently selected database
SELECT DATABASE();

-- =====================================================
-- SECTION 2: CREATE TABLE WITH CONSTRAINTS
-- =====================================================

-- 2.1 Create Department table (Parent table)
CREATE TABLE IF NOT EXISTS Department (
    dept_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(100) NOT NULL UNIQUE,
    dept_code VARCHAR(10) NOT NULL UNIQUE,
    established_year YEAR,
    budget DECIMAL(10,2) DEFAULT 100000.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_budget CHECK (budget >= 0)
);

-- 2.2 Create Student table with various constraints
CREATE TABLE IF NOT EXISTS Student (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15),
    date_of_birth DATE NOT NULL,
    age INT,
    dept_id INT,
    enrollment_date DATE DEFAULT (CURRENT_DATE),
    cgpa DECIMAL(3,2),
    status ENUM('Active', 'Graduated', 'Suspended') DEFAULT 'Active',
    
    -- Adding constraints
    CONSTRAINT fk_student_dept FOREIGN KEY (dept_id) 
        REFERENCES Department(dept_id) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE,
    
    CONSTRAINT check_email_format CHECK (email LIKE '%@%.%'),
    CONSTRAINT check_cgpa CHECK (cgpa >= 0 AND cgpa <= 4.0),
    CONSTRAINT check_age CHECK (age >= 16 AND age <= 60)
);

-- 2.3 Create Course table
CREATE TABLE IF NOT EXISTS Course (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_code VARCHAR(20) NOT NULL UNIQUE,
    course_name VARCHAR(200) NOT NULL,
    credits INT NOT NULL,
    dept_id INT,
    max_students INT DEFAULT 30,
    
    CONSTRAINT fk_course_dept FOREIGN KEY (dept_id) 
        REFERENCES Department(dept_id)
        ON DELETE SET NULL,
    
    CONSTRAINT check_credits CHECK (credits > 0 AND credits <= 6),
    CONSTRAINT check_max_students CHECK (max_students > 0)
);

-- 2.4 Create Enrollment table (Junction table with composite primary key)
CREATE TABLE IF NOT EXISTS Enrollment (
    student_id INT,
    course_id INT,
    enrollment_date DATE DEFAULT (CURRENT_DATE),
    grade CHAR(2),
    semester VARCHAR(20) NOT NULL,
    year YEAR NOT NULL,
    
    -- Composite Primary Key
    PRIMARY KEY (student_id, course_id, semester, year),
    
    -- Foreign Keys
    CONSTRAINT fk_enrollment_student FOREIGN KEY (student_id) 
        REFERENCES Student(student_id) 
        ON DELETE CASCADE,
    
    CONSTRAINT fk_enrollment_course FOREIGN KEY (course_id) 
        REFERENCES Course(course_id) 
        ON DELETE CASCADE,
    
    -- Check constraint for grade
    CONSTRAINT check_grade CHECK (grade IN ('A+', 'A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D', 'F', NULL))
);

-- =====================================================
-- SECTION 3: SHOW TABLE INFORMATION
-- =====================================================

-- 3.1 Show all tables
SHOW TABLES;

-- 3.2 Describe table structure
DESC Student;
DESCRIBE Department;

-- 3.3 Show create table statement
SHOW CREATE TABLE Student;

-- 3.4 Show table status
SHOW TABLE STATUS WHERE Name = 'Student';

-- =====================================================
-- SECTION 4: ALTER TABLE COMMANDS
-- =====================================================

-- 4.1 ADD Column
ALTER TABLE Student 
ADD COLUMN address VARCHAR(255) AFTER phone;

ALTER TABLE Student 
ADD COLUMN emergency_contact VARCHAR(15),
ADD COLUMN blood_group VARCHAR(5);

-- 4.2 MODIFY Column (Change column definition)
ALTER TABLE Student 
MODIFY COLUMN phone VARCHAR(20);

ALTER TABLE Student 
MODIFY COLUMN age INT NOT NULL;

-- 4.3 CHANGE Column (Rename and modify column)
ALTER TABLE Student 
CHANGE COLUMN address permanent_address VARCHAR(300);

-- 4.4 RENAME Column (MySQL 8.0+)
ALTER TABLE Student 
RENAME COLUMN emergency_contact TO emergency_phone;

-- 4.5 DROP Column
ALTER TABLE Student 
DROP COLUMN blood_group;

-- 4.6 ADD Constraints
ALTER TABLE Student 
ADD CONSTRAINT unique_phone UNIQUE (phone);

ALTER TABLE Student 
ADD CONSTRAINT check_phone_format CHECK (phone REGEXP '^[0-9]{10}$');

-- 4.7 DROP Constraints
ALTER TABLE Student 
DROP CONSTRAINT unique_phone;

ALTER TABLE Student 
DROP CHECK check_phone_format;

-- 4.8 ENABLE/DISABLE Constraints (MySQL 8.0.19+)
-- Note: MySQL doesn't directly support disabling constraints, but we can drop and recreate

-- 4.9 RENAME Table
ALTER TABLE Student 
RENAME TO UniversityStudent;

ALTER TABLE UniversityStudent 
RENAME TO Student;

-- =====================================================
-- SECTION 5: INDEX OPERATIONS
-- =====================================================

-- 5.1 CREATE INDEX
CREATE INDEX idx_student_name ON Student(last_name, first_name);
CREATE UNIQUE INDEX idx_student_email ON Student(email);
CREATE INDEX idx_dob ON Student(date_of_birth);

-- 5.2 SHOW INDEXES
SHOW INDEX FROM Student;

-- 5.3 DROP INDEX
DROP INDEX idx_dob ON Student;

-- =====================================================
-- SECTION 6: INSERT SAMPLE DATA (For testing constraints)
-- =====================================================

-- 6.1 Insert data in Department
INSERT INTO Department (dept_name, dept_code, established_year, budget) VALUES
('Computer Science', 'CS', 2000, 500000.00),
('Electrical Engineering', 'EE', 1998, 450000.00),
('Mechanical Engineering', 'ME', 1995, 400000.00),
('Civil Engineering', 'CE', 2005, 350000.00);

-- 6.2 Insert data in Student
INSERT INTO Student (first_name, last_name, email, phone, date_of_birth, age, dept_id, cgpa) VALUES
('John', 'Doe', 'john.doe@email.com', '1234567890', '2000-05-15', 23, 1, 3.5),
('Jane', 'Smith', 'jane.smith@email.com', '9876543210', '2001-08-22', 22, 2, 3.8),
('Bob', 'Johnson', 'bob.j@email.com', '5555555555', '2000-11-30', 23, 1, 3.2);

-- 6.3 Insert data in Course
INSERT INTO Course (course_code, course_name, credits, dept_id, max_students) VALUES
('CS101', 'Introduction to Programming', 4, 1, 50),
('CS201', 'Data Structures', 4, 1, 40),
('EE101', 'Circuit Analysis', 3, 2, 35),
('ME101', 'Thermodynamics', 4, 3, 30);

-- 6.4 Insert data in Enrollment
INSERT INTO Enrollment (student_id, course_id, semester, year, grade) VALUES
(1, 1, 'Fall', 2023, 'A'),
(1, 2, 'Fall', 2023, 'B+'),
(2, 3, 'Fall', 2023, 'A-'),
(3, 1, 'Fall', 2023, 'B');

-- =====================================================
-- SECTION 7: TRUNCATE COMMAND
-- =====================================================

-- 7.1 TRUNCATE (Removes all rows, resets auto-increment)
-- Note: Be careful with foreign key constraints
SET FOREIGN_KEY_CHECKS = 0;  -- Disable FK checks temporarily
TRUNCATE TABLE Enrollment;
TRUNCATE TABLE Student;
TRUNCATE TABLE Course;
TRUNCATE TABLE Department;
SET FOREIGN_KEY_CHECKS = 1;  -- Enable FK checks

-- =====================================================
-- SECTION 8: DROP COMMANDS
-- =====================================================

-- 8.1 DROP Table
-- Drop tables in correct order (child tables first due to FK constraints)
DROP TABLE IF EXISTS Enrollment;
DROP TABLE IF EXISTS Student;
DROP TABLE IF EXISTS Course;
DROP TABLE IF EXISTS Department;

-- 8.2 DROP Database
DROP DATABASE IF EXISTS UniversityDB;

-- =====================================================
-- SECTION 9: RENAME COMMANDS
-- =====================================================

-- 9.1 RENAME Database (Not directly possible in MySQL)
-- Workaround: Create new DB, move tables, drop old

-- 9.2 RENAME Multiple Tables
RENAME TABLE 
    Student TO OldStudent,
    Department TO OldDepartment;

-- Rename back
RENAME TABLE 
    OldStudent TO Student,
    OldDepartment TO Department;

-- =====================================================
-- SECTION 10: IMPORTANT INFORMATION SCHEMA QUERIES
-- =====================================================

-- 10.1 View all constraints in a database
SELECT * FROM information_schema.TABLE_CONSTRAINTS 
WHERE CONSTRAINT_SCHEMA = 'UniversityDB';

-- 10.2 View all tables in database
SELECT * FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'UniversityDB';

-- 10.3 View column information
SELECT * FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = 'UniversityDB' AND TABLE_NAME = 'Student';


