/*
Lecture 05: MYSQL DML Commands and use cases 
Objective: Learn DML Commands to build effective database with constraints 
Author : Chandan Chaudhari

DML (Data Manipulation Language) Commands covered:
- INSERT     : Add new records to tables
- SELECT     : Retrieve data from tables
- UPDATE     : Modify existing records
- DELETE     : Remove records from tables
- REPLACE    : Insert or replace records
- CALL       : Call stored procedures
- EXPLAIN    : Show query execution plan
- LOCK/UNLOCK: Table locking for data integrity

Additional Concepts:
- Transaction Control (COMMIT, ROLLBACK, SAVEPOINT)
- Import/Export Data
- Bulk Operations
- Conditional Manipulation
- Joins in DML operations
*/

-- =====================================================
-- SECTION 0: SETUP - Create and use database
-- =====================================================

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS UniversityDB;
USE UniversityDB;

-- Recreate tables with sample structure (from Lecture 04)
-- Department table
CREATE TABLE IF NOT EXISTS Department (
    dept_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(100) NOT NULL UNIQUE,
    dept_code VARCHAR(10) NOT NULL UNIQUE,
    established_year YEAR,
    budget DECIMAL(10,2) DEFAULT 100000.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Student table
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
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id) ON DELETE SET NULL
);

-- Course table
CREATE TABLE IF NOT EXISTS Course (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_code VARCHAR(20) NOT NULL UNIQUE,
    course_name VARCHAR(200) NOT NULL,
    credits INT NOT NULL,
    dept_id INT,
    max_students INT DEFAULT 30,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id) ON DELETE SET NULL
);

