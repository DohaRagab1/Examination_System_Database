--===========================================Database Creation============================================
CREATE DATABASE iti_examination_system
USE iti_examination_system

--===========================================file group============================================
alter database iti_examination_system add filegroup FG1
go

alter database iti_examination_system add file
(NAME='FILEDB',
FILENAME='G:\data engineering\database\project\MY_FILE_IN_FG.ndf',
size=2MB,
MAXSIZE=200MB,
FILEGROWTH=4MB) TO FILEGROUP [FG1]


SELECT name
FROM sys.key_constraints
WHERE type = 'PK'
AND parent_object_id = OBJECT_ID('answer');

ALTER TABLE answer
DROP CONSTRAINT PK_Answer

ALTER TABLE Answer
ADD CONSTRAINT PK_Answer
PRIMARY KEY CLUSTERED (SID, EID, QID)
ON FG1;

--===========================================Tables Creation============================================
-- Department table
CREATE TABLE Department (
    DID INT IDENTITY(1,1) PRIMARY KEY,
    DName VARCHAR(20) NOT NULL
);

-- Track table

CREATE TABLE Track (
    TID INT IDENTITY(1,1) PRIMARY KEY,
    DID INT NOT NULL,
    TName VARCHAR(20) NOT NULL,
    FOREIGN KEY (DID) REFERENCES Department(DID)
);


-- Branch table
CREATE TABLE Branch (
    BID INT IDENTITY(1,1) PRIMARY KEY,
    BName VARCHAR(20) NOT NULL
);

-- Intake table
 
CREATE  TABLE Intake (
    IntakeID INT IDENTITY(1,1) PRIMARY KEY,
    inname varchar(20),
   
);
select * from intake

-- Course table
CREATE TABLE Course (
    CID INT IDENTITY(1,1) PRIMARY KEY,
    CName NVARCHAR(100) NOT NULL,
    MaxDegree INT,
    MinDegree INT,
    Description VARCHAR(30)
);
select * from course
-- Student table
CREATE TABLE Student (
    SID INT IDENTITY(1,1) PRIMARY KEY,
    SName VARCHAR(100) NOT NULL,
    SAddress NVARCHAR(255),
    SAge INT,
    SEmail NVARCHAR(100),
    SPhone BIGINT,
    IntakeID INT NOT NULL,
    CONSTRAINT FK_Student_Intake FOREIGN KEY (IntakeID) REFERENCES Intake(IntakeID),
    CONSTRAINT UQ_Student_Email UNIQUE (SEmail)
);
ALTER TABLE Student
ALTER COLUMN SPhone VARCHAR(11);
ALTER TABLE Student
ADD TID INT,
    BID INT;
    ALTER TABLE Student
ADD CONSTRAINT FK_Student_Track
FOREIGN KEY (TID)
REFERENCES Track(TID);

ALTER TABLE Student
ADD CONSTRAINT FK_Student_Branch
FOREIGN KEY (BID)
REFERENCES Branch(BID);
select * from student
ALTER TABLE Student
ADD CONSTRAINT CK_Student_Email_ContainsAt
CHECK (SEmail LIKE '%@%');
-- Instructor table
CREATE TABLE Instructor (
    IID INT IDENTITY(1,1) PRIMARY KEY,
    IName VARCHAR(100) NOT NULL,
    IAddress NVARCHAR(255),
    IEmail NVARCHAR(100) UNIQUE,
    ISalary INT NOT NULL CHECK (ISalary > 5000)
);

ALTER TABLE instructor
 add CONSTRAINT UQ_instructor_Email UNIQUE (iEmail)
ALTER TABLE instructor
add SPhone VARCHAR(11);
ALTER TABLE instructor
add sage int;

ALTER TABLE instructor
ADD CONSTRAINT CK_instructor_Email_ContainsAt
CHECK (iEmail LIKE '%@%');


-- Exam table
CREATE TABLE Exam (
    EID INT IDENTITY(1,1) PRIMARY KEY,
    CID INT NOT NULL,
    IID INT NOT NULL,
    IntakeID INT NOT NULL,
    ExamYear INT,
    Type VARCHAR(20),
    STime TIME NOT NULL,
    ETime TIME NOT NULL,
    TotalDegree INT,
    CONSTRAINT FK_Exam_Course FOREIGN KEY (CID) REFERENCES Course(CID),
    CONSTRAINT FK_Exam_Instructor FOREIGN KEY (IID) REFERENCES Instructor(IID),
    CONSTRAINT FK_Exam_Intake FOREIGN KEY (IntakeID) REFERENCES Intake(IntakeID),
    CONSTRAINT CHK_ExamTime CHECK (ETime > STime)
);
ALTER TABLE exam
ADD TID INT,
    BID INT;
     ALTER TABLE exam
ADD CONSTRAINT FK_exam_Track
FOREIGN KEY (TID)
REFERENCES Track(TID);

ALTER TABLE exam
ADD CONSTRAINT FK_exam_Branch
FOREIGN KEY (BID)
REFERENCES Branch(BID);
select * from exam
ALTER TABLE exam
ADD allowoptions varchar(50)
ALTER TABLE Exam
ADD TotalTimeMin AS DATEDIFF(MINUTE, STime, ETime);
ALTER TABLE Exam
ADD ExamDate DATE;


