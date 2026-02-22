--=============================================Data Insertion==============================================
  BULK INSERT Branch
FROM 'G:\data engineering\database\project\Data Files\branch_clean.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);

select * from branch
-------
BULK INSERT department
FROM 'G:\data engineering\database\project\Data Files\department.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);
select * from department
---------
BULK INSERT track
FROM 'G:\data engineering\database\project\Data Files\track.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
    );
select * from track


----
DBCC CHECKIDENT ('exam', RESEED, 0);
DELETE FROM Exam;
DBCC CHECKIDENT ('exam', RESEED, 0);
-----
BULK INSERT intake
FROM 'G:\data engineering\database\project\Data Files\intakenew.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);
select * from intake


-----
BULK INSERT course
FROM 'G:\data engineering\database\project\Data Files\coursenew.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);
select * from course

------
BULK INSERT student
FROM 'G:\data engineering\database\project\Data Files\newstudent.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);
select * from student
------
 BULK INSERT instructor
FROM 'G:\data engineering\database\project\Data Files\instructor.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);
select * from Instructor

------

  INSERT INTO Exam (CID, IID, IntakeID, ExamYear, Type, STime, ETime, TotalDegree, BID, TID, allowoptions, ExamDate)
VALUES
(1, 1, 1, 2026, 'exam', '09:00', '11:00', 100, 3, 1, 'Open Book', '2026-06-01'),
(3, 3, 1, 2026, 'exam', '09:00', '11:00', 100, 3, 1, 'Closed Book', '2026-06-02'),
(4, 4, 1, 2026, 'exam', '09:00', '11:00', 100, 3, 1, 'Open Book', '2026-06-03'),
(5, 5, 1, 2026, 'exam', '09:00', '11:00', 100, 3, 1, 'Closed Book', '2026-06-04'),
(6, 6, 1, 2026, 'exam', '09:00', '11:00', 100, 3, 1, 'Open Book', '2026-06-05'),
(7, 7, 1, 2026, 'exam', '09:00', '11:00', 100, 3, 1, 'Closed Book', '2026-06-06'),
(8, 7, 1, 2026, 'exam', '09:00', '11:00', 100, 3, 1, 'Open Book', '2026-06-07'),
(2, 2, 2, 2026, 'exam', '12:00', '14:00', 100, 2, 2, 'Closed Book', '2026-06-08'),
(3, 3, 3, 2026, 'exam', '15:00', '15:30', 50, 1, 2, 'Open Book', '2026-06-09'),
(4, 5, 4, 2026, 'exam', '16:00', '18:00', 100, 5, 1, 'Closed Book', '2026-06-10'),
(5, 4, 5, 2026, 'exam', '08:00', '10:00', 50, 2, 1, 'Open Book', '2026-06-11'),
(6, 1, 3, 2026, 'exam', '10:30', '12:00', 50, 2, 2, 'Closed Book', '2026-06-12'),
(7, 1, 3, 2026, 'exam', '13:00', '14:00', 50, 1, 3, 'Open Book', '2026-06-13'),
(8, 12, 2, 2026, 'exam', '14:30', '15:30', 50, 3, 4, 'Closed Book', '2026-06-14'),
(9, 16, 4, 2026, 'Corrective', '09:00', '11:00', 100, 4, 4, 'Open Book', '2026-06-15'),
(10, 11, 1, 2026, 'Corrective', '12:00', '14:00', 100, 5, 4, 'Closed Book', '2026-06-16'),
(11, 12, 2, 2026, 'Corrective', '15:00', '15:30', 50, 2, 4, 'Open Book', '2026-06-17'),
(12, 13, 3, 2026, 'Corrective', '16:00', '18:00', 100, 4, 5, 'Closed Book', '2026-06-18'),
(13, 7, 6, 2026, 'Corrective', '08:00', '10:00', 50, 1, 6, 'Open Book', '2026-06-19'),
(14, 8, 5, 2026, 'Corrective', '10:30', '12:00', 50, 2, 6, 'Closed Book', '2026-06-20'),
(15, 10, 1, 2026, 'Corrective', '13:00', '14:00', 50, 1, 6, 'Open Book', '2026-06-21');