-- Enrollment table
CREATE TABLE IF NOT EXISTS Enrollment (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date DATE DEFAULT (CURRENT_DATE),
    grade CHAR(2),
    semester VARCHAR(20) NOT NULL,
    year YEAR NOT NULL,
    FOREIGN KEY (student_id) REFERENCES Student(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Course(course_id) ON DELETE CASCADE,
    UNIQUE KEY unique_enrollment (student_id, course_id, semester, year)
);

-- =====================================================
-- SECTION 1: INSERT COMMANDS
-- =====================================================

-- 1.1 Basic INSERT - Single row
INSERT INTO Department (dept_name, dept_code, established_year, budget) 
VALUES ('Computer Science', 'CS', 2000, 500000.00);

-- 1.2 INSERT without specifying columns (values for all columns)
INSERT INTO Department 
VALUES (2, 'Electrical Engineering', 'EE', 1998, 450000.00, CURRENT_TIMESTAMP);

-- 1.3 INSERT with DEFAULT values
INSERT INTO Department (dept_name, dept_code, established_year) 
VALUES ('Mechanical Engineering', 'ME', 1995);

-- 1.4 INSERT multiple rows
INSERT INTO Department (dept_name, dept_code, established_year, budget) VALUES
    ('Civil Engineering', 'CE', 2005, 350000.00),
    ('Chemical Engineering', 'CHE', 2010, 300000.00),
    ('Biotechnology', 'BT', 2015, 250000.00);

-- 1.5 INSERT with SELECT (Copy data from another table)
-- Create a backup table first
CREATE TABLE Department_Backup LIKE Department;
INSERT INTO Department_Backup SELECT * FROM Department;

-- 1.6 INSERT IGNORE - Skip rows that cause errors
INSERT IGNORE INTO Department (dept_id, dept_name, dept_code, established_year) VALUES
    (1, 'Computer Science', 'CS', 2000),  -- Duplicate - will be ignored
    (7, 'Mathematics', 'MATH', 2012);      -- New - will be inserted

-- 1.7 INSERT with ON DUPLICATE KEY UPDATE
INSERT INTO Department (dept_id, dept_name, dept_code, budget) 
VALUES (1, 'Computer Science', 'CS', 550000.00)
ON DUPLICATE KEY UPDATE 
    budget = VALUES(budget),
    dept_name = CONCAT(dept_name, ' (Updated)');

-- 1.8 INSERT student data
INSERT INTO Student (first_name, last_name, email, phone, date_of_birth, age, dept_id, cgpa) VALUES
    ('John', 'Doe', 'john.doe@email.com', '1234567890', '2000-05-15', 23, 1, 3.5),
    ('Jane', 'Smith', 'jane.smith@email.com', '9876543210', '2001-08-22', 22, 2, 3.8),
    ('Bob', 'Johnson', 'bob.j@email.com', '5555555555', '2000-11-30', 23, 1, 3.2),
    ('Alice', 'Williams', 'alice.w@email.com', '1112223333', '2002-03-10', 21, 3, 3.9),
    ('Charlie', 'Brown', 'charlie.b@email.com', '4445556666', '2001-07-25', 22, 2, 2.8);

-- 1.9 INSERT course data
INSERT INTO Course (course_code, course_name, credits, dept_id, max_students) VALUES
    ('CS101', 'Introduction to Programming', 4, 1, 50),
    ('CS201', 'Data Structures', 4, 1, 40),
    ('CS301', 'Database Systems', 3, 1, 45),
    ('EE101', 'Circuit Analysis', 3, 2, 35),
    ('EE201', 'Digital Electronics', 4, 2, 30),
    ('ME101', 'Thermodynamics', 4, 3, 30),
    ('ME201', 'Fluid Mechanics', 3, 3, 25);

-- 1.10 INSERT enrollment data
INSERT INTO Enrollment (student_id, course_id, semester, year, grade) VALUES
    (1, 1, 'Fall', 2023, 'A'),
    (1, 2, 'Fall', 2023, 'B+'),
    (2, 4, 'Fall', 2023, 'A-'),
    (3, 1, 'Fall', 2023, 'B'),
    (4, 3, 'Fall', 2023, 'A+'),
    (5, 2, 'Fall', 2023, 'C+'),
    (2, 5, 'Fall', 2023, 'B+'),
    (3, 6, 'Fall', 2023, 'B-');

-- =====================================================
-- SECTION 2: SELECT COMMANDS (Data Retrieval)
-- =====================================================

-- 2.1 Basic SELECT
SELECT * FROM Student;
SELECT first_name, last_name, email FROM Student;

-- 2.2 SELECT with WHERE clause
SELECT * FROM Student WHERE dept_id = 1;
SELECT * FROM Student WHERE cgpa >= 3.5;
SELECT * FROM Student WHERE date_of_birth > '2001-01-01';

-- 2.3 SELECT with AND/OR/NOT
SELECT * FROM Student 
WHERE dept_id = 1 AND cgpa >= 3.0;

SELECT * FROM Student 
WHERE dept_id = 1 OR dept_id = 2;

SELECT * FROM Student 
WHERE NOT status = 'Graduated';

-- 2.4 SELECT with IN/NOT IN
SELECT * FROM Student 
WHERE dept_id IN (1, 3, 5);

SELECT * FROM Course 
WHERE dept_id NOT IN (1, 2);

-- 2.5 SELECT with BETWEEN
SELECT * FROM Student 
WHERE cgpa BETWEEN 3.0 AND 4.0;

SELECT * FROM Enrollment 
WHERE year BETWEEN 2022 AND 2023;

-- 2.6 SELECT with LIKE (Pattern Matching)
-- Names starting with 'J'
SELECT * FROM Student 
WHERE first_name LIKE 'J%';

-- Names ending with 'son'
SELECT * FROM Student 
WHERE last_name LIKE '%son';

-- Email containing 'smith'
SELECT * FROM Student 
WHERE email LIKE '%smith%';

-- Phone numbers with specific pattern
SELECT * FROM Student 
WHERE phone LIKE '123%';

-- 2.7 SELECT with REGEXP (Regular Expression)
-- More powerful pattern matching
SELECT * FROM Student 
WHERE first_name REGEXP '^[J|A]';  -- Starts with J or A

SELECT * FROM Student 
WHERE email REGEXP '@.*\\.com$';   -- Ends with .com

-- 2.8 SELECT with ORDER BY
SELECT * FROM Student 
ORDER BY last_name ASC, first_name ASC;

SELECT * FROM Student 
ORDER BY cgpa DESC;

SELECT * FROM Enrollment 
ORDER BY year DESC, semester ASC;

-- 2.9 SELECT with LIMIT and OFFSET
-- Top 3 students by CGPA
SELECT * FROM Student 
ORDER BY cgpa DESC 
LIMIT 3;

-- Next 3 students (pagination)
SELECT * FROM Student 
ORDER BY cgpa DESC 
LIMIT 3 OFFSET 3;

-- Alternative syntax
SELECT * FROM Student 
ORDER BY cgpa DESC 
LIMIT 3, 3;  -- offset = 3, limit = 3

-- 2.10 SELECT with DISTINCT
SELECT DISTINCT dept_id FROM Student;
SELECT DISTINCT semester, year FROM Enrollment;

-- 2.11 SELECT with Aggregate Functions
SELECT 
    COUNT(*) AS total_students,
    AVG(cgpa) AS average_cgpa,
    MAX(cgpa) AS highest_cgpa,
    MIN(cgpa) AS lowest_cgpa,
    SUM(age) AS total_age
FROM Student;

-- 2.12 SELECT with GROUP BY
SELECT 
    dept_id,
    COUNT(*) AS student_count,
    AVG(cgpa) AS avg_cgpa
FROM Student
GROUP BY dept_id;

-- 2.13 SELECT with HAVING (filter groups)
SELECT 
    dept_id,
    COUNT(*) AS student_count,
    AVG(cgpa) AS avg_cgpa
FROM Student
GROUP BY dept_id
HAVING student_count > 1 AND avg_cgpa > 3.0;

-- 2.14 SELECT with JOINS
-- INNER JOIN
SELECT 
    s.first_name, 
    s.last_name,
    d.dept_name,
    s.cgpa
FROM Student s
INNER JOIN Department d ON s.dept_id = d.dept_id;

-- LEFT JOIN
SELECT 
    d.dept_name,
    COUNT(s.student_id) AS student_count
FROM Department d
LEFT JOIN Student s ON d.dept_id = s.dept_id
GROUP BY d.dept_id, d.dept_name;

-- Multiple JOINs
SELECT 
    s.first_name,
    s.last_name,
    c.course_name,
    e.grade,
    e.semester,
    e.year
FROM Student s
JOIN Enrollment e ON s.student_id = e.student_id
JOIN Course c ON e.course_id = c.course_id
WHERE s.student_id = 1;

-- 2.15 SELECT with Subqueries
-- Students with CGPA above average
SELECT first_name, last_name, cgpa
FROM Student
WHERE cgpa > (SELECT AVG(cgpa) FROM Student);

-- Departments with more than 2 students
SELECT dept_name
FROM Department
WHERE dept_id IN (
    SELECT dept_id
    FROM Student
    GROUP BY dept_id
    HAVING COUNT(*) > 2
);

-- 2.16 SELECT with EXISTS
-- Find students who are enrolled in at least one course
SELECT first_name, last_name
FROM Student s
WHERE EXISTS (
    SELECT 1 
    FROM Enrollment e 
    WHERE e.student_id = s.student_id
);

-- 2.17 SELECT with CASE (Conditional logic)
SELECT 
    first_name,
    last_name,
    cgpa,
    CASE 
        WHEN cgpa >= 3.5 THEN 'Excellent'
        WHEN cgpa >= 3.0 THEN 'Good'
        WHEN cgpa >= 2.5 THEN 'Average'
        ELSE 'Needs Improvement'
    END AS performance_category
FROM Student;

-- 2.18 SELECT with UNION/UNION ALL
-- Combine results from multiple queries
SELECT first_name, last_name, 'Student' AS type FROM Student
UNION ALL
SELECT dept_name, dept_code, 'Department' AS type FROM Department;

-- =====================================================
-- SECTION 3: UPDATE COMMANDS
-- =====================================================

-- 3.1 Basic UPDATE
UPDATE Student 
SET phone = '9998887777' 
WHERE student_id = 1;

-- 3.2 UPDATE multiple columns
UPDATE Student 
SET 
    cgpa = 3.7,
    status = 'Graduated'
WHERE student_id = 2;

-- 3.3 UPDATE with calculation
UPDATE Student 
SET age = TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE());