-- Question table
CREATE TABLE Question (
    QID INT IDENTITY(1,1) PRIMARY KEY,
    CID INT NOT NULL,
    QuestionText NVARCHAR(MAX) NOT NULL,
    CorrectAns VARCHAR(50) NOT NULL,
    Type CHAR(5) NOT NULL CHECK (Type IN ('MCQ','TF','text')),
    Choice1 VARCHAR(20),
    Choice2 VARCHAR(20),
    Choice3 VARCHAR(20),
    Choice4 VARCHAR(20),
    CONSTRAINT FK_Question_Course FOREIGN KEY (CID) REFERENCES Course(CID)

);
ALTER TABLE Question
ALTER COLUMN Choice1 NVARCHAR(100);

ALTER TABLE Question
ALTER COLUMN Choice2 NVARCHAR(100);

ALTER TABLE Question
ALTER COLUMN Choice3 NVARCHAR(100);

ALTER TABLE Question
ALTER COLUMN Choice4 NVARCHAR(100);
ALTER TABLE Question
ALTER COLUMN Choice1 NVARCHAR(100);

-- Answer table (ternary relationship)
CREATE TABLE Answer (
    EID INT NOT NULL,
    QID INT NOT NULL,
    SID INT NOT NULL,
    StudentAns VARCHAR(MAX),
    QGrade INT,
    CONSTRAINT PK_Answer PRIMARY KEY (SID, EID, QID),
    CONSTRAINT FK_Answer_Student FOREIGN KEY (SID) REFERENCES Student(SID),
    CONSTRAINT FK_Answer_Question FOREIGN KEY (QID) REFERENCES Question(QID),
    CONSTRAINT FK_Answer_Exam FOREIGN KEY (EID) REFERENCES Exam(EID)
);

-- Exam_Question table
CREATE TABLE Exam_Question (
    QID INT NOT NULL,
    EID INT NOT NULL,
    QDegree INT,
    CONSTRAINT PK_ExamQuestion PRIMARY KEY (EID, QID),
    CONSTRAINT FK_ExamQuestion_Question FOREIGN KEY (QID) REFERENCES Question(QID),
    CONSTRAINT FK_ExamQuestion_Exam FOREIGN KEY (EID) REFERENCES Exam(EID)
);

-- Student_Course table
CREATE TABLE Student_Course (
    SID INT NOT NULL,
    CID INT NOT NULL,
    Grade INT,
    PRIMARY KEY (SID, CID),
    FOREIGN KEY (SID) REFERENCES Student(SID),
    FOREIGN KEY (CID) REFERENCES Course(CID)
);

-- Instructor_Course table
CREATE TABLE Instructor_Course (
    CID INT NOT NULL,
    IID INT NOT NULL,
    Year INT,
    PRIMARY KEY (CID, IID),
    FOREIGN KEY (CID) REFERENCES Course(CID),
    FOREIGN KEY (IID) REFERENCES Instructor(IID)
);
SELECT name 
FROM sys.key_constraints 
WHERE parent_object_id = OBJECT_ID('Instructor_Course') 
  AND type = 'PK';

  aLTER TABLE Instructor_Course
DROP CONSTRAINT PK__Instruct__1DB1AEEDD7E4DF7F;
ALTER TABLE Instructor_Course
ALTER COLUMN Year INT NOT NULL;

ALTER TABLE Instructor_Course
ADD CONSTRAINT PK_Instructor_Course_Composite PRIMARY KEY (CID, IID, Year);
-- Branch_Track table
CREATE TABLE Branch_Track (
    BID INT NOT NULL,
    TID INT NOT NULL,
    PRIMARY KEY (BID, TID),
    FOREIGN KEY (BID) REFERENCES Branch(BID),
    FOREIGN KEY (TID) REFERENCES Track(TID)
);
drop TABLE Branch_Track

-- Track_Course table
CREATE TABLE Track_Course (
    CID INT NOT NULL,
    TID INT NOT NULL,
    PRIMARY KEY (CID, TID),
    FOREIGN KEY (CID) REFERENCES Course(CID),
    FOREIGN KEY (TID) REFERENCES Track(TID)
);
--student_exam
CREATE TABLE student_exam(
    SID INT ,
    EID INT ,
    ExamGrade int,
    PRIMARY KEY (sid,eid),
    FOREIGN KEY (sid) REFERENCES student(sid),
    FOREIGN KEY (eid) REFERENCES exam(eid)


    )

    ----- intake_branch_track table
CREATE TABLE Intake_Branch_Track (
    IntakeID INT NOT NULL,
    BID INT NOT NULL,
    TID INT NOT NULL,

    CONSTRAINT PK_IntakeBranchTrack 
        PRIMARY KEY (IntakeID, BID, TID),

    CONSTRAINT FK_IBT_Intake 
        FOREIGN KEY (IntakeID) 
        REFERENCES Intake(IntakeID),

    CONSTRAINT FK_IBT_Branch 
        FOREIGN KEY (BID) 
        REFERENCES Branch(BID),

    CONSTRAINT FK_IBT_Track 
        FOREIGN KEY (TID) 
        REFERENCES Track(TID)
);