/*
Lecture 06: MYSQL DQL Commands and use cases 
Objective: Learn DQL Commands to build effective database with constraints 
Author : Chandan Chaudhari

DQL (Data Query Language) Commands covered:
- SELECT (Advanced) : Complex data retrieval with various clauses
- Subqueries        : Nested queries for sophisticated filtering
- Common Table Expressions (CTE) : Temporary result sets
- Window Functions  : Advanced analytical queries
- Recursive Queries : Hierarchical data retrieval
- JSON Functions    : Working with JSON data
- Performance Tuning: Query optimization techniques

Note: While SELECT is technically the only DQL command, this lecture covers
advanced querying capabilities that go beyond basic data manipulation.
*/

-- =====================================================
-- SECTION 0: SETUP - Enhanced Database Schema
-- =====================================================

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS UniversityDB;
USE UniversityDB;

-- Enhanced schema with additional tables for complex queries
-- Department table
CREATE TABLE IF NOT EXISTS Department (
    dept_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(100) NOT NULL UNIQUE,
    dept_code VARCHAR(10) NOT NULL UNIQUE,
    established_year YEAR,
    budget DECIMAL(10,2) DEFAULT 100000.00,
    location VARCHAR(100),
    dean_name VARCHAR(100),
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
    age INT GENERATED ALWAYS AS (TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE())) STORED,
    dept_id INT,
    enrollment_date DATE DEFAULT (CURRENT_DATE),
    cgpa DECIMAL(3,2),
    status ENUM('Active', 'Graduated', 'Suspended', 'On Leave') DEFAULT 'Active',
    scholarship_amount DECIMAL(10,2) DEFAULT 0.00,
    parent_income DECIMAL(10,2),
    address JSON,  -- JSON column for structured address
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
    instructor_name VARCHAR(100),
    semester_offered SET('Fall', 'Spring', 'Summer', 'Winter'),  -- SET datatype
    prerequisites JSON,  -- JSON array of prerequisite course IDs
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
    attendance_percentage DECIMAL(5,2),
    feedback TEXT,
    FOREIGN KEY (student_id) REFERENCES Student(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Course(course_id) ON DELETE CASCADE,
    UNIQUE KEY unique_enrollment (student_id, course_id, semester, year)
);

-- Faculty table for more complex joins
CREATE TABLE IF NOT EXISTS Faculty (
    faculty_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15),
    dept_id INT,
    hire_date DATE,
    salary DECIMAL(10,2),
    specialization VARCHAR(100),
    research_area JSON,  -- JSON array
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id) ON DELETE SET NULL
);

-- Course-Faculty assignment (many-to-many)
CREATE TABLE IF NOT EXISTS CourseAssignment (
    assignment_id INT PRIMARY KEY AUTO_INCREMENT,
    course_id INT NOT NULL,
    faculty_id INT NOT NULL,
    semester VARCHAR(20) NOT NULL,
    year YEAR NOT NULL,
    role ENUM('Primary', 'Assistant', 'Guest') DEFAULT 'Primary',
    FOREIGN KEY (course_id) REFERENCES Course(course_id) ON DELETE CASCADE,
    FOREIGN KEY (faculty_id) REFERENCES Faculty(faculty_id) ON DELETE CASCADE,
    UNIQUE KEY unique_assignment (course_id, faculty_id, semester, year)
);

-- Create indexes for performance
CREATE INDEX idx_student_dept ON Student(dept_id);
CREATE INDEX idx_student_cgpa ON Student(cgpa);
CREATE INDEX idx_enrollment_grade ON Enrollment(grade);
CREATE INDEX idx_course_dept ON Course(dept_id);
CREATE INDEX idx_faculty_dept ON Faculty(dept_id);

-- Insert sample data for complex queries
-- Departments
INSERT INTO Department (dept_name, dept_code, established_year, budget, location, dean_name) VALUES
('Computer Science', 'CS', 2000, 500000.00, 'Engineering Block A', 'Dr. Alan Turing'),
('Electrical Engineering', 'EE', 1998, 450000.00, 'Engineering Block B', 'Dr. Nikola Tesla'),
('Mechanical Engineering', 'ME', 1995, 400000.00, 'Engineering Block C', 'Dr. James Watt'),
('Civil Engineering', 'CE', 2005, 350000.00, 'Engineering Block D', 'Dr. Isambard Brunel'),
('Mathematics', 'MATH', 2010, 250000.00, 'Science Block', 'Dr. Ada Lovelace'),
('Physics', 'PHY', 2008, 300000.00, 'Science Block', 'Dr. Albert Einstein');

-- Students with JSON address
INSERT INTO Student (first_name, last_name, email, phone, date_of_birth, dept_id, cgpa, status, scholarship_amount, parent_income, address) VALUES
('John', 'Doe', 'john.doe@email.com', '1234567890', '2000-05-15', 1, 3.5, 'Active', 5000.00, 60000.00, 
 '{"street": "123 Main St", "city": "Boston", "state": "MA", "zip": "02108", "country": "USA"}'),
('Jane', 'Smith', 'jane.smith@email.com', '9876543210', '2001-08-22', 2, 3.8, 'Active', 7500.00, 45000.00,
 '{"street": "456 Oak Ave", "city": "Cambridge", "state": "MA", "zip": "02139", "country": "USA"}'),
('Bob', 'Johnson', 'bob.j@email.com', '5555555555', '2000-11-30', 1, 3.2, 'Active', 3000.00, 75000.00,
 '{"street": "789 Pine Rd", "city": "Somerville", "state": "MA", "zip": "02143", "country": "USA"}'),
('Alice', 'Williams', 'alice.w@email.com', '1112223333', '2002-03-10', 3, 3.9, 'Active', 10000.00, 35000.00,
 '{"street": "321 Elm St", "city": "Boston", "state": "MA", "zip": "02110", "country": "USA"}'),