-- 3.4 UPDATE with JOIN
-- Update CGPA for students in Computer Science department
UPDATE Student s
JOIN Department d ON s.dept_id = d.dept_id
SET s.cgpa = s.cgpa + 0.1
WHERE d.dept_name = 'Computer Science' AND s.cgpa < 4.0;

-- 3.5 UPDATE with subquery
-- Update status based on enrollment
UPDATE Student s
SET s.status = 'Inactive'
WHERE s.student_id NOT IN (
    SELECT DISTINCT student_id FROM Enrollment
);

-- 3.6 UPDATE with LIMIT
UPDATE Student 
SET cgpa = cgpa + 0.05
WHERE cgpa < 3.0
ORDER BY cgpa ASC
LIMIT 2;

-- 3.7 UPDATE multiple tables
UPDATE Student s
JOIN Enrollment e ON s.student_id = e.student_id
SET 
    s.status = 'Active',
    e.grade = 'W'
WHERE e.semester = 'Fall' AND e.year = 2023;

-- =====================================================
-- SECTION 4: DELETE COMMANDS
-- =====================================================

-- 4.1 Basic DELETE
DELETE FROM Enrollment 
WHERE enrollment_id = 1;

-- 4.2 DELETE with WHERE clause
DELETE FROM Student 
WHERE status = 'Graduated' AND student_id > 100;

