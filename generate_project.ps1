$base = "c:\Users\ASUS\Downloads\Java Project"

# ============================================================
# db.properties
# ============================================================
@"
db.driver=com.mysql.cj.jdbc.Driver
db.url=jdbc:mysql://localhost:3306/training_institute?useSSL=false&serverTimezone=Asia/Kolkata&allowPublicKeyRetrieval=true
db.username=root
db.password=Nikhil_N@2130
db.name=training_institute
"@ | Set-Content "$base\src\main\resources\db.properties" -Encoding UTF8

# ============================================================
# schema.sql
# ============================================================
@"
CREATE DATABASE IF NOT EXISTS training_institute;
USE training_institute;

DROP TABLE IF EXISTS session_tracking;
DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS answers;
DROP TABLE IF EXISTS exam_attempts;
DROP TABLE IF EXISTS options;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS exams;
DROP TABLE IF EXISTS application_logs;
DROP TABLE IF EXISTS applications;
DROP TABLE IF EXISTS internships;
DROP TABLE IF EXISTS companies;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('ADMIN','STUDENT') NOT NULL,
    is_logged_in BOOLEAN DEFAULT FALSE,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT UNIQUE,
    course VARCHAR(100) NOT NULL,
    cgpa DECIMAL(3,2) CHECK (cgpa BETWEEN 0 AND 10),
    phone VARCHAR(15) UNIQUE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE companies (
    company_id INT PRIMARY KEY AUTO_INCREMENT,
    company_name VARCHAR(150) NOT NULL,
    location VARCHAR(100) NOT NULL,
    eligibility_cgpa DECIMAL(3,2) NOT NULL CHECK (eligibility_cgpa BETWEEN 0 AND 10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE internships (
    internship_id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    role VARCHAR(100) NOT NULL,
    stipend DECIMAL(10,2) CHECK (stipend >= 0),
    deadline DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(company_id) ON DELETE CASCADE
);

CREATE TABLE applications (
    application_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    internship_id INT NOT NULL,
    status ENUM('APPLIED','SHORTLISTED','REJECTED','SELECTED') DEFAULT 'APPLIED',
    applied_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(student_id, internship_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (internship_id) REFERENCES internships(internship_id) ON DELETE CASCADE
);

CREATE TABLE application_logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    application_id INT,
    action VARCHAR(100) NOT NULL,
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (application_id) REFERENCES applications(application_id) ON DELETE CASCADE
);

CREATE TABLE exams (
    exam_id INT PRIMARY KEY AUTO_INCREMENT,
    exam_name VARCHAR(150) NOT NULL,
    duration INT NOT NULL CHECK (duration > 0),
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    total_marks INT CHECK (total_marks > 0)
);

CREATE TABLE questions (
    question_id INT PRIMARY KEY AUTO_INCREMENT,
    exam_id INT NOT NULL,
    question_text TEXT NOT NULL,
    type ENUM('MCQ','SUBJECTIVE') NOT NULL,
    marks INT NOT NULL CHECK (marks > 0),
    FOREIGN KEY (exam_id) REFERENCES exams(exam_id) ON DELETE CASCADE
);

CREATE TABLE options (
    option_id INT PRIMARY KEY AUTO_INCREMENT,
    question_id INT NOT NULL,
    option_text VARCHAR(255) NOT NULL,
    is_correct BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (question_id) REFERENCES questions(question_id) ON DELETE CASCADE
);

CREATE TABLE exam_attempts (
    attempt_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    exam_id INT NOT NULL,
    start_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    end_time DATETIME,
    status ENUM('IN_PROGRESS','SUBMITTED','AUTO_SUBMITTED') DEFAULT 'IN_PROGRESS',
    UNIQUE(user_id, exam_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (exam_id) REFERENCES exams(exam_id) ON DELETE CASCADE
);

CREATE TABLE answers (
    answer_id INT PRIMARY KEY AUTO_INCREMENT,
    attempt_id INT NOT NULL,
    question_id INT NOT NULL,
    selected_option INT,
    descriptive_answer TEXT,
    marks_awarded DECIMAL(5,2) DEFAULT 0,
    UNIQUE(attempt_id, question_id),
    FOREIGN KEY (attempt_id) REFERENCES exam_attempts(attempt_id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions(question_id) ON DELETE CASCADE,
    FOREIGN KEY (selected_option) REFERENCES options(option_id) ON DELETE SET NULL
);

CREATE TABLE audit_logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    action VARCHAR(255) NOT NULL,
    ip_address VARCHAR(50),
    user_agent VARCHAR(255),
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
);

CREATE TABLE session_tracking (
    session_id VARCHAR(100) PRIMARY KEY,
    user_id INT UNIQUE,
    ip_address VARCHAR(50),
    user_agent VARCHAR(255),
    login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
"@ | Set-Content "$base\src\main\resources\schema.sql" -Encoding UTF8

# ============================================================
# seed.sql
# ============================================================
@"
USE training_institute;

-- Admin user (password: admin123)
INSERT INTO users (name, email, password, role) VALUES
('Admin User', 'admin@institute.com', 'admin123', 'ADMIN');

-- Student users (password: student123)
INSERT INTO users (name, email, password, role) VALUES
('Aarav Sharma', 'aarav@student.com', 'student123', 'STUDENT'),
('Priya Patel', 'priya@student.com', 'student123', 'STUDENT'),
('Rahul Verma', 'rahul@student.com', 'student123', 'STUDENT'),
('Sneha Iyer', 'sneha@student.com', 'student123', 'STUDENT'),
('Vikram Desai', 'vikram@student.com', 'student123', 'STUDENT');

-- Students
INSERT INTO students (user_id, course, cgpa, phone) VALUES
(2, 'B.Tech Computer Science', 8.50, '9876543210'),
(3, 'B.Tech Information Technology', 7.80, '9876543211'),
(4, 'B.Tech Electronics', 6.50, '9876543212'),
(5, 'M.Tech Data Science', 9.10, '9876543213'),
(6, 'B.Tech Mechanical', 5.90, '9876543214');

-- Companies
INSERT INTO companies (company_name, location, eligibility_cgpa) VALUES
('TechCorp Solutions', 'Bangalore', 7.00),
('DataMinds Analytics', 'Hyderabad', 8.00),
('CloudNine Systems', 'Pune', 6.50),
('InnovateTech Labs', 'Mumbai', 7.50),
('CyberShield Security', 'Chennai', 8.50);

-- Internships
INSERT INTO internships (company_id, role, stipend, deadline) VALUES
(1, 'Software Developer Intern', 25000.00, '2026-06-30'),
(1, 'Backend Engineer Intern', 30000.00, '2026-06-30'),
(2, 'Data Analyst Intern', 20000.00, '2026-05-31'),
(3, 'Cloud Engineer Intern', 22000.00, '2026-07-15'),
(4, 'Full Stack Developer Intern', 28000.00, '2026-06-15'),
(5, 'Security Analyst Intern', 35000.00, '2026-05-30');

-- Exam
INSERT INTO exams (exam_name, duration, start_time, end_time, total_marks) VALUES
('Certification Exam - Batch 2026', 60, '2026-05-01 09:00:00', '2026-07-31 18:00:00', 100);

-- MCQ Questions for Exam 1
INSERT INTO questions (exam_id, question_text, type, marks) VALUES
(1, 'What is the time complexity of binary search?', 'MCQ', 5),
(1, 'Which data structure uses FIFO?', 'MCQ', 5),
(1, 'What does SQL stand for?', 'MCQ', 5),
(1, 'Which protocol is used for secure web browsing?', 'MCQ', 5),
(1, 'What is the default port for HTTP?', 'MCQ', 5),
(1, 'Which OOP principle allows a class to inherit from another?', 'MCQ', 5),
(1, 'What is a primary key in a database?', 'MCQ', 5),
(1, 'Which sorting algorithm has the best average-case complexity?', 'MCQ', 5),
(1, 'What does API stand for?', 'MCQ', 5),
(1, 'Which layer of OSI model handles routing?', 'MCQ', 5);

-- Options for MCQ Questions
-- Q1: Binary Search
INSERT INTO options (question_id, option_text, is_correct) VALUES
(1, 'O(n)', FALSE), (1, 'O(log n)', TRUE), (1, 'O(n^2)', FALSE), (1, 'O(1)', FALSE);
-- Q2: FIFO
INSERT INTO options (question_id, option_text, is_correct) VALUES
(2, 'Stack', FALSE), (2, 'Queue', TRUE), (2, 'Tree', FALSE), (2, 'Graph', FALSE);
-- Q3: SQL
INSERT INTO options (question_id, option_text, is_correct) VALUES
(3, 'Structured Query Language', TRUE), (3, 'Simple Query Language', FALSE), (3, 'Standard Query Logic', FALSE), (3, 'Sequential Query Language', FALSE);
-- Q4: HTTPS
INSERT INTO options (question_id, option_text, is_correct) VALUES
(4, 'HTTP', FALSE), (4, 'FTP', FALSE), (4, 'HTTPS', TRUE), (4, 'SMTP', FALSE);
-- Q5: HTTP Port
INSERT INTO options (question_id, option_text, is_correct) VALUES
(5, '443', FALSE), (5, '8080', FALSE), (5, '80', TRUE), (5, '21', FALSE);
-- Q6: Inheritance
INSERT INTO options (question_id, option_text, is_correct) VALUES
(6, 'Encapsulation', FALSE), (6, 'Inheritance', TRUE), (6, 'Polymorphism', FALSE), (6, 'Abstraction', FALSE);
-- Q7: Primary Key
INSERT INTO options (question_id, option_text, is_correct) VALUES
(7, 'A foreign reference', FALSE), (7, 'A unique identifier for each record', TRUE), (7, 'A data type', FALSE), (7, 'An index', FALSE);
-- Q8: Sorting
INSERT INTO options (question_id, option_text, is_correct) VALUES
(8, 'Bubble Sort', FALSE), (8, 'Selection Sort', FALSE), (8, 'Merge Sort', TRUE), (8, 'Insertion Sort', FALSE);
-- Q9: API
INSERT INTO options (question_id, option_text, is_correct) VALUES
(9, 'Application Programming Interface', TRUE), (9, 'Advanced Program Integration', FALSE), (9, 'Application Process Integration', FALSE), (9, 'Automated Programming Interface', FALSE);
-- Q10: OSI Layer
INSERT INTO options (question_id, option_text, is_correct) VALUES
(10, 'Transport Layer', FALSE), (10, 'Network Layer', TRUE), (10, 'Data Link Layer', FALSE), (10, 'Session Layer', FALSE);

-- Subjective Questions
INSERT INTO questions (exam_id, question_text, type, marks) VALUES
(1, 'Explain the concept of normalization in databases. Describe the first three normal forms with examples.', 'SUBJECTIVE', 10),
(1, 'What is the difference between TCP and UDP? When would you use each?', 'SUBJECTIVE', 10),
(1, 'Describe the MVC architecture pattern and explain its advantages in web application development.', 'SUBJECTIVE', 10),
(1, 'Explain the concept of threading in Java. How do you handle thread safety?', 'SUBJECTIVE', 10),
(1, 'What are ACID properties in database transactions? Explain each with an example.', 'SUBJECTIVE', 10);
"@ | Set-Content "$base\src\main\resources\seed.sql" -Encoding UTF8

Write-Host "Phase 2 complete: db.properties, schema.sql, seed.sql"