select * from exam

-----
INSERT INTO Question (CID, QuestionText, CorrectAns, Type, Choice1, Choice2, Choice3, Choice4)
VALUES
-- HTML (CID=1)
(1, N'What does HTML stand for?', 'HyperText Markup Language', 'MCQ', 'HyperText Markup Language', 'HighText Machine Language', 'Hyperloop Machine Language', 'HyperText Markdown Language'),
(1, N'HTML is a programming language?', 'False', 'TF', NULL, NULL, NULL, NULL),
(1, N'what is the capital of egypt', 'cairo', 'text', null, null, null, null),
(1, N'HTML supports CSS?', 'True', 'TF', NULL, NULL, NULL, NULL),
(1, N'Which tag creates a link?', 'a', 'MCQ', 'img', 'p', 'a', 'span'),
(1, N'HTML pages can include JavaScript?', 'True', 'TF', NULL, NULL, NULL, NULL),
(1, N'The <div> tag is a block-level element?', 'True', 'TF', NULL, NULL, NULL, NULL),
(1, N'Which tag is for headings?', 'h1', 'MCQ', 'h1', 'p', 'b', 'span'),

-- SQL (CID=8)
(8, N'SQL stands for Structured Query Language?', 'True', 'TF', NULL, NULL, NULL, NULL),
(8, N'Which SQL command deletes data?', 'DELETE', 'MCQ', 'UPDATE', 'DELETE', 'DROP', 'REMOVE'),
(8, N'Primary key can accept NULL?', 'False', 'TF', NULL, NULL, NULL, NULL),
(8, N'Which command creates a table?', 'CREATE TABLE', 'MCQ', 'CREATE TABLE', 'INSERT TABLE', 'UPDATE TABLE', 'ALTER TABLE'),
(8, N'SQL is case sensitive?', 'False', 'TF', NULL, NULL, NULL, NULL),
(8, N'JOIN combines rows from multiple tables?', 'True', 'TF', NULL, NULL, NULL, NULL),
(8, N'Which keyword is used to sort results?', 'ORDER BY', 'MCQ', 'ORDERBY', 'SORTBY', 'ORDER BY', 'SORT'),
(8, N'SQL supports transactions?', 'True', 'TF', NULL, NULL, NULL, NULL),

-- Python (CID=9)
(9, N'Python is dynamically typed?', 'True', 'TF', NULL, NULL, NULL, NULL),
(9, N'Which symbol is used for comments in Python?', '#', 'MCQ', '/', '#', '//', '/* */'),
(9, N'Python supports object-oriented programming?', 'True', 'TF', NULL, NULL, NULL, NULL),
(9, N'Python lists are mutable?', 'True', 'TF', NULL, NULL, NULL, NULL),
(9, N'Which function prints output?', 'print()', 'MCQ', 'print()', 'echo()', 'console.log()', 'printf()'),
(9, N'Python uses indentation for blocks?', 'True', 'TF', NULL, NULL, NULL, NULL),
(9, N'Python tuples are mutable?', 'False', 'TF', NULL, NULL, NULL, NULL),
(9, N'Which keyword defines a function?', 'def', 'MCQ', 'function', 'fun', 'def', 'define'),

-- DataWarehouse (CID=10)
(10, N'Data warehouse is used for OLAP?', 'True', 'TF', NULL, NULL, NULL, NULL),
(10, N'Fact tables store transactional data?', 'Yes', 'MCQ', 'Yes', 'No', 'Sometimes', 'Depends'),
(10, N'Snowflake schema is normalized?', 'True', 'TF', NULL, NULL, NULL, NULL),
(10, N'Dimension tables are usually large?', 'False', 'TF', NULL, NULL, NULL, NULL),
(10, N'ETL is Extract, Transform, Load?', 'True', 'TF', NULL, NULL, NULL, NULL),
(10, N'Which tool is used for DW reporting?', 'PowerBI', 'MCQ', 'Python', 'PowerBI', 'Java', 'Excel'),
(10, N'Data warehouses are updated frequently?', 'False', 'TF', NULL, NULL, NULL, NULL),
(10, N'OLAP is analytical processing?', 'True', 'TF', NULL, NULL, NULL, NULL),

-- NetworkSecurity (CID=13)
(13, N'Firewall is used to block unauthorized access?', 'True', 'TF', NULL, NULL, NULL, NULL),
(13, N'Which is a symmetric encryption algorithm?', 'AES', 'MCQ', 'RSA', 'DSA', 'ECC', 'AES'),
(13, N'SSL encrypts communication over networks?', 'True', 'TF', NULL, NULL, NULL, NULL),
(13, N'VPN provides secure remote access?', 'True', 'TF', NULL, NULL, NULL, NULL),
(13, N'Which protocol is used for secure web?', 'HTTPS', 'MCQ', 'HTTPS', 'HTTP', 'FTP', 'SSH'),
(13, N'Network attacks can be passive?', 'True', 'TF', NULL, NULL, NULL, NULL),
(13, N'Intrusion Detection Systems detect breaches?', 'True', 'TF', NULL, NULL, NULL, NULL),
(13, N'MAC addresses can be spoofed?', 'True', 'TF', NULL, NULL, NULL, NULL);

INSERT INTO Question (CID, QuestionText, CorrectAns, Type, Choice1, Choice2, Choice3, Choice4)
VALUES

-- ================= JAVA CORE (CID=3) =================
(3, N'Java is platform independent?', 'True', 'TF', NULL, NULL, NULL, NULL),
(3, N'Which keyword is used to inherit a class?', 'extends', 'MCQ', 'implement', 'extends', 'inherits', 'instanceof'),
(3, N'JVM stands for?', 'Java Virtual Machine', 'MCQ', 'Java Variable Method', 'Java Virtual Machine', 'Joint Virtual Machine', 'Java Verified Machine'),
(3, N'Java supports multiple inheritance with classes?', 'False', 'TF', NULL, NULL, NULL, NULL),
(3, N'which language is primarly used for android development?', 'java', 'text', null, null, null, null),
(3, N'Which method is entry point of Java program?', 'main', 'MCQ', 'start', 'run', 'main', 'init'),

-- ================= SPRING BOOT (CID=4) =================
(4, N'Spring Boot is built on Spring Framework?', 'True', 'TF', NULL, NULL, NULL, NULL),
(4, N'Which annotation is used to start Spring Boot application?', '@SpringBootApplication', 'MCQ', '@EnableBoot', '@SpringBootApplication', '@StartApp', '@Configuration'),
(4, N'Spring Boot uses embedded servers?', 'True', 'TF', NULL, NULL, NULL, NULL),
(4, N'Which server is default in Spring Boot?', 'Tomcat', 'MCQ', 'Jetty', 'GlassFish', 'Tomcat', 'JBoss'),
(4, N'Which annotation is used for REST controller?', '@RestController', 'MCQ', '@Controller', '@RestController', '@Component', '@Service'),
(4, N'Spring Boot simplifies dependency management?', 'True', 'TF', NULL, NULL, NULL, NULL),

-- ================= REACT (CID=5) =================
(5, N'React is developed by Facebook?', 'True', 'TF', NULL, NULL, NULL, NULL),
(5, N'Which hook is used for state management?', 'useState', 'MCQ', 'useEffect', 'useState', 'useRef', 'useContext'),
(5, N'React uses virtual DOM?', 'True', 'TF', NULL, NULL, NULL, NULL),
(5, N'JSX stands for?', 'JavaScript XML', 'MCQ', 'Java Syntax Extension', 'JavaScript XML', 'JSON XML', 'Java Extended'),
(5, N'Props are immutable?', 'True', 'TF', NULL, NULL, NULL, NULL),
(5, N'Which command creates React app?', 'create-react-app', 'MCQ', 'npm react-start', 'create-react-app', 'react-init', 'npm create-react'),

