/*
Lecture 07: MYSQL DCL Commands and use cases 
Objective: Learn DCL Commands to build effective database with constraints 
Author : Chandan Chaudhari

DCL (Data Control Language) Commands covered:
- GRANT     : Assign privileges to users
- REVOKE    : Remove privileges from users
- DENY      : Explicitly deny permissions (SQL Server style - simulated in MySQL)
- CREATE USER : Create new database users
- ALTER USER  : Modify user properties
- DROP USER   : Remove users
- RENAME USER : Rename existing users
- SET PASSWORD : Change user password
- SHOW GRANTS  : Display user privileges

Security Concepts:
- Authentication Methods
- Privilege Types (Global, Database, Table, Column)
- Role-Based Access Control (RBAC)
- Proxy Users
- Connection Control
- Password Policies
- Auditing and Logging
*/

-- =====================================================
-- SECTION 0: PREREQUISITES AND SETUP
-- =====================================================

-- Connect as root or admin user first
-- mysql -u root -p

-- Create a practice database
CREATE DATABASE IF NOT EXISTS UniversityDB_Secure;
USE UniversityDB_Secure;

-- Create sample tables for privilege demonstration
CREATE TABLE IF NOT EXISTS Employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_name VARCHAR(100) NOT NULL,
    department VARCHAR(50),
    salary DECIMAL(10,2),
    hire_date DATE,
    email VARCHAR(100),
    phone VARCHAR(15),
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS Salaries (
    emp_id INT,
    salary_month DATE,
    amount DECIMAL(10,2),
    bonus DECIMAL(10,2),
    deductions DECIMAL(10,2),
    PRIMARY KEY (emp_id, salary_month),
    FOREIGN KEY (emp_id) REFERENCES Employees(emp_id)
);

CREATE TABLE IF NOT EXISTS PublicInfo (
    info_id INT PRIMARY KEY AUTO_INCREMENT,
    department VARCHAR(50),
    announcement TEXT,
    publish_date DATE
);

-- Insert sample data
INSERT INTO Employees (emp_name, department, salary, hire_date, email) VALUES
('John Smith', 'IT', 75000.00, '2020-01-15', 'john.smith@company.com'),
('Jane Doe', 'HR', 65000.00, '2019-03-20', 'jane.doe@company.com'),
('Bob Wilson', 'Finance', 85000.00, '2018-06-10', 'bob.wilson@company.com'),
('Alice Brown', 'IT', 72000.00, '2021-02-05', 'alice.brown@company.com'),
('Charlie Davis', 'Marketing', 58000.00, '2022-04-12', 'charlie.davis@company.com');

INSERT INTO PublicInfo (department, announcement, publish_date) VALUES
('All', 'Company picnic next Friday', CURDATE()),
('IT', 'New software training available', CURDATE()),
('HR', 'Benefits enrollment open until end of month', CURDATE());

-- =====================================================
-- SECTION 1: USER MANAGEMENT
-- =====================================================

-- 1.1 CREATE USER - Basic user creation
-- Create user with simple authentication
CREATE USER 'john_analyst'@'localhost' IDENTIFIED BY 'SecurePass123!';

-- Create user with password expiration
CREATE USER 'jane_hr'@'localhost' 
IDENTIFIED BY 'HRpass456!'
PASSWORD EXPIRE INTERVAL 30 DAY;

-- Create user with resource limits
CREATE USER 'bob_reports'@'localhost' 
IDENTIFIED BY 'Report789!'
WITH
    MAX_QUERIES_PER_HOUR 100
    MAX_UPDATES_PER_HOUR 50
    MAX_CONNECTIONS_PER_HOUR 20
    MAX_USER_CONNECTIONS 5;

-- Create user with account locking
CREATE USER 'temp_user'@'localhost' 
IDENTIFIED BY 'TempPass123!'
ACCOUNT LOCK;

-- Create user from any host (use with caution)
CREATE USER 'remote_user'@'%' IDENTIFIED BY 'RemotePass456!';

-- Create user with specific IP range
CREATE USER 'office_user'@'192.168.1.%' IDENTIFIED BY 'OfficePass789!';

-- Create user with SSL requirement
CREATE USER 'secure_user'@'localhost' 
IDENTIFIED BY 'SSLpass123!'
REQUIRE SSL;

-- Create user with X509 requirement
CREATE USER 'x509_user'@'localhost' 
IDENTIFIED BY 'X509pass456!'
REQUIRE X509;

-- Create multiple users in one statement (MySQL 8.0+)
CREATE USER IF NOT EXISTS
    'analyst1'@'localhost' IDENTIFIED BY 'Pass123!',
    'analyst2'@'localhost' IDENTIFIED BY 'Pass456!',
    'analyst3'@'localhost' IDENTIFIED BY 'Pass789!';