-- 4.3 DELETE with JOIN
-- Delete enrollments for students with low CGPA
DELETE e
FROM Enrollment e
JOIN Student s ON e.student_id = s.student_id
WHERE s.cgpa < 2.0;

-- 4.4 DELETE with subquery
DELETE FROM Student
WHERE student_id IN (
    SELECT student_id FROM (
        SELECT s.student_id 
        FROM Student s
        LEFT JOIN Enrollment e ON s.student_id = e.student_id
        WHERE e.student_id IS NULL
    ) AS temp
);

-- 4.5 DELETE with LIMIT
DELETE FROM Enrollment 
WHERE grade IS NULL
LIMIT 5;

-- 4.6 DELETE all rows (but keep table structure)
DELETE FROM Department_Backup;

-- =====================================================
-- SECTION 5: REPLACE COMMAND
-- =====================================================

-- 5.1 REPLACE (INSERT or DELETE+INSERT)
REPLACE INTO Department (dept_id, dept_name, dept_code, budget)
VALUES (1, 'Computer Science and Engineering', 'CSE', 600000.00);

-- 5.2 REPLACE with multiple rows
REPLACE INTO Student (student_id, first_name, last_name, email, phone, date_of_birth, dept_id)
VALUES 
    (1, 'Johnathan', 'Doe', 'john.doe@email.com', '1234567890', '2000-05-15', 1),
    (6, 'New', 'Student', 'new.student@email.com', '7778889999', '2002-01-01', 2);

-- =====================================================
-- SECTION 6: TRANSACTION CONTROL
-- =====================================================

-- 6.1 Start a transaction
START TRANSACTION;

-- Perform operations
INSERT INTO Department (dept_name, dept_code) VALUES ('Physics', 'PHY');
UPDATE Student SET cgpa = cgpa + 0.1 WHERE dept_id = 1;

-- View changes (only visible in this transaction)
SELECT * FROM Department WHERE dept_code = 'PHY';

-- 6.2 Commit transaction (save changes permanently)
COMMIT;

-- 6.3 Rollback transaction (undo changes)
START TRANSACTION;
DELETE FROM Student WHERE student_id = 5;
-- Oops, wrong student! Undo...
ROLLBACK;

-- 6.4 SAVEPOINT (partial rollback)
START TRANSACTION;

INSERT INTO Department (dept_name, dept_code) VALUES ('Astronomy', 'AST');
SAVEPOINT after_dept_insert;

INSERT INTO Student (first_name, last_name, email, date_of_birth, dept_id) 
VALUES ('Test', 'User', 'test@email.com', '2000-01-01', LAST_INSERT_ID());

-- Something went wrong with student insert
ROLLBACK TO SAVEPOINT after_dept_insert;
-- Department insert preserved, student insert rolled back

COMMIT;

-- 6.5 Transaction with error handling
START TRANSACTION;