-- ================= NODE JS (CID=6) =================
(6, N'Node.js is built on Chrome V8 engine?', 'True', 'TF', NULL, NULL, NULL, NULL),
(6, N'Which module is used to create server?', 'http', 'MCQ', 'fs', 'http', 'url', 'path'),
(6, N'Node.js is single-threaded?', 'True', 'TF', NULL, NULL, NULL, NULL),
(6, N'NPM stands for?', 'Node Package Manager', 'MCQ', 'New Project Manager', 'Node Package Manager', 'Network Package Manager', 'Node Program Method'),
(6, N'Which keyword is used to export module?', 'module.exports', 'MCQ', 'export', 'require', 'module.exports', 'include'),
(6, N'Node.js can interact with databases?', 'True', 'TF', NULL, NULL, NULL, NULL),

-- ================= MERN (CID=7) =================
(7, N'MERN stands for MongoDB, Express, React, Node?', 'True', 'TF', NULL, NULL, NULL, NULL),
(7, N'Which database is used in MERN stack?', 'MongoDB', 'MCQ', 'MySQL', 'Oracle', 'MongoDB', 'PostgreSQL'),
(7, N'Express is backend framework?', 'True', 'TF', NULL, NULL, NULL, NULL),
(7, N'React is used for frontend?', 'True', 'TF', NULL, NULL, NULL, NULL),
(7, N'MongoDB is relational database?', 'False', 'TF', NULL, NULL, NULL, NULL),
(7, N'Node.js handles server-side logic?', 'True', 'TF', NULL, NULL, NULL, NULL),

-- ================= SQL (CID=8) =================
(8, N'SQL stands for Structured Query Language?', 'True', 'TF', NULL, NULL, NULL, NULL),
(8, N'Which command is used to retrieve data?', 'SELECT', 'MCQ', 'INSERT', 'UPDATE', 'DELETE', 'SELECT'),
(8, N'Primary Key must be unique?', 'True', 'TF', NULL, NULL, NULL, NULL),
(8, N'Which clause is used to filter records?', 'WHERE', 'MCQ', 'ORDER BY', 'GROUP BY', 'WHERE', 'HAVING'),
(8, N'JOIN is used to combine tables?', 'True', 'TF', NULL, NULL, NULL, NULL),
(8, N'Which command removes table?', 'DROP', 'MCQ', 'DELETE', 'REMOVE', 'DROP', 'CLEAR');


select* from question

-----
INSERT INTO Track_Course (CID, TID) VALUES
(1, 1), -- HTML/CSS
(3, 1), -- JavaScript
(4, 1), -- Java Core
(5, 1), -- Spring Boot
(6, 1), -- React
(7, 1), -- Node.js
(8, 1), -- MERN Project
--
(1, 3), -- HTML/CSS
(3, 3), -- JavaScript
(6, 3), -- React
(7, 3), -- MERN Project
--
(8, 4), -- SQL
(9, 4), -- Python
(10, 4), -- Data Warehousing
(11, 4), -- ETL
--

(10, 5), -- Data Warehousing
(11, 5), -- ETL
(12, 5), -- Power BI Dashboard

--

(4, 2), -- Java Core
(5, 2), -- Spring Boot

-- CyberSec Associate (6)

(8, 6), -- SQL
(13, 6), -- Network Security
(14, 6), -- Ethical Hacking
(15, 6); -- Cybersecurity Basics
select * from Track_Course


------
INSERT INTO intake_branch_track (IntakeID, BID, TID) VALUES
(1, 1, 3),
(2, 2, 1),
(3, 3, 5),
(4, 4, 2),
(5, 5, 6),
(6, 1, 4),
(7, 2, 3),
(8, 3, 2),
(1, 4, 1),
(2, 5, 5),
(3, 1, 6),
(4, 2, 4),
(5, 3, 3),
(6, 4, 2),
(7, 5, 1),
(8, 1, 5),
(1, 2, 6),
(2, 3, 4),
(3, 4, 1),
(4, 5, 2),
(5, 1, 3),
(6, 2, 5),
(7, 3, 6),
(8, 4, 4),
(1, 5, 2),
(2, 1, 1),
(3, 2, 6),
(4, 3, 3),
(5, 4, 5),
(6, 5, 2),
(7, 1, 4),
(8, 2, 3),
(1, 3, 5),
(2, 4, 1),
(3, 5, 6),
(4, 1, 2),
(5, 2, 4),
(6, 3, 3),
(7, 4, 5),
(8, 5, 1);
select * from intake_branch_track 
---
insert into student_exam(sid,eid,examgrade)
values
(1,1,60),
(1,2,80),
(1,3,40),
(1,4,60),
(1,5,20),
(1,6,80),
(1,7,100),
(2,3,30),
(4,11,20),
(3,7,50);

select * from student_exam

----
insert into Instructor_Course(cid,iid,year)
values
(1,1,2026),
(2,2,2026),
(3,3,2026),
(4,4,2026),
(5,5,2026),
(6,6,2026),
(7,7,2026),
(8,8,2026),
(9,9,2026),
(10,10,2026),
(11,11,2026),
(12,12,2026),
(13,13,2026),
(14,14,2026),
(15,15,2026),
(1,16,2025),
(2,17,2025),
(3,18,2025),
(4,19,2025),
(5,20,2025)
select * from Instructor_Course
----
insert into student_Course(sid,cid,grade)
values
(1,1,60),
(1,3,80),
(1,4,40),
(1,5,60),
(1,6,20),
(1,7,80),
(1,8,100),
(2,4,60),
(2,5,20),
(3,1,95),
(3,3,20),
(3,6,70),
(3,7,65),
(4,8,50),
(4,9,30),
(4,10,60),
(4,11,70)

select * from student_Course
----
insert into Exam_Question(qid,eid,qdegree)
values
(1,1,20),
(2,1,20),
(3,1,20),
(4,1,20),
(5,1,20),
(41,2,20),
(42,2,20),
(43,2,20),
(44,2,20),
(45,2,20),
(47,3,20),
(48,3,20),
(49,3,20),
(50,3,20),
(51,3,20),
(53,4,20),
(54,4,20),
(55,4,20),
(56,4,20),
(57,4,20),
(59,5,20),
(60,5,20),
(61,5,20),
(62,5,20),
(63,5,20),
(65,6,20),
(66,6,20),
(67,6,20),
(68,6,20),
(69,6,20),
(71,7,20),
(72,7,20),
(73,7,20),
(74,7,20),
(75,7,20),
(1,8,20),--
(2,8,20),
(3,8,20),
(4,8,20),
(5,8,20);
select * from Exam_Question

---

select * from answer
insert into answer(eid,qid,sid,studentans,qgrade)
values
(1,1,1,'HyperText Markup Language',20),
(1,2,1,'false',20),
(1,3,1,'cairo',20),
(1,4,1,'false',0), --mistake
(1,5,1,'span',0),--mis

(2,41,1,'true',20),
(2,42,1,'extends',20),
(2,43,1,'java virtual machine',20),
(2,44,1,'false',20),
(2,45,1,'kotlin',0),

(3,47,1,'true',20),
(3,48,1,'@SpringBootApplication',20),
(3,49,1,'false',0),
(3,50,1,'jetty',0),
(3,51,1,'@Controller',0),

(4,53,1,'true',20),
(4,54,1,'useState',20),
(4,55,1,'true',20),
(4,56,1,'Java Syntax Extension',0),
(4,57,1,'false',0),

(5,59,1,'true',20),
(5,60,1,'fs',0),
(5,61,1,'false',0),
(5,62,1,'new project manager',0),
(5,63,1,'export',0),

(6,65,1,'true',20),
(6,66,1,'MongoDB',20),
(6,67,1,'true',20),
(6,68,1,'true',20),
(6,69,1,'true',0),

(7,71,1,'true',20),
(7,72,1,'SELECT',20),
(7,73,1,'true',20),
(7,74,1,'WHERE',20),
(7,75,1,'true',20)