-- 1.2 View created users
SELECT User, Host, account_locked, password_expired 
FROM mysql.user 
WHERE User LIKE '%user%' OR User IN ('john_analyst', 'jane_hr', 'bob_reports');

-- 1.3 ALTER USER - Modify user properties
-- Change user password
ALTER USER 'john_analyst'@'localhost' IDENTIFIED BY 'NewSecurePass456!';

-- Expire password immediately
ALTER USER 'jane_hr'@'localhost' PASSWORD EXPIRE;

-- Change password expiration policy
ALTER USER 'bob_reports'@'localhost' 
PASSWORD EXPIRE INTERVAL 90 DAY;

-- Set password to never expire
ALTER USER 'john_analyst'@'localhost' 
PASSWORD EXPIRE NEVER;

-- Reset password to use default expiration policy
ALTER USER 'jane_hr'@'localhost' 
PASSWORD EXPIRE DEFAULT;

-- Lock user account
ALTER USER 'temp_user'@'localhost' ACCOUNT LOCK;

-- Unlock user account
ALTER USER 'temp_user'@'localhost' ACCOUNT UNLOCK;

-- Change resource limits
ALTER USER 'bob_reports'@'localhost' 
WITH
    MAX_QUERIES_PER_HOUR 200
    MAX_UPDATES_PER_HOUR 100;

-- Add SSL requirement to existing user
ALTER USER 'john_analyst'@'localhost' REQUIRE SSL;

-- Change authentication plugin (MySQL 8.0+)
ALTER USER 'john_analyst'@'localhost' 
IDENTIFIED WITH caching_sha2_password BY 'NewPass123!';

-- 1.4 RENAME USER
RENAME USER 'temp_user'@'localhost' TO 'permanent_user'@'localhost';

-- 1.5 DROP USER
-- Drop a single user
DROP USER 'temp_user'@'localhost';

-- Drop multiple users
DROP USER IF EXISTS
    'analyst1'@'localhost',
    'analyst2'@'localhost',
    'analyst3'@'localhost';

-- Drop user and revoke all privileges automatically
DROP USER 'remote_user'@'%';

-- =====================================================
-- SECTION 2: PASSWORD MANAGEMENT AND POLICIES
-- =====================================================

-- 2.1 SET PASSWORD commands
-- Set password for current user
SET PASSWORD = 'NewCurrentPass123!';

-- Set password for another user (requires appropriate privileges)
SET PASSWORD FOR 'john_analyst'@'localhost' = 'AnotherPass789!';

-- Using OLD_PASSWORD for legacy compatibility (not recommended)
-- SET PASSWORD FOR 'legacy_user'@'localhost' = OLD_PASSWORD('OldStylePass');

-- 2.2 Password expiration policies
-- Global password policy
SET GLOBAL default_password_lifetime = 180;  -- 6 months

-- Password history (prevent reuse)
SET GLOBAL password_history = 5;  -- Last 5 passwords can't be reused

-- Password reuse interval
SET GLOBAL password_reuse_interval = 365;  -- Days before password can be reused

-- Password strength validation (install plugin first)
-- INSTALL PLUGIN validate_password SONAME 'validate_password.so';
SET GLOBAL validate_password.policy = 'MEDIUM';  -- LOW, MEDIUM, STRONG
SET GLOBAL validate_password.length = 8;
SET GLOBAL validate_password.mixed_case_count = 1;
SET GLOBAL validate_password.number_count = 1;
SET GLOBAL validate_password.special_char_count = 1;

-- 2.3 Check password validation settings
SHOW VARIABLES LIKE 'validate_password%';

-- 2.4 Failed login tracking and temporary account locking
-- Create user with failed login tracking
CREATE USER 'monitor_user'@'localhost' 
IDENTIFIED BY 'Monitor123!'
FAILED_LOGIN_ATTEMPTS 3
PASSWORD_LOCK_TIME 2;  -- Lock for 2 days after 3 failures

-- Password lock time can be unbounded
ALTER USER 'monitor_user'@'localhost' 
PASSWORD_LOCK_TIME UNBOUNDED;

-- 2.5 Password expiration for all users
-- Force all users to change password on next login
ALTER USER 'john_analyst'@'localhost' PASSWORD EXPIRE;
ALTER USER 'jane_hr'@'localhost' PASSWORD EXPIRE;
ALTER USER 'bob_reports'@'localhost' PASSWORD EXPIRE;

-- =====================================================
-- SECTION 3: PRIVILEGE TYPES AND GRANT COMMANDS
-- =====================================================

-- 3.1 GLOBAL PRIVILEGES (affect all databases)
-- Grant all privileges globally (superuser)
GRANT ALL PRIVILEGES ON *.* TO 'admin_user'@'localhost' WITH GRANT OPTION;

-- Grant specific global privileges
GRANT SELECT, INSERT, UPDATE, DELETE ON *.* TO 'global_user'@'localhost';
GRANT CREATE, ALTER, DROP ON *.* TO 'schema_manager'@'localhost';
GRANT PROCESS, SUPER, RELOAD ON *.* TO 'server_admin'@'localhost';
GRANT SHUTDOWN ON *.* TO 'maintenance_user'@'localhost';
GRANT FILE ON *.* TO 'data_importer'@'localhost';  -- File access privilege

-- 3.2 DATABASE-LEVEL PRIVILEGES
-- Grant all privileges on specific database
GRANT ALL PRIVILEGES ON UniversityDB_Secure.* TO 'db_admin'@'localhost';

-- Grant specific privileges on database
GRANT SELECT, INSERT, UPDATE, DELETE 
ON UniversityDB_Secure.* 
TO 'app_user'@'localhost';

-- Grant only read access
GRANT SELECT ON UniversityDB_Secure.* TO 'readonly_user'@'localhost';

-- Grant create/modify structure but not data
GRANT CREATE, ALTER, DROP, INDEX 
ON UniversityDB_Secure.* 
TO 'schema_editor'@'localhost';

-- 3.3 TABLE-LEVEL PRIVILEGES
-- Grant on specific table
GRANT SELECT, INSERT, UPDATE 
ON UniversityDB_Secure.Employees 
TO 'hr_assistant'@'localhost';

-- Grant on multiple specific tables
GRANT SELECT ON UniversityDB_Secure.PublicInfo TO 'public_user'@'localhost';
GRANT SELECT ON UniversityDB_Secure.Employees TO 'report_viewer'@'localhost';

-- Grant different privileges on different tables
GRANT SELECT, INSERT, UPDATE ON UniversityDB_Secure.PublicInfo TO 'content_manager'@'localhost';
GRANT SELECT ON UniversityDB_Secure.Employees TO 'content_manager'@'localhost';

-- 3.4 COLUMN-LEVEL PRIVILEGES
-- Grant access only to specific columns
GRANT SELECT (emp_id, emp_name, department, email) 
ON UniversityDB_Secure.Employees 
TO 'hr_assistant'@'localhost';

-- Grant update only on specific columns
GRANT UPDATE (salary) 
ON UniversityDB_Secure.Employees 
TO 'payroll_manager'@'localhost';

-- Grant insert on specific columns
GRANT INSERT (emp_name, department, hire_date, email) 
ON UniversityDB_Secure.Employees 
TO 'recruiter'@'localhost';

-- 3.5 PROCEDURE/FUNCTION-LEVEL PRIVILEGES
-- Create a stored procedure for demonstration
DELIMITER //
CREATE PROCEDURE GetEmployeeCount()
BEGIN
    SELECT COUNT(*) as emp_count FROM Employees;
END //
CREATE PROCEDURE GetSalarySum(IN dept VARCHAR(50))
BEGIN
    SELECT SUM(salary) as total_salary 
    FROM Employees 
    WHERE department = dept;
END //
DELIMITER ;

-- Grant execute on specific procedure
GRANT EXECUTE ON PROCEDURE UniversityDB_Secure.GetEmployeeCount 
TO 'report_viewer'@'localhost';

-- Grant execute on all procedures in database
GRANT EXECUTE ON PROCEDURE UniversityDB_Secure.* 
TO 'analyst'@'localhost';

-- 3.6 GRANT WITH GRANT OPTION (allow user to grant privileges to others)
GRANT SELECT ON UniversityDB_Secure.* 
TO 'team_lead'@'localhost' 
WITH GRANT OPTION;

-- 3.7 GRANT PROXY (allow user to proxy as another user)
CREATE USER 'app_server'@'localhost' IDENTIFIED BY 'AppPass123!';
GRANT PROXY ON 'john_analyst'@'localhost' TO 'app_server'@'localhost';

-- 3.8 GRANT with role (MySQL 8.0+)
-- Create roles
CREATE ROLE 'read_only_role', 'data_entry_role', 'admin_role';

-- Grant privileges to roles
GRANT SELECT ON UniversityDB_Secure.* TO 'read_only_role';
GRANT SELECT, INSERT, UPDATE ON UniversityDB_Secure.* TO 'data_entry_role';
GRANT ALL PRIVILEGES ON UniversityDB_Secure.* TO 'admin_role';

-- Grant roles to users
GRANT 'read_only_role' TO 'john_analyst'@'localhost';
GRANT 'data_entry_role' TO 'jane_hr'@'localhost';
GRANT 'admin_role' TO 'bob_reports'@'localhost';

-- Set default role for users
SET DEFAULT ROLE 'read_only_role' TO 'john_analyst'@'localhost';
SET DEFAULT ROLE ALL TO 'jane_hr'@'localhost';

-- 3.9 Grant with specific requirements
-- Grant with SSL requirement
GRANT SELECT ON UniversityDB_Secure.Salaries 
TO 'secure_user'@'localhost' 
REQUIRE SSL;

-- Grant with CIPHER requirement
GRANT ALL PRIVILEGES ON *.* 
TO 'encrypted_user'@'localhost' 
REQUIRE CIPHER 'EDH-RSA-DES-CBC3-SHA';

-- 3.10 GRANT examples with different host specifications
-- Localhost only
GRANT SELECT ON UniversityDB_Secure.* TO 'local_user'@'localhost';

-- Specific IP
GRANT SELECT ON UniversityDB_Secure.* TO 'office_user'@'192.168.1.100';

-- IP range (using wildcard)
GRANT SELECT ON UniversityDB_Secure.* TO 'network_user'@'192.168.1.%';

-- Any host
GRANT SELECT ON UniversityDB_Secure.* TO 'anywhere_user'@'%';

-- Domain (MySQL resolves domain names)
-- GRANT SELECT ON *.* TO 'domain_user'@'%.company.com';

-- =====================================================
-- SECTION 4: REVOKE COMMANDS
-- =====================================================

-- 4.1 REVOKE global privileges
-- Revoke all global privileges
REVOKE ALL PRIVILEGES ON *.* FROM 'global_user'@'localhost';

-- Revoke specific global privileges
REVOKE CREATE, ALTER, DROP ON *.* FROM 'schema_manager'@'localhost';
REVOKE PROCESS, SUPER ON *.* FROM 'server_admin'@'localhost';

-- 4.2 REVOKE database-level privileges
-- Revoke all on database
REVOKE ALL PRIVILEGES ON UniversityDB_Secure.* FROM 'app_user'@'localhost';

-- Revoke specific database privileges
REVOKE INSERT, UPDATE, DELETE 
ON UniversityDB_Secure.* 
FROM 'readonly_user'@'localhost';

-- 4.3 REVOKE table-level privileges
-- Revoke on specific table
REVOKE INSERT, UPDATE 
ON UniversityDB_Secure.Employees 
FROM 'hr_assistant'@'localhost';

-- Revoke all on specific table
REVOKE ALL PRIVILEGES 
ON UniversityDB_Secure.Salaries 
FROM 'payroll_viewer'@'localhost';

-- 4.4 REVOKE column-level privileges
-- Revoke column-specific privileges
REVOKE UPDATE (salary) 
ON UniversityDB_Secure.Employees 
FROM 'payroll_manager'@'localhost';

REVOKE SELECT (emp_id, emp_name) 
ON UniversityDB_Secure.Employees 
FROM 'limited_user'@'localhost';

-- 4.5 REVOKE procedure privileges
REVOKE EXECUTE ON PROCEDURE UniversityDB_Secure.GetEmployeeCount 
FROM 'report_viewer'@'localhost';

-- 4.6 REVOKE GRANT OPTION
-- Revoke only the grant option, not the privilege itself
REVOKE GRANT OPTION 
ON UniversityDB_Secure.* 
FROM 'team_lead'@'localhost';

-- Revoke privilege and grant option together
REVOKE SELECT, GRANT OPTION 
ON UniversityDB_Secure.* 
FROM 'team_lead'@'localhost';

-- 4.7 REVOKE PROXY
REVOKE PROXY ON 'john_analyst'@'localhost' FROM 'app_server'@'localhost';

-- 4.8 REVOKE role (MySQL 8.0+)
REVOKE 'read_only_role' FROM 'john_analyst'@'localhost';
REVOKE 'data_entry_role' FROM 'jane_hr'@'localhost';

-- 4.9 REVOKE ALL (clean up)
-- Completely revoke all privileges from a user
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'temp_user'@'localhost';

-- 4.10 Revoke with IF EXISTS (MySQL 8.0+)
REVOKE IF EXISTS SELECT ON UniversityDB_Secure.* FROM 'unknown_user'@'localhost';

-- =====================================================
-- SECTION 5: SHOW GRANTS AND PRIVILEGE VERIFICATION
-- =====================================================

-- 5.1 SHOW GRANTS for current user
SHOW GRANTS;

-- 5.2 SHOW GRANTS for specific user
SHOW GRANTS FOR 'john_analyst'@'localhost';

-- 5.3 SHOW GRANTS with roles (MySQL 8.0+)
SHOW GRANTS FOR 'john_analyst'@'localhost' USING 'read_only_role';

-- 5.4 Check user's privileges from mysql database
-- View all user privileges
SELECT * FROM mysql.user WHERE User = 'john_analyst'\G

-- View database-level privileges
SELECT * FROM mysql.db WHERE User = 'john_analyst'\G

-- View table-level privileges
SELECT * FROM mysql.tables_priv WHERE User = 'john_analyst'\G

-- View column-level privileges
SELECT * FROM mysql.columns_priv WHERE User = 'john_analyst'\G

-- View procedure privileges
SELECT * FROM mysql.procs_priv WHERE User = 'john_analyst'\G

-- 5.5 Check current user and privileges
SELECT CURRENT_USER();
SELECT USER();

-- 5.6 Check user's roles (MySQL 8.0+)
SELECT CURRENT_ROLE();

-- 5.7 List all users
SELECT User, Host, account_locked, password_expired 
FROM mysql.user 
ORDER BY User;

-- 5.8 Check active connections
SHOW PROCESSLIST;
SELECT * FROM information_schema.PROCESSLIST;

-- =====================================================
-- SECTION 6: ROLE MANAGEMENT (MySQL 8.0+)
-- =====================================================

-- 6.1 CREATE ROLE
-- Create basic roles
CREATE ROLE 'app_read', 'app_write', 'app_developer';

-- Create role with host specification
CREATE ROLE 'role_admin'@'localhost';

-- Create multiple roles at once
CREATE ROLE IF NOT EXISTS
    'data_scientist',
    'data_engineer',
    'business_analyst';

-- 6.2 Grant privileges to roles
-- Grant read access to read role
GRANT SELECT ON UniversityDB_Secure.* TO 'app_read';

-- Grant write access to write role
GRANT INSERT, UPDATE, DELETE ON UniversityDB_Secure.* TO 'app_write';

-- Grant development privileges
GRANT CREATE, ALTER, DROP, INDEX ON UniversityDB_Secure.* TO 'app_developer';
GRANT SELECT, INSERT, UPDATE, DELETE ON UniversityDB_Secure.* TO 'app_developer';

-- Create hierarchical roles
CREATE ROLE 'all_access';
GRANT ALL PRIVILEGES ON UniversityDB_Secure.* TO 'all_access';

-- 6.3 Grant roles to users
-- Create users
CREATE USER 'reader1'@'localhost' IDENTIFIED BY 'Read123!';
CREATE USER 'writer1'@'localhost' IDENTIFIED BY 'Write456!';
CREATE USER 'dev1'@'localhost' IDENTIFIED BY 'Dev789!';

-- Grant roles
GRANT 'app_read' TO 'reader1'@'localhost';
GRANT 'app_write' TO 'writer1'@'localhost';
GRANT 'app_developer' TO 'dev1'@'localhost';

-- Grant multiple roles to a user
GRANT 'app_read', 'app_write' TO 'manager'@'localhost';

-- 6.4 Set default roles
-- User automatically gets these roles when connecting
SET DEFAULT ROLE 'app_read' TO 'reader1'@'localhost';
SET DEFAULT ROLE ALL TO 'dev1'@'localhost';  -- All granted roles are default
SET DEFAULT ROLE NONE TO 'writer1'@'localhost';  -- No default roles

-- 6.5 Activate roles in current session
-- Activate specific role
SET ROLE 'app_read';

-- Activate all granted roles
SET ROLE ALL;

-- Activate default roles
SET ROLE DEFAULT;

-- Deactivate all roles
SET ROLE NONE;

-- 6.6 Check role information
-- Show current active roles
SELECT CURRENT_ROLE();

-- Show roles granted to current user
SHOW GRANTS;

-- Show roles granted to specific user
SHOW GRANTS FOR 'reader1'@'localhost';

-- Show all existing roles
SELECT * FROM mysql.user WHERE is_role = 'Y';

-- 6.7 Role hierarchy
-- Create hierarchy (role can be granted to another role)
CREATE ROLE 'super_read';
GRANT SELECT ON *.* TO 'super_read';

CREATE ROLE 'department_read';
GRANT SELECT ON UniversityDB_Secure.* TO 'department_read';

-- Grant role to another role
GRANT 'department_read' TO 'super_read';

-- Now users with super_read get both sets of privileges

-- 6.8 Revoke roles
-- Revoke role from user
REVOKE 'app_read' FROM 'reader1'@'localhost';

-- Revoke role from another role
REVOKE 'department_read' FROM 'super_read';

-- 6.9 DROP ROLE
DROP ROLE 'app_read', 'app_write', 'app_developer';
DROP ROLE IF EXISTS 'temp_role';

-- =====================================================
-- SECTION 7: ADVANCED DCL CONCEPTS
-- =====================================================

-- 7.1 PROXY USERS
-- Create proxy user and target user
CREATE USER 'app_user'@'localhost' IDENTIFIED BY 'AppPass123!';
CREATE USER 'end_user'@'localhost' IDENTIFIED BY 'EndPass123!';

-- Grant proxy privilege
GRANT PROXY ON 'end_user'@'localhost' TO 'app_user'@'localhost';

-- Now app_user can connect and assume identity of end_user
-- Proxy user retains privileges of target user

-- Check proxy users
SELECT * FROM mysql.proxies_priv;

-- 7.2 ACTIVE DIRECTORY/LDAP Integration (MySQL Enterprise)
-- Example of LDAP user creation (MySQL Enterprise)
-- CREATE USER 'ldap_user'@'localhost' IDENTIFIED WITH authentication_ldap_simple AS 'cn=admin,dc=company,dc=com';