INSERT INTO Department (dept_name, dept_code) VALUES ('Geology', 'GEO');
INSERT INTO Student (first_name, last_name, email, date_of_birth, dept_id) 
VALUES ('Rock', 'Hunter', 'rock.hunter@email.com', '1999-12-12', LAST_INSERT_ID());

-- Check if everything is OK
-- If OK:
COMMIT;
-- If not:
-- ROLLBACK;

-- 6.6 AUTOCOMMIT setting
-- Check current autocommit setting
SELECT @@AUTOCOMMIT;

-- Disable autocommit
SET AUTOCOMMIT = 0;

-- Perform operations (need explicit COMMIT)
INSERT INTO Department (dept_name, dept_code) VALUES ('Statistics', 'STAT');
-- Changes not yet permanent

COMMIT; -- Now permanent

-- Re-enable autocommit
SET AUTOCOMMIT = 1;

-- =====================================================
-- SECTION 7: LOCKING MECHANISMS
-- =====================================================

-- 7.1 LOCK TABLES (for data integrity)
LOCK TABLES Student READ, Enrollment WRITE;

-- Can read from Student
SELECT * FROM Student LIMIT 1;

-- Can write to Enrollment
UPDATE Enrollment SET grade = 'A' WHERE enrollment_id = 1;

-- Cannot write to Student (read lock)
-- UPDATE Student SET phone = '1111111111' WHERE student_id = 1; -- This would fail

-- Release locks
UNLOCK TABLES;

-- 7.2 SELECT ... FOR UPDATE (row-level locking)
START TRANSACTION;

-- Lock specific rows for update
SELECT * FROM Student 
WHERE dept_id = 1 
FOR UPDATE;

-- Perform updates on locked rows
UPDATE Student SET cgpa = cgpa + 0.05 WHERE dept_id = 1;

COMMIT; -- Locks released

-- 7.3 SELECT ... LOCK IN SHARE MODE
START TRANSACTION;

-- Shared lock (other transactions can read but not modify)
SELECT * FROM Course 
WHERE course_id = 1 
LOCK IN SHARE MODE;

-- Other session can read, but cannot update/delete this row

COMMIT;

-- =====================================================
-- SECTION 8: BULK OPERATIONS
-- =====================================================

-- 8.1 Bulk INSERT with SELECT
CREATE TABLE HighAchievers AS
SELECT student_id, first_name, last_name, cgpa 
FROM Student 
WHERE cgpa >= 3.5;

-- 8.2 INSERT with SELECT from multiple tables
INSERT INTO Student (first_name, last_name, email, date_of_birth, dept_id)
SELECT 
    CONCAT('Temp', dept_id), 
    dept_code, 
    LOWER(CONCAT(dept_code, '@temp.edu')), 
    CURDATE() - INTERVAL 20 YEAR,
    dept_id
FROM Department
WHERE dept_id NOT IN (SELECT DISTINCT dept_id FROM Student WHERE dept_id IS NOT NULL);

-- 8.3 Bulk UPDATE with JOIN
UPDATE Student s
JOIN (
    SELECT student_id, AVG(CASE 
        WHEN grade = 'A+' THEN 4.0
        WHEN grade = 'A' THEN 4.0
        WHEN grade = 'A-' THEN 3.7
        WHEN grade = 'B+' THEN 3.3
        WHEN grade = 'B' THEN 3.0
        WHEN grade = 'B-' THEN 2.7
        WHEN grade = 'C+' THEN 2.3
        WHEN grade = 'C' THEN 2.0
        WHEN grade = 'C-' THEN 1.7
        WHEN grade = 'D' THEN 1.0
        ELSE 0.0
    END) as calculated_cgpa
    FROM Enrollment
    GROUP BY student_id
) e ON s.student_id = e.student_id
SET s.cgpa = e.calculated_cgpa;

-- =====================================================
-- SECTION 9: EXPLAIN (Query Analysis)
-- =====================================================

-- 9.1 Analyze query execution plan
EXPLAIN SELECT * FROM Student WHERE cgpa > 3.5;

-- 9.2 EXPLAIN with JOIN
EXPLAIN SELECT 
    s.first_name, 
    c.course_name 
FROM Student s
JOIN Enrollment e ON s.student_id = e.student_id
JOIN Course c ON e.course_id = c.course_id
WHERE s.dept_id = 1;

-- 9.3 EXPLAIN FORMAT=JSON (detailed output)
EXPLAIN FORMAT=JSON 
SELECT * FROM Student 
WHERE last_name LIKE 'S%' AND dept_id IN (1, 2);

-- =====================================================
-- SECTION 10: DATA IMPORT/EXPORT OPERATIONS
-- =====================================================

-- 10.1 Export to CSV
SELECT * FROM Student 
INTO OUTFILE '/tmp/students.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- 10.2 Import from CSV
LOAD DATA INFILE '/tmp/students.csv'
INTO TABLE Student
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 10.3 Create table from SELECT result
CREATE TABLE StudentSummary AS
SELECT 
    d.dept_name,
    COUNT(s.student_id) AS student_count,
    AVG(s.cgpa) AS avg_cgpa
FROM Department d
LEFT JOIN Student s ON d.dept_id = s.dept_id
GROUP BY d.dept_id;

-- =====================================================
-- SECTION 11: CLEANUP AND MAINTENANCE
-- =====================================================

-- 11.1 Check table integrity
CHECK TABLE Student;

-- 11.2 Optimize table (reclaim unused space)
OPTIMIZE TABLE Student;

-- 11.3 Analyze table (update statistics)
ANALYZE TABLE Student;

-- 11.4 Repair table (if corrupted)
REPAIR TABLE Student;

-- =====================================================
-- SECTION 12: PRACTICAL USE CASES
-- =====================================================

-- 12.1 Generate academic report
SELECT 
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name) AS full_name,
    d.dept_name,
    COUNT(e.course_id) AS courses_enrolled,
    AVG(CASE 
        WHEN e.grade = 'A+' THEN 4.0
        WHEN e.grade = 'A' THEN 4.0
        WHEN e.grade = 'A-' THEN 3.7
        WHEN e.grade = 'B+' THEN 3.3
        WHEN e.grade = 'B' THEN 3.0
        WHEN e.grade = 'B-' THEN 2.7
        WHEN e.grade = 'C+' THEN 2.3
        WHEN e.grade = 'C' THEN 2.0
        WHEN e.grade = 'C-' THEN 1.7
        WHEN e.grade = 'D' THEN 1.0
        ELSE 0.0
    END) AS gpa
FROM Student s
LEFT JOIN Department d ON s.dept_id = d.dept_id
LEFT JOIN Enrollment e ON s.student_id = e.student_id
GROUP BY s.student_id
HAVING courses_enrolled > 0;

-- 12.2 Department-wise course popularity
SELECT 
    d.dept_name,
    c.course_name,
    COUNT(e.student_id) AS enrollment_count,
    c.max_students,
    (COUNT(e.student_id) / c.max_students) * 100 AS utilization_percentage
FROM Course c
JOIN Department d ON c.dept_id = d.dept_id
LEFT JOIN Enrollment e ON c.course_id = e.course_id
GROUP BY c.course_id
ORDER BY enrollment_count DESC;

-- 12.3 Student performance trend
SELECT 
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    e.year,
    e.semester,
    COUNT(e.course_id) AS courses_taken,
    AVG(CASE 
        WHEN e.grade = 'A+' THEN 4.0
        WHEN e.grade = 'A' THEN 4.0
        WHEN e.grade = 'A-' THEN 3.7
        WHEN e.grade = 'B+' THEN 3.3
        WHEN e.grade = 'B' THEN 3.0
        WHEN e.grade = 'B-' THEN 2.7
        WHEN e.grade = 'C+' THEN 2.3
        WHEN e.grade = 'C' THEN 2.0
        WHEN e.grade = 'C-' THEN 1.7
        WHEN e.grade = 'D' THEN 1.0
        ELSE 0.0
    END) AS semester_gpa
FROM Student s
JOIN Enrollment e ON s.student_id = e.student_id
GROUP BY s.student_id, e.year, e.semester
ORDER BY s.student_id, e.year DESC, 
    FIELD(e.semester, 'Spring', 'Summer', 'Fall', 'Winter');