('Charlie', 'Brown', 'charlie.b@email.com', '4445556666', '2001-07-25', 2, 2.8, 'Active', 0.00, 85000.00,
 '{"street": "654 Maple Dr", "city": "Medford", "state": "MA", "zip": "02155", "country": "USA"}'),
('Diana', 'Prince', 'diana.p@email.com', '7778889999', '2000-12-01', 4, 3.7, 'Active', 6000.00, 55000.00,
 '{"street": "987 Cedar Ln", "city": "Quincy", "state": "MA", "zip": "02169", "country": "USA"}'),
('Bruce', 'Wayne', 'bruce.w@email.com', '2223334444', '1999-09-15', 5, 4.0, 'Active', 20000.00, 1000000.00,
 '{"street": "1 Wayne Manor", "city": "Gotham", "state": "NY", "zip": "10001", "country": "USA"}'),
('Clark', 'Kent', 'clark.k@email.com', '6667778888', '2000-06-18', 6, 3.6, 'Active', 8000.00, 40000.00,
 '{"street": "100 Farm Rd", "city": "Smallville", "state": "KS", "zip": "66002", "country": "USA"}');

-- Courses with JSON prerequisites
INSERT INTO Course (course_code, course_name, credits, dept_id, max_students, instructor_name, semester_offered, prerequisites) VALUES
('CS101', 'Introduction to Programming', 4, 1, 50, 'Prof. Knuth', 'Fall,Spring', NULL),
('CS201', 'Data Structures', 4, 1, 40, 'Prof. Dijkstra', 'Fall,Spring', '[1]'),
('CS301', 'Database Systems', 3, 1, 45, 'Prof. Codd', 'Fall,Spring', '[1,2]'),
('CS401', 'Artificial Intelligence', 4, 1, 30, 'Prof. McCarthy', 'Fall', '[2,3]'),
('EE101', 'Circuit Analysis', 3, 2, 35, 'Prof. Ohm', 'Fall,Spring', NULL),
('EE201', 'Digital Electronics', 4, 2, 30, 'Prof. Boole', 'Spring', '[5]'),
('ME101', 'Thermodynamics', 4, 3, 30, 'Prof. Carnot', 'Fall,Spring', NULL),
('ME201', 'Fluid Mechanics', 3, 3, 25, 'Prof. Bernoulli', 'Spring', '[7]'),
('MATH201', 'Linear Algebra', 3, 5, 40, 'Prof. Hilbert', 'Fall,Spring', NULL),
('MATH301', 'Differential Equations', 4, 5, 35, 'Prof. Euler', 'Spring', '[9]'),
('PHY101', 'Classical Mechanics', 4, 6, 40, 'Prof. Newton', 'Fall,Spring', NULL),
('PHY201', 'Quantum Physics', 4, 6, 25, 'Prof. Schrödinger', 'Fall', '[11]');

-- Enrollment data with grades
INSERT INTO Enrollment (student_id, course_id, semester, year, grade, attendance_percentage, feedback) VALUES
(1, 1, 'Fall', 2023, 'A', 95.5, 'Excellent student,积极参与'),
(1, 2, 'Fall', 2023, 'B+', 88.0, 'Good work, needs to improve programming style'),
(2, 5, 'Fall', 2023, 'A-', 92.3, 'Very good understanding of concepts'),
(3, 1, 'Fall', 2023, 'B', 85.5, 'Satisfactory performance'),
(4, 7, 'Fall', 2023, 'A+', 98.0, 'Outstanding! Best in class'),
(5, 2, 'Fall', 2023, 'C+', 75.0, 'Needs more practice'),
(2, 6, 'Fall', 2023, 'B+', 87.5, 'Good potential'),
(3, 8, 'Fall', 2023, 'B-', 82.0, 'Fair performance'),
(6, 3, 'Fall', 2023, 'A-', 91.0, 'Consistently good'),
(7, 9, 'Fall', 2023, 'A+', 99.0, 'Exceptional mathematical ability'),
(8, 11, 'Fall', 2023, 'A', 94.0, 'Excellent grasp of concepts'),
(1, 3, 'Spring', 2024, NULL, NULL, NULL),  -- Currently enrolled, no grade yet
(2, 5, 'Spring', 2024, NULL, NULL, NULL),
(3, 2, 'Spring', 2024, NULL, NULL, NULL);

-- Faculty data
INSERT INTO Faculty (first_name, last_name, email, phone, dept_id, hire_date, salary, specialization, research_area) VALUES
('Alan', 'Turing', 'a.turing@university.edu', '1111111111', 1, '2010-08-15', 120000.00, 'Computer Science', '["AI", "Cryptography", "Computability"]'),
('Donald', 'Knuth', 'd.knuth@university.edu', '2222222222', 1, '2015-01-10', 150000.00, 'Algorithms', '["TeX", "Algorithm Analysis", "Programming"]'),
('Edsger', 'Dijkstra', 'e.dijkstra@university.edu', '3333333333', 1, '2012-03-20', 130000.00, 'Programming', '["Concurrency", "Graph Algorithms", "Formal Methods"]'),
('Nikola', 'Tesla', 'n.tesla@university.edu', '4444444444', 2, '2008-05-05', 110000.00, 'Electrical Engineering', '["AC Motors", "Wireless Power", "Electromagnetism"]'),
('James', 'Watt', 'j.watt@university.edu', '5555555555', 3, '2009-11-12', 115000.00, 'Mechanical Engineering', '["Steam Engines", "Thermodynamics", "Energy"]'),
('Ada', 'Lovelace', 'a.lovelace@university.edu', '6666666666', 5, '2016-07-01', 125000.00, 'Mathematics', '["Computing", "Numerical Analysis", "Algorithms"]'),
('Albert', 'Einstein', 'a.einstein@university.edu', '7777777777', 6, '2005-09-01', 140000.00, 'Physics', '["Relativity", "Quantum Mechanics", "Cosmology"]');

-- Course assignments
INSERT INTO CourseAssignment (course_id, faculty_id, semester, year, role) VALUES
(1, 2, 'Fall', 2023, 'Primary'),
(1, 3, 'Fall', 2023, 'Assistant'),
(2, 3, 'Fall', 2023, 'Primary'),
(3, 1, 'Fall', 2023, 'Primary'),
(5, 4, 'Fall', 2023, 'Primary'),
(7, 5, 'Fall', 2023, 'Primary'),
(9, 6, 'Fall', 2023, 'Primary'),
(11, 7, 'Fall', 2023, 'Primary');

-- =====================================================
-- SECTION 1: ADVANCED SELECT TECHNIQUES
-- =====================================================

-- 1.1 SELECT with Common Table Expressions (CTE)
-- Find students with above-average CGPA in their department
WITH DeptAverage AS (
    SELECT 
        dept_id,
        AVG(cgpa) AS avg_dept_cgpa
    FROM Student
    GROUP BY dept_id
)
SELECT 
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    d.dept_name,
    s.cgpa,
    da.avg_dept_cgpa,
    s.cgpa - da.avg_dept_cgpa AS difference_from_avg
FROM Student s
JOIN Department d ON s.dept_id = d.dept_id
JOIN DeptAverage da ON s.dept_id = da.dept_id
WHERE s.cgpa > da.avg_dept_cgpa
ORDER BY difference_from_avg DESC;

-- 1.2 Multiple CTEs for complex analysis
WITH 
StudentStats AS (
    SELECT 
        dept_id,
        COUNT(*) AS total_students,
        AVG(cgpa) AS avg_cgpa,
        MAX(cgpa) AS max_cgpa,
        MIN(cgpa) AS min_cgpa
    FROM Student
    GROUP BY dept_id
),
EnrollmentStats AS (
    SELECT 
        s.dept_id,
        COUNT(DISTINCT e.student_id) AS enrolled_students,
        COUNT(e.course_id) AS total_enrollments
    FROM Student s
    LEFT JOIN Enrollment e ON s.student_id = e.student_id
    GROUP BY s.dept_id
)
SELECT 
    d.dept_name,
    ss.total_students,
    ss.avg_cgpa,
    ss.max_cgpa,
    ss.min_cgpa,
    es.enrolled_students,
    es.total_enrollments,
    ROUND(es.total_enrollments / NULLIF(es.enrolled_students, 0), 2) AS avg_courses_per_student
FROM Department d
LEFT JOIN StudentStats ss ON d.dept_id = ss.dept_id
LEFT JOIN EnrollmentStats es ON d.dept_id = es.dept_id
ORDER BY ss.avg_cgpa DESC;

-- 1.3 SELECT with Window Functions
-- Ranking students by CGPA within their department
SELECT 
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    d.dept_name,
    s.cgpa,
    ROW_NUMBER() OVER (PARTITION BY s.dept_id ORDER BY s.cgpa DESC) AS dept_rank,
    RANK() OVER (PARTITION BY s.dept_id ORDER BY s.cgpa DESC) AS dept_rank_with_gaps,
    DENSE_RANK() OVER (PARTITION BY s.dept_id ORDER BY s.cgpa DESC) AS dept_dense_rank,
    PERCENT_RANK() OVER (PARTITION BY s.dept_id ORDER BY s.cgpa DESC) AS percentile_rank
FROM Student s
JOIN Department d ON s.dept_id = d.dept_id
ORDER BY d.dept_name, s.cgpa DESC;