-- 7.3 CONNECTION CONTROL
-- Install connection control plugin
-- INSTALL PLUGIN CONNECTION_CONTROL SONAME 'connection_control.so';
-- INSTALL PLUGIN CONNECTION_CONTROL_FAILED_LOGIN_ATTEMPTS SONAME 'connection_control.so';

-- Set connection control variables
SET GLOBAL connection_control_failed_connections_threshold = 3;
SET GLOBAL connection_control_min_connection_delay = 1000;  -- milliseconds

-- 7.4 PASSWORD VERIFICATION POLICY
-- Create custom password validation function (simplified example)
DELIMITER //
CREATE FUNCTION validate_password_strength(password VARCHAR(255))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE is_strong BOOLEAN DEFAULT FALSE;
    IF LENGTH(password) >= 8 AND
       password REGEXP '[A-Z]' AND
       password REGEXP '[a-z]' AND
       password REGEXP '[0-9]' AND
       password REGEXP '[!@#$%^&*]' THEN
       SET is_strong = TRUE;
    END IF;
    RETURN is_strong;
END //
DELIMITER ;

-- 7.5 FINE-GRINED ACCESS CONTROL (using views)
-- Create views to restrict access to sensitive data
CREATE VIEW PublicEmployeeInfo AS
SELECT emp_id, emp_name, department, email
FROM Employees;

CREATE VIEW SalarySummary AS
SELECT department, AVG(salary) as avg_salary, COUNT(*) as emp_count
FROM Employees
GROUP BY department;

-- Grant access to views instead of base tables
GRANT SELECT ON UniversityDB_Secure.PublicEmployeeInfo TO 'public_user'@'localhost';
GRANT SELECT ON UniversityDB_Secure.SalarySummary TO 'manager'@'localhost';

-- 7.6 ROW-LEVEL SECURITY (using views with WHERE clauses)
-- Create department-specific views
CREATE VIEW ITEmployees AS
SELECT * FROM Employees WHERE department = 'IT';

CREATE VIEW HREmployees AS
SELECT * FROM Employees WHERE department = 'HR';

-- Grant access based on user's department
GRANT SELECT ON UniversityDB_Secure.ITEmployees TO 'it_manager'@'localhost';
GRANT SELECT ON UniversityDB_Secure.HREmployees TO 'hr_manager'@'localhost';

-- 7.7 TEMPORARY GRANTS (for specific time periods)
-- Grant access for a limited time (manual approach)
-- Schedule a job to revoke after specific time
-- Example: Grant for 1 day
GRANT SELECT ON UniversityDB_Secure.Salaries TO 'auditor'@'localhost';
-- Later, revoke using event scheduler or manual REVOKE

-- 7.8 APPLICATION-SPECIFIC USERS
-- Create user for web application with limited privileges
CREATE USER 'webapp'@'localhost' IDENTIFIED BY 'WebAppPass123!';
GRANT SELECT, INSERT, UPDATE ON UniversityDB_Secure.* TO 'webapp'@'localhost';
-- No DELETE, DROP, ALTER, etc.

-- Create user for batch jobs
CREATE USER 'batch_job'@'localhost' IDENTIFIED BY 'BatchPass123!';
GRANT SELECT, INSERT, UPDATE, DELETE ON UniversityDB_Secure.* TO 'batch_job'@'localhost';

-- Create user for reporting tool
CREATE USER 'report_tool'@'localhost' IDENTIFIED BY 'ReportPass123!';
GRANT SELECT ON UniversityDB_Secure.* TO 'report_tool'@'localhost';

-- =====================================================
-- SECTION 8: AUDITING AND MONITORING
-- =====================================================

-- 8.1 Enable general query log (for auditing)
SET GLOBAL general_log = 'ON';
SET GLOBAL log_output = 'TABLE';  -- Log to mysql.general_log table

-- View audit logs
SELECT * FROM mysql.general_log 
WHERE argument LIKE '%UniversityDB_Secure%'
ORDER BY event_time DESC
LIMIT 10;

-- 8.2 Enable slow query log (for performance monitoring)
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2;  -- Log queries taking > 2 seconds

-- 8.3 Create audit table for tracking privilege changes
CREATE TABLE IF NOT EXISTS PrivilegeAudit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action_user VARCHAR(100),
    action_type VARCHAR(50),
    target_user VARCHAR(100),
    target_host VARCHAR(100),
    privilege_details TEXT,
    ip_address VARCHAR(50)
);

-- Create trigger to log GRANT operations (conceptual - triggers can't capture DCL)
-- This would need to be handled at application level or via init-file

-- 8.4 Monitor user connections
-- Current connections
SHOW PROCESSLIST;

-- Connection history (if performance_schema enabled)
SELECT * FROM performance_schema.accounts 
WHERE USER IN ('john_analyst', 'jane_hr', 'bob_reports');

-- 8.5 Check privilege usage
-- Find users with super admin privileges
SELECT User, Host 
FROM mysql.user 
WHERE Super_priv = 'Y';

-- Find users with global privileges
SELECT User, Host, Select_priv, Insert_priv, Update_priv, Delete_priv
FROM mysql.user 
WHERE Select_priv = 'Y' OR Insert_priv = 'Y' OR Update_priv = 'Y' OR Delete_priv = 'Y';

-- Find users with access to specific database
SELECT * FROM mysql.db WHERE Db = 'UniversityDB_Secure';

-- 8.6 Track password changes (in general log)
SELECT * FROM mysql.general_log 
WHERE argument LIKE '%IDENTIFIED BY%' 
ORDER BY event_time DESC 
LIMIT 10;

-- =====================================================
-- SECTION 9: SECURITY BEST PRACTICES EXAMPLES
-- =====================================================

-- 9.1 Principle of Least Privilege - Create minimal privilege users

-- Read-only user for reporting
CREATE USER 'report_user'@'localhost' IDENTIFIED BY 'Report123!';
GRANT SELECT ON UniversityDB_Secure.PublicEmployeeInfo TO 'report_user'@'localhost';
GRANT SELECT ON UniversityDB_Secure.SalarySummary TO 'report_user'@'localhost';
-- No INSERT, UPDATE, DELETE privileges

-- Data entry user (can only insert/update, not delete)
CREATE USER 'data_entry'@'localhost' IDENTIFIED BY 'Entry123!';
GRANT SELECT, INSERT, UPDATE ON UniversityDB_Secure.PublicInfo TO 'data_entry'@'localhost';
GRANT SELECT, INSERT, UPDATE ON UniversityDB_Secure.Employees (emp_name, department, email) 
TO 'data_entry'@'localhost';
-- No DELETE, no access to salary columns

-- Manager user (can view all but modify only their department)
CREATE USER 'it_manager'@'localhost' IDENTIFIED BY 'ITMgr123!';
GRANT SELECT ON UniversityDB_Secure.* TO 'it_manager'@'localhost';
GRANT UPDATE ON UniversityDB_Secure.ITEmployees TO 'it_manager'@'localhost';
-- Can view everything but only update IT employees

-- App user with minimal privileges
CREATE USER 'app_user'@'localhost' IDENTIFIED BY 'App123!';
GRANT SELECT, INSERT, UPDATE ON UniversityDB_Secure.PublicInfo TO 'app_user'@'localhost';
GRANT SELECT ON UniversityDB_Secure.PublicEmployeeInfo TO 'app_user'@'localhost';
-- No direct table access, only through views

-- 9.2 Separate users by function
-- Backup user (needs SELECT and LOCK TABLES)
CREATE USER 'backup_user'@'localhost' IDENTIFIED BY 'Backup123!';
GRANT SELECT, LOCK TABLES ON UniversityDB_Secure.* TO 'backup_user'@'localhost';
GRANT FILE ON *.* TO 'backup_user'@'localhost';  -- For SELECT INTO OUTFILE

-- Maintenance user (can modify structure)
CREATE USER 'maintenance'@'localhost' IDENTIFIED BY 'Maint123!';
GRANT CREATE, ALTER, DROP, INDEX ON UniversityDB_Secure.* TO 'maintenance'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON UniversityDB_Secure.* TO 'maintenance'@'localhost';

-- 9.3 Application-specific users with connection limits
-- Web application user with strict limits
CREATE USER 'web_frontend'@'192.168.1.%' IDENTIFIED BY 'Web123!'
WITH
    MAX_QUERIES_PER_HOUR 10000
    MAX_CONNECTIONS_PER_HOUR 500
    MAX_USER_CONNECTIONS 10;

GRANT SELECT, INSERT, UPDATE ON UniversityDB_Secure.* TO 'web_frontend'@'192.168.1.%';

-- API user with different limits
CREATE USER 'api_service'@'%' IDENTIFIED BY 'API123!'
WITH
    MAX_QUERIES_PER_HOUR 5000
    MAX_UPDATES_PER_HOUR 2000;

GRANT SELECT ON UniversityDB_Secure.PublicEmployeeInfo TO 'api_service'@'%';

-- 9.4 Emergency access accounts (with auditing)
-- Create emergency DBA account with strong authentication
CREATE USER 'emergency_dba'@'localhost' 
IDENTIFIED BY 'EmergencyAccess123!VeryStrong'
PASSWORD EXPIRE INTERVAL 7 DAY
FAILED_LOGIN_ATTEMPTS 2
PASSWORD_LOCK_TIME 1;

GRANT ALL PRIVILEGES ON *.* TO 'emergency_dba'@'localhost' WITH GRANT OPTION;

-- This account should only be used in emergencies and audited heavily

-- 9.5 Secure default configuration
-- Remove anonymous users
DELETE FROM mysql.user WHERE User = '';

-- Remove test database
DROP DATABASE IF EXISTS test;

-- Set root password (if not already set)
-- ALTER USER 'root'@'localhost' IDENTIFIED BY 'VeryStrongRootPassword123!';

-- Disable remote root login
-- RENAME USER 'root'@'%' TO 'root'@'localhost';  -- If exists

-- 9.6 Regular privilege review queries
-- Find users with excessive privileges
SELECT 
    User, 
    Host,
    SUM(CASE WHEN Select_priv = 'Y' THEN 1 ELSE 0 END) as has_select,
    SUM(CASE WHEN Insert_priv = 'Y' THEN 1 ELSE 0 END) as has_insert,
    SUM(CASE WHEN Update_priv = 'Y' THEN 1 ELSE 0 END) as has_update,
    SUM(CASE WHEN Delete_priv = 'Y' THEN 1 ELSE 0 END) as has_delete,
    SUM(CASE WHEN Create_priv = 'Y' THEN 1 ELSE 0 END) as has_create,
    SUM(CASE WHEN Drop_priv = 'Y' THEN 1 ELSE 0 END) as has_drop,
    SUM(CASE WHEN Grant_priv = 'Y' THEN 1 ELSE 0 END) as has_grant
FROM mysql.user
GROUP BY User, Host
HAVING has_grant > 0 OR has_drop > 0 OR has_create > 0;

-- Find users who haven't changed password in 90 days
SELECT 
    User, 
    Host,
    password_last_changed,
    DATEDIFF(NOW(), password_last_changed) as days_since_change
FROM mysql.user
WHERE password_last_changed < DATE_SUB(NOW(), INTERVAL 90 DAY);

-- =====================================================
-- SECTION 10: TROUBLESHOOTING AND DIAGNOSTICS
-- =====================================================

-- 10.1 Check if user can connect
-- Test authentication (conceptual)
-- mysql -u username -p -h hostname

-- 10.2 Diagnose access denied errors
-- Check if user exists
SELECT User, Host FROM mysql.user WHERE User = 'john_analyst';

-- Check if host is correct
SELECT User, Host FROM mysql.user 
WHERE User = 'john_analyst' AND Host IN ('localhost', '%', '192.168.1.%');

-- Check account lock status
SELECT User, Host, account_locked FROM mysql.user WHERE User = 'john_analyst';

-- Check password expiration
SELECT User, Host, password_expired FROM mysql.user WHERE User = 'john_analyst';

-- 10.3 Diagnose privilege issues
-- What privileges does user have on specific database?
SELECT * FROM mysql.db 
WHERE User = 'john_analyst' AND Db = 'UniversityDB_Secure';

-- What table-level privileges?
SELECT * FROM mysql.tables_priv 
WHERE User = 'john_analyst' AND Db = 'UniversityDB_Secure';

-- 10.4 Check active roles
-- For the current session
SELECT CURRENT_ROLE();

-- For a user
SHOW GRANTS FOR 'reader1'@'localhost';

-- 10.5 Resolve common issues
-- Unlock locked account
ALTER USER 'john_analyst'@'localhost' ACCOUNT UNLOCK;

-- Reset expired password
ALTER USER 'john_analyst'@'localhost' IDENTIFIED BY 'NewPassword123!';

-- Grant missing privileges
GRANT SELECT ON UniversityDB_Secure.* TO 'john_analyst'@'localhost';

-- Flush privileges (if modified grant tables directly)
FLUSH PRIVILEGES;

-- =====================================================
-- SECTION 11: CLEANUP AND MAINTENANCE
-- =====================================================

-- 11.1 Remove test users (if needed)
DROP USER IF EXISTS 
    'john_analyst'@'localhost',
    'jane_hr'@'localhost',
    'bob_reports'@'localhost',
    'reader1'@'localhost',
    'writer1'@'localhost',
    'dev1'@'localhost',
    'app_user'@'localhost',
    'webapp'@'localhost',
    'batch_job'@'localhost',
    'report_tool'@'localhost',
    'backup_user'@'localhost',
    'maintenance'@'localhost',
    'emergency_dba'@'localhost';

-- 11.2 Drop roles
DROP ROLE IF EXISTS 
    'read_only_role',
    'data_entry_role',
    'admin_role',
    'app_read',
    'app_write',
    'app_developer',
    'super_read',
    'department_read';

-- 11.3 Drop test database (if needed)
DROP DATABASE IF EXISTS UniversityDB_Secure;

-- 11.4 Reset global settings (if changed)
SET GLOBAL default_password_lifetime = DEFAULT;
SET GLOBAL password_history = DEFAULT;
SET GLOBAL password_reuse_interval = DEFAULT;
SET GLOBAL general_log = 'OFF';
SET GLOBAL slow_query_log = 'OFF';

-- 11.5 Flush privileges after manual changes
FLUSH PRIVILEGES;