-- 1.4 Window Functions with Aggregates
-- Running totals and moving averages
SELECT 
    e.year,
    e.semester,
    c.course_name,
    COUNT(e.student_id) AS enrollment_count,
    SUM(COUNT(e.student_id)) OVER (ORDER BY e.year, e.semester) AS running_total_enrollments,
    AVG(COUNT(e.student_id)) OVER (ORDER BY e.year, e.semester ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_3_periods
FROM Enrollment e
JOIN Course c ON e.course_id = c.course_id
GROUP BY e.year, e.semester, c.course_name
ORDER BY e.year, e.semester;

-- 1.5 Window Functions for Comparative Analysis
-- Compare each student's CGPA with department average and top performer
SELECT 
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    d.dept_name,
    s.cgpa,
    AVG(s.cgpa) OVER (PARTITION BY s.dept_id) AS dept_avg_cgpa,
    MAX(s.cgpa) OVER (PARTITION BY s.dept_id) AS dept_max_cgpa,
    s.cgpa - AVG(s.cgpa) OVER (PARTITION BY s.dept_id) AS diff_from_avg,
    FIRST_VALUE(CONCAT(s.first_name, ' ', s.last_name)) OVER (PARTITION BY s.dept_id ORDER BY s.cgpa DESC) AS top_student_in_dept
FROM Student s
JOIN Department d ON s.dept_id = d.dept_id
ORDER BY d.dept_name, s.cgpa DESC;

-- 1.6 SELECT with LAG and LEAD (Time-based analysis)
-- Track CGPA changes over semesters
WITH StudentGrades AS (
    SELECT 
        s.student_id,
        CONCAT(s.first_name, ' ', s.last_name) AS student_name,
        e.year,
        e.semester,
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
    WHERE e.grade IS NOT NULL
    GROUP BY s.student_id, e.year, e.semester
)
SELECT 
    student_name,
    year,
    semester,
    semester_gpa,
    LAG(semester_gpa) OVER (PARTITION BY student_id ORDER BY year, 
        FIELD(semester, 'Spring', 'Summer', 'Fall', 'Winter')) AS previous_semester_gpa,
    semester_gpa - LAG(semester_gpa) OVER (PARTITION BY student_id ORDER BY year, 
        FIELD(semester, 'Spring', 'Summer', 'Fall', 'Winter')) AS gpa_change,
    LEAD(semester_gpa) OVER (PARTITION BY student_id ORDER BY year, 
        FIELD(semester, 'Spring', 'Summer', 'Fall', 'Winter')) AS next_semester_gpa
FROM StudentGrades
ORDER BY student_name, year, FIELD(semester, 'Spring', 'Summer', 'Fall', 'Winter');

-- =====================================================
-- SECTION 2: ADVANCED SUBQUERIES
-- =====================================================

-- 2.1 Correlated Subqueries
-- Find students who are above average for their department
SELECT 
    CONCAT(s1.first_name, ' ', s1.last_name) AS student_name,
    d.dept_name,
    s1.cgpa
FROM Student s1
JOIN Department d ON s1.dept_id = d.dept_id
WHERE s1.cgpa > (
    SELECT AVG(s2.cgpa)
    FROM Student s2
    WHERE s2.dept_id = s1.dept_id
)
ORDER BY d.dept_name, s1.cgpa DESC;

-- 2.2 EXISTS vs IN performance comparison
-- Find students who have enrolled in at least one course (using EXISTS)
SELECT 
    CONCAT(first_name, ' ', last_name) AS student_name
FROM Student s
WHERE EXISTS (
    SELECT 1
    FROM Enrollment e
    WHERE e.student_id = s.student_id
);

-- Find students who have enrolled in at least one course (using IN)
SELECT 
    CONCAT(first_name, ' ', last_name) AS student_name
FROM Student
WHERE student_id IN (
    SELECT DISTINCT student_id
    FROM Enrollment
);

-- 2.3 Subqueries in SELECT clause
SELECT 
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    d.dept_name,
    s.cgpa,
    (SELECT AVG(cgpa) FROM Student) AS overall_avg_cgpa,
    (SELECT COUNT(*) FROM Enrollment e WHERE e.student_id = s.student_id) AS courses_enrolled,
    (SELECT MAX(grade) FROM Enrollment e WHERE e.student_id = s.student_id) AS best_grade
FROM Student s
JOIN Department d ON s.dept_id = d.dept_id
ORDER BY s.cgpa DESC;

-- 2.4 Subqueries in FROM clause (Derived Tables)
-- Find departments with the highest variance in student performance
SELECT 
    dept_name,
    avg_cgpa,
    cgpa_variance,
    student_count
FROM (
    SELECT 
        d.dept_name,
        AVG(s.cgpa) AS avg_cgpa,
        VARIANCE(s.cgpa) AS cgpa_variance,
        COUNT(s.student_id) AS student_count
    FROM Department d
    LEFT JOIN Student s ON d.dept_id = s.dept_id
    GROUP BY d.dept_id, d.dept_name
) AS dept_stats
WHERE student_count > 1
ORDER BY cgpa_variance DESC;

-- 2.5 Scalar Subqueries with CASE
-- Categorize students based on enrollment patterns
SELECT 
    CONCAT(first_name, ' ', last_name) AS student_name,
    cgpa,
    CASE 
        WHEN (SELECT COUNT(*) FROM Enrollment WHERE student_id = s.student_id) = 0 THEN 'No Courses'
        WHEN (SELECT COUNT(*) FROM Enrollment WHERE student_id = s.student_id) <= 2 THEN 'Part Time'
        WHEN (SELECT COUNT(*) FROM Enrollment WHERE student_id = s.student_id) <= 4 THEN 'Full Time'
        ELSE 'Overloaded'
    END AS enrollment_status,
    (SELECT AVG(attendance_percentage) FROM Enrollment WHERE student_id = s.student_id) AS avg_attendance
FROM Student s
ORDER BY enrollment_status;

-- =====================================================
-- SECTION 3: RECURSIVE QUERIES (CTE)
-- =====================================================

-- 3.1 Generate a number series (simple recursion)
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM numbers
    WHERE n < 10
)
SELECT * FROM numbers;

-- 3.2 Generate date series
WITH RECURSIVE dates AS (
    SELECT DATE('2024-01-01') AS date
    UNION ALL
    SELECT DATE_ADD(date, INTERVAL 1 DAY)
    FROM dates
    WHERE date < '2024-01-31'
)
SELECT * FROM dates;

-- 3.3 Simulate course prerequisite chain
WITH RECURSIVE CoursePrereq AS (
    -- Anchor: Start with a specific course
    SELECT 
        course_id,
        course_code,
        course_name,
        prerequisites,
        1 AS level,
        CAST(course_code AS CHAR(200)) AS path
    FROM Course
    WHERE course_code = 'CS401'  -- AI course
    
    UNION ALL
    
    -- Recursive: Find prerequisites
    SELECT 
        c.course_id,
        c.course_code,
        c.course_name,
        c.prerequisites,
        cp.level + 1,
        CONCAT(cp.path, ' -> ', c.course_code)
    FROM Course c
    JOIN CoursePrereq cp ON JSON_CONTAINS(cp.prerequisites, CAST(c.course_id AS JSON))
)
SELECT * FROM CoursePrereq
ORDER BY level;

-- 3.4 Organizational hierarchy simulation
WITH RECURSIVE FacultyHierarchy AS (
    -- Simplified hierarchy based on department and role
    SELECT 
        faculty_id,
        CONCAT(first_name, ' ', last_name) AS faculty_name,
        dept_id,
        0 AS level
    FROM Faculty
    WHERE faculty_id = 1  -- Start with a specific faculty
    
    UNION ALL
    
    -- This is simulated - in real scenario, you'd have manager_id column
    SELECT 
        f.faculty_id,
        CONCAT(f.first_name, ' ', f.last_name),
        f.dept_id,
        fh.level + 1
    FROM Faculty f
    JOIN FacultyHierarchy fh ON f.dept_id = fh.dept_id AND f.faculty_id != fh.faculty_id
    WHERE fh.level < 2  -- Limit depth
)
SELECT * FROM FacultyHierarchy;

-- =====================================================
-- SECTION 4: JSON DATA QUERYING
-- =====================================================

-- 4.1 Extract data from JSON columns
SELECT 
    CONCAT(first_name, ' ', last_name) AS student_name,
    JSON_EXTRACT(address, '$.city') AS city,
    JSON_EXTRACT(address, '$.state') AS state,
    JSON_EXTRACT(address, '$.country') AS country
FROM Student
WHERE JSON_EXTRACT(address, '$.city') = '"Boston"';

-- 4.2 JSON functions for complex extraction
SELECT 
    CONCAT(first_name, ' ', last_name) AS student_name,
    address->>'$.street' AS street,
    address->>'$.city' AS city,
    address->>'$.zip' AS zip_code
FROM Student
WHERE address->>'$.state' = 'MA'
ORDER BY address->>'$.city';

-- 4.3 Query JSON arrays in prerequisites
SELECT 
    course_code,
    course_name,
    JSON_LENGTH(prerequisites) AS num_prerequisites,
    JSON_KEYS(prerequisites) AS prereq_indices,
    JSON_EXTRACT(prerequisites, '$[0]') AS first_prerequisite
FROM Course
WHERE JSON_LENGTH(prerequisites) > 0;

-- 4.4 Find courses with specific prerequisites
SELECT 
    course_code,
    course_name
FROM Course
WHERE JSON_CONTAINS(prerequisites, '1');  -- Course ID 1 is prerequisite

-- 4.5 JSON_TABLE (MySQL 8.0+) - Convert JSON to relational
SELECT 
    s.student_id,
    s.first_name,
    s.last_name,
    addr.*
FROM Student s,
JSON_TABLE(
    s.address,
    '$' COLUMNS(
        street VARCHAR(100) PATH '$.street',
        city VARCHAR(50) PATH '$.city',
        state VARCHAR(20) PATH '$.state',
        zip VARCHAR(10) PATH '$.zip',
        country VARCHAR(50) PATH '$.country'
    )
) AS addr
WHERE s.address IS NOT NULL;

-- 4.6 Aggregate JSON data
SELECT 
    d.dept_name,
    JSON_ARRAYAGG(
        JSON_OBJECT(
            'student_id', s.student_id,
            'name', CONCAT(s.first_name, ' ', s.last_name),
            'cgpa', s.cgpa
        )
    ) AS top_students_json
FROM Department d
JOIN Student s ON d.dept_id = s.dept_id
WHERE s.cgpa >= 3.5
GROUP BY d.dept_id;

-- =====================================================
-- SECTION 5: ADVANCED AGGREGATION AND GROUPING
-- =====================================================

-- 5.1 ROLLUP for hierarchical summaries
SELECT 
    d.dept_name,
    c.course_name,
    COUNT(e.student_id) AS enrollment_count,
    AVG(e.attendance_percentage) AS avg_attendance
FROM Department d
LEFT JOIN Course c ON d.dept_id = c.dept_id
LEFT JOIN Enrollment e ON c.course_id = e.course_id
GROUP BY d.dept_name, c.course_name WITH ROLLUP;

-- 5.2 CUBE for multi-dimensional analysis
-- Note: MySQL doesn't support CUBE directly, simulate with UNION
-- Simulating CUBE for (dept, semester, year)
SELECT 
    d.dept_name,
    e.semester,
    e.year,
    COUNT(e.student_id) AS enrollment_count
FROM Department d
JOIN Course c ON d.dept_id = c.dept_id
JOIN Enrollment e ON c.course_id = e.course_id
GROUP BY d.dept_name, e.semester, e.year

UNION ALL

-- All combinations with NULLs
SELECT 
    d.dept_name,
    e.semester,
    NULL,
    COUNT(e.student_id)
FROM Department d
JOIN Course c ON d.dept_id = c.dept_id
JOIN Enrollment e ON c.course_id = e.course_id
GROUP BY d.dept_name, e.semester

UNION ALL

SELECT 
    d.dept_name,
    NULL,
    e.year,
    COUNT(e.student_id)
FROM Department d
JOIN Course c ON d.dept_id = c.dept_id
JOIN Enrollment e ON c.course_id = e.course_id
GROUP BY d.dept_name, e.year

UNION ALL

SELECT 
    NULL,
    e.semester,
    e.year,
    COUNT(e.student_id)
FROM Department d
JOIN Course c ON d.dept_id = c.dept_id
JOIN Enrollment e ON c.course_id = e.course_id
GROUP BY e.semester, e.year

UNION ALL

SELECT 
    NULL,
    NULL,
    NULL,
    COUNT(e.student_id)
FROM Enrollment e;

-- 5.3 GROUP_CONCAT for string aggregation
SELECT 
    d.dept_name,
    COUNT(DISTINCT s.student_id) AS student_count,
    GROUP_CONCAT(DISTINCT CONCAT(s.first_name, ' ', s.last_name) 
                 ORDER BY s.cgpa DESC 
                 SEPARATOR '; ') AS student_names,
    GROUP_CONCAT(DISTINCT c.course_code SEPARATOR ', ') AS courses_offered
FROM Department d
LEFT JOIN Student s ON d.dept_id = s.dept_id
LEFT JOIN Course c ON d.dept_id = c.dept_id
GROUP BY d.dept_id;

-- 5.4 FILTERING with HAVING and complex conditions
SELECT 
    d.dept_name,
    COUNT(s.student_id) AS student_count,
    AVG(s.cgpa) AS avg_cgpa,
    SUM(CASE WHEN s.scholarship_amount > 0 THEN 1 ELSE 0 END) AS scholarship_students,
    AVG(s.scholarship_amount) AS avg_scholarship
FROM Department d
LEFT JOIN Student s ON d.dept_id = s.dept_id
GROUP BY d.dept_id
HAVING student_count > 0 
    AND avg_cgpa > 3.0
    AND scholarship_students > 0
ORDER BY avg_cgpa DESC;

-- =====================================================
-- SECTION 6: PIVOTING AND CROSS-TAB QUERIES
-- =====================================================

-- 6.1 Manual Pivot - Courses by semester
SELECT 
    c.course_name,
    SUM(CASE WHEN e.semester = 'Fall' THEN 1 ELSE 0 END) AS fall_enrollment,
    SUM(CASE WHEN e.semester = 'Spring' THEN 1 ELSE 0 END) AS spring_enrollment,
    SUM(CASE WHEN e.semester = 'Summer' THEN 1 ELSE 0 END) AS summer_enrollment,
    COUNT(*) AS total_enrollment
FROM Course c
LEFT JOIN Enrollment e ON c.course_id = e.course_id
GROUP BY c.course_id;

-- 6.2 Dynamic Pivot using GROUP_CONCAT and prepared statements
-- First, get unique semesters
SET @sql = NULL;
SELECT
    GROUP_CONCAT(DISTINCT
        CONCAT(
            'SUM(CASE WHEN semester = ''',
            semester,
            ''' THEN 1 ELSE 0 END) AS `',
            semester, '`'
        )
    ) INTO @sql
FROM Enrollment;

-- Construct and execute dynamic pivot query
SET @sql = CONCAT('SELECT course_name, ', @sql, ', COUNT(*) AS total 
                   FROM Course c 
                   LEFT JOIN Enrollment e ON c.course_id = e.course_id 
                   GROUP BY c.course_id');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 6.3 Grade distribution pivot
SELECT 
    c.course_code,
    c.course_name,
    COUNT(*) AS total_students,
    SUM(CASE WHEN e.grade = 'A+' OR e.grade = 'A' OR e.grade = 'A-' THEN 1 ELSE 0 END) AS A_grades,
    SUM(CASE WHEN e.grade = 'B+' OR e.grade = 'B' OR e.grade = 'B-' THEN 1 ELSE 0 END) AS B_grades,
    SUM(CASE WHEN e.grade = 'C+' OR e.grade = 'C' OR e.grade = 'C-' THEN 1 ELSE 0 END) AS C_grades,
    SUM(CASE WHEN e.grade = 'D' THEN 1 ELSE 0 END) AS D_grades,
    SUM(CASE WHEN e.grade = 'F' THEN 1 ELSE 0 END) AS F_grades,
    SUM(CASE WHEN e.grade IS NULL THEN 1 ELSE 0 END) AS ongoing
FROM Course c
JOIN Enrollment e ON c.course_id = e.course_id
GROUP BY c.course_id;

-- =====================================================
-- SECTION 7: PERFORMANCE OPTIMIZATION TECHNIQUES
-- =====================================================

-- 7.1 Analyze query performance with EXPLAIN
EXPLAIN ANALYZE
SELECT 
    s.first_name,
    s.last_name,
    COUNT(e.course_id) AS course_count
FROM Student s
LEFT JOIN Enrollment e ON s.student_id = e.student_id
WHERE s.cgpa > 3.0
GROUP BY s.student_id
HAVING course_count > 1;

-- 7.2 Use FORCE INDEX for query optimization
SELECT * 
FROM Student FORCE INDEX (idx_student_cgpa)
WHERE cgpa BETWEEN 3.0 AND 3.5
ORDER BY cgpa DESC;

-- 7.3 Partitioned query example (if tables were partitioned)
-- SELECT * FROM Enrollment PARTITION (p_fall2023);

-- 7.4 Use STRAIGHT_JOIN for join order control
SELECT STRAIGHT_JOIN
    s.first_name,
    s.last_name,
    c.course_name
FROM Student s
STRAIGHT_JOIN Enrollment e ON s.student_id = e.student_id
STRAIGHT_JOIN Course c ON e.course_id = c.course_id;

-- 7.5 Optimizer hints
SELECT /*+ INDEX(s idx_student_cgpa) */ 
    first_name, 
    last_name, 
    cgpa
FROM Student s
WHERE cgpa > 3.5;

-- =====================================================
-- SECTION 8: SET OPERATIONS
-- =====================================================

-- 8.1 UNION vs UNION ALL
-- Students and faculty combined list
SELECT 
    first_name,
    last_name,
    email,
    'Student' AS role
FROM Student
WHERE status = 'Active'

UNION ALL

SELECT 
    first_name,
    last_name,
    email,
    'Faculty' AS role
FROM Faculty
WHERE dept_id = 1;

-- 8.2 INTERSECT simulation (using IN with subquery)
-- Find students who are also faculty (simulated - not real scenario)
SELECT first_name, last_name, email
FROM Student
WHERE (first_name, last_name) IN (
    SELECT first_name, last_name
    FROM Faculty
);

-- 8.3 EXCEPT simulation (using NOT IN)
-- Students who are not enrolled in any course
SELECT student_id, first_name, last_name
FROM Student
WHERE student_id NOT IN (
    SELECT DISTINCT student_id
    FROM Enrollment
);

-- =====================================================
-- SECTION 9: TEMPORARY TABLES FOR COMPLEX QUERIES
-- =====================================================

-- 9.1 Create temporary table for intermediate results
CREATE TEMPORARY TABLE temp_student_stats AS
SELECT 
    dept_id,
    AVG(cgpa) AS avg_cgpa,
    STDDEV(cgpa) AS stddev_cgpa
FROM Student
GROUP BY dept_id;

-- Use temporary table in query
SELECT 
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    d.dept_name,
    s.cgpa,
    t.avg_cgpa,
    (s.cgpa - t.avg_cgpa) / NULLIF(t.stddev_cgpa, 0) AS z_score
FROM Student s
JOIN Department d ON s.dept_id = d.dept_id
JOIN temp_student_stats t ON s.dept_id = t.dept_id
ORDER BY z_score DESC;

-- 9.2 Temporary table with indexes
CREATE TEMPORARY TABLE temp_high_achievers (
    student_id INT PRIMARY KEY,
    full_name VARCHAR(101),
    cgpa DECIMAL(3,2),
    INDEX idx_cgpa (cgpa)
) AS
SELECT 
    student_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    cgpa
FROM Student
WHERE cgpa >= 3.5;

SELECT * FROM temp_high_achievers ORDER BY cgpa DESC;

-- Temporary tables are automatically dropped when session ends

-- =====================================================
-- SECTION 10: ADVANCED STRING AND DATE FUNCTIONS
-- =====================================================

-- 10.1 String manipulation in queries
SELECT 
    UPPER(CONCAT(first_name, ' ', last_name)) AS uppercase_name,
    LOWER(email) AS lowercase_email,
    LENGTH(CONCAT(first_name, last_name)) AS name_length,
    LEFT(phone, 3) AS area_code,
    RIGHT(phone, 4) AS last_four,
    SUBSTRING_INDEX(email, '@', 1) AS username,
    SUBSTRING_INDEX(email, '@', -1) AS domain
FROM Student
LIMIT 5;

-- 10.2 Regular expressions for pattern matching
SELECT 
    first_name,
    last_name,
    email
FROM Student
WHERE email REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$';  -- Valid email pattern

-- 10.3 Date arithmetic and formatting
SELECT 
    CONCAT(first_name, ' ', last_name) AS student_name,
    date_of_birth,
    DATE_FORMAT(date_of_birth, '%M %d, %Y') AS formatted_dob,
    DAYNAME(date_of_birth) AS birth_day_of_week,
    TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) AS current_age,
    DATE_ADD(date_of_birth, INTERVAL 18 YEAR) AS eligible_for_driving,
    DATEDIFF(CURDATE(), enrollment_date) AS days_since_enrollment
FROM Student;

-- 10.4 Complex date aggregations
SELECT 
    YEAR(enrollment_date) AS enrollment_year,
    QUARTER(enrollment_date) AS enrollment_quarter,
    MONTH(enrollment_date) AS enrollment_month,
    WEEK(enrollment_date) AS enrollment_week,
    DAYOFWEEK(enrollment_date) AS day_of_week,
    COUNT(*) AS enrollment_count
FROM Enrollment
GROUP BY enrollment_year, enrollment_quarter, enrollment_month
WITH ROLLUP;

-- =====================================================
-- SECTION 11: ANALYTICAL FUNCTIONS
-- =====================================================

-- 11.1 NTILE for quartile analysis
SELECT 
    CONCAT(first_name, ' ', last_name) AS student_name,
    cgpa,
    NTILE(4) OVER (ORDER BY cgpa) AS cgpa_quartile,
    NTILE(10) OVER (ORDER BY cgpa) AS cgpa_decile
FROM Student
WHERE cgpa IS NOT NULL;

-- 11.2 CUME_DIST and PERCENT_RANK
SELECT 
    CONCAT(first_name, ' ', last_name) AS student_name,
    cgpa,
    CUME_DIST() OVER (ORDER BY cgpa) AS cumulative_distribution,
    PERCENT_RANK() OVER (ORDER BY cgpa) AS percent_rank,
    ROUND(PERCENT_RANK() OVER (ORDER BY cgpa) * 100, 2) AS percentile
FROM Student
WHERE cgpa IS NOT NULL;

-- 11.3 FIRST_VALUE, LAST_VALUE with window frames
SELECT 
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    d.dept_name,
    s.cgpa,
    FIRST_VALUE(CONCAT(s.first_name, ' ', s.last_name)) OVER (
        PARTITION BY s.dept_id 
        ORDER BY s.cgpa DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS dept_topper,
    LAST_VALUE(CONCAT(s.first_name, ' ', s.last_name)) OVER (
        PARTITION BY s.dept_id 
        ORDER BY s.cgpa DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS dept_bottom
FROM Student s
JOIN Department d ON s.dept_id = d.dept_id
WHERE s.cgpa IS NOT NULL;

-- 11.4 NTH_VALUE for finding specific ranked students
SELECT DISTINCT
    d.dept_name,
    NTH_VALUE(CONCAT(s.first_name, ' ', s.last_name), 2) OVER (
        PARTITION BY s.dept_id 
        ORDER BY s.cgpa DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS second_best_student,
    NTH_VALUE(s.cgpa, 2) OVER (
        PARTITION BY s.dept_id 
        ORDER BY s.cgpa DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS second_best_cgpa
FROM Student s
JOIN Department d ON s.dept_id = d.dept_id
WHERE s.cgpa IS NOT NULL;

-- =====================================================
-- SECTION 12: COMPLEX BUSINESS QUERIES (Use Cases)
-- =====================================================

-- 12.1 Scholarship eligibility analysis
WITH StudentRanking AS (
    SELECT 
        s.student_id,
        CONCAT(s.first_name, ' ', s.last_name) AS student_name,
        d.dept_name,
        s.cgpa,
        s.parent_income,
        s.scholarship_amount,
        COUNT(e.course_id) AS courses_taken,
        AVG(e.attendance_percentage) AS avg_attendance,
        ROW_NUMBER() OVER (PARTITION BY s.dept_id ORDER BY s.cgpa DESC) AS rank_in_dept
    FROM Student s
    JOIN Department d ON s.dept_id = d.dept_id
    LEFT JOIN Enrollment e ON s.student_id = e.student_id
    WHERE s.status = 'Active'
    GROUP BY s.student_id
)
SELECT 
    student_name,
    dept_name,
    cgpa,
    parent_income,
    CASE 
        WHEN cgpa >= 3.8 AND parent_income < 50000 AND avg_attendance > 90 THEN 'Eligible - High Merit + Need'
        WHEN cgpa >= 3.5 AND rank_in_dept <= 3 THEN 'Eligible - Department Merit'
        WHEN cgpa >= 3.0 AND parent_income < 30000 THEN 'Eligible - Financial Need'
        ELSE 'Not Eligible'
    END AS scholarship_status,
    CASE 
        WHEN cgpa >= 3.8 AND parent_income < 50000 THEN 10000
        WHEN cgpa >= 3.5 AND rank_in_dept <= 3 THEN 5000
        WHEN cgpa >= 3.0 AND parent_income < 30000 THEN 3000
        ELSE 0
    END AS recommended_amount
FROM StudentRanking
ORDER BY recommended_amount DESC, cgpa DESC;

-- 12.2 Course demand and capacity planning
SELECT 
    c.course_code,
    c.course_name,
    d.dept_name,
    c.max_students,
    COUNT(e.student_id) AS current_enrollment,
    c.max_students - COUNT(e.student_id) AS available_seats,
    CASE 
        WHEN COUNT(e.student_id) >= c.max_students THEN 'Full'
        WHEN COUNT(e.student_id) >= c.max_students * 0.8 THEN 'Nearly Full'
        WHEN COUNT(e.student_id) >= c.max_students * 0.5 THEN 'Moderate'
        ELSE 'Low Demand'
    END AS demand_status,
    AVG(e.attendance_percentage) AS avg_attendance,
    (SELECT COUNT(*) 
     FROM Enrollment e2 
     WHERE e2.course_id = c.course_id 
       AND e2.grade IN ('A+', 'A', 'A-')) AS high_grades_count
FROM Course c
JOIN Department d ON c.dept_id = d.dept_id
LEFT JOIN Enrollment e ON c.course_id = e.course_id
GROUP BY c.course_id
ORDER BY current_enrollment DESC;

-- 12.3 Faculty workload analysis
SELECT 
    CONCAT(f.first_name, ' ', f.last_name) AS faculty_name,
    d.dept_name,
    f.specialization,
    COUNT(DISTINCT ca.course_id) AS courses_taught,
    COUNT(DISTINCT ca.semester) AS semesters_active,
    COUNT(DISTINCT e.student_id) AS total_students_taught,
    AVG(e.attendance_percentage) AS avg_student_attendance,
    SUM(c.credits * ca.role = 'Primary') AS total_credits_primary,
    SUM(c.credits * ca.role = 'Assistant') AS total_credits_assistant
FROM Faculty f
JOIN Department d ON f.dept_id = d.dept_id
LEFT JOIN CourseAssignment ca ON f.faculty_id = ca.faculty_id
LEFT JOIN Course c ON ca.course_id = c.course_id
LEFT JOIN Enrollment e ON c.course_id = e.course_id AND ca.semester = e.semester AND ca.year = e.year
GROUP BY f.faculty_id
ORDER BY total_students_taught DESC;

-- 12.4 Student success prediction (simplified)
SELECT 
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    s.cgpa,
    AVG(e.attendance_percentage) AS avg_attendance,
    COUNT(e.course_id) AS courses_enrolled,
    SUM(CASE WHEN e.grade IN ('D', 'F') THEN 1 ELSE 0 END) AS failing_courses,
    CASE 
        WHEN s.cgpa < 2.5 AND AVG(e.attendance_percentage) < 70 THEN 'High Risk'
        WHEN s.cgpa < 2.0 THEN 'Critical Risk'
        WHEN s.cgpa BETWEEN 2.5 AND 3.0 AND AVG(e.attendance_percentage) < 75 THEN 'Moderate Risk'
        WHEN s.cgpa > 3.5 AND AVG(e.attendance_percentage) > 85 THEN 'Low Risk - High Performer'
        ELSE 'Normal'
    END AS risk_level,
    CASE 
        WHEN s.cgpa < 2.0 OR AVG(e.attendance_percentage) < 60 THEN 'Immediate Intervention Required'
        WHEN s.cgpa < 2.5 OR AVG(e.attendance_percentage) < 70 THEN 'Schedule Academic Counseling'
        WHEN s.cgpa < 3.0 AND AVG(e.attendance_percentage) < 80 THEN 'Monitor Progress'
        ELSE 'On Track'
    END AS recommended_action
FROM Student s
LEFT JOIN Enrollment e ON s.student_id = e.student_id
WHERE s.status = 'Active'
GROUP BY s.student_id
ORDER BY risk_level, s.cgpa;

-- 12.5 Department performance dashboard
SELECT 
    d.dept_name,
    COUNT(DISTINCT s.student_id) AS total_students,
    COUNT(DISTINCT f.faculty_id) AS total_faculty,
    COUNT(DISTINCT c.course_id) AS total_courses,
    AVG(s.cgpa) AS avg_student_cgpa,
    SUM(CASE WHEN s.cgpa >= 3.5 THEN 1 ELSE 0 END) AS honors_students,
    SUM(CASE WHEN s.scholarship_amount > 0 THEN 1 ELSE 0 END) AS scholarship_students,
    AVG(f.salary) AS avg_faculty_salary,
    d.budget,
    d.budget / NULLIF(COUNT(DISTINCT s.student_id), 0) AS budget_per_student,
    (
        SELECT COUNT(*) 
        FROM Enrollment e 
        JOIN Course c2 ON e.course_id = c2.course_id 
        WHERE c2.dept_id = d.dept_id
    ) AS total_enrollments,
    ROUND(
        (SELECT AVG(attendance_percentage) 
         FROM Enrollment e 
         JOIN Course c2 ON e.course_id = c2.course_id 
         WHERE c2.dept_id = d.dept_id), 2
    ) AS avg_attendance
FROM Department d
LEFT JOIN Student s ON d.dept_id = s.dept_id
LEFT JOIN Faculty f ON d.dept_id = f.dept_id
LEFT JOIN Course c ON d.dept_id = c.dept_id
GROUP BY d.dept_id
ORDER BY avg_student_cgpa DESC;

