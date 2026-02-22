# Examination System Database

## Project Overview

The Examination System DataBase is a SQL server-based solution to manage exams, students, instructors, and courses within an education environment. It implements role-based access control and each role has specific permissions and tasks.

This system provides a secure and automated way to 

- Manage question pools and generate exams
- Manage courses, branches, tracks, and intakes
- Track student answers and results
- Control access using role-based access
- Automate database backup daily
- Ensure data integrity and performance optimization
- Users cannot access tables directly. All operations are performed through procedures and views.

This project was implemented using Microsoft SQL Server following database design and performance best practices.

## System Features

### Admin Features

- Full system control
- Manage accounts & permissions

### Training Manager Features

- Manage branches & departments
- Manage tracks and intakes
- Add and manage students

### Instructor Features

- Add and update questions in the question pool
- Create exams from question pool
- Select questions manually or randomly
- Review and assign grades for text questions
- Assign student for specific exam

### Student Features

- Takes exams during specific time only
- Submit answers and exams 
- View his results

## Technical Implementation

- SQL Server database files & filegroups
- Stored Procedures for all operations
- Views for reporting & data access
- Triggers & constraints for data integrity
- Indexes for performance
- SQL Server Agent Job for automatic backup

## Project Structure

```
Examination_System/
│
├── Data Files/
│   ├── branch_clean.csv
│   ├── coursenew.csv
│   ├── department.csv
│   ├── instructor.csv
│   ├── intakenew.csv
│   ├── newstudent.csv
│   └── track.csv
│
├── Docs/
│   ├── ERD.png
│   ├── Mapping.png
│   ├── Users.txt
│   ├── DB Objects.txt
│   ├── Procedures & Views Testing.txt
│   ├── Testing.xlsx
│   └── iti_examination_system.bak
│
└── Examination_System (ProjectCode)/
    ├── DB&TablesCreation.sql
    ├── DBScript.sql
    ├── DataInsertion.sql
    ├── Procedures&Views.sql
    ├── Triggers.sql
    ├── Indexes.sql
    ├── Roles.sql
    ├── Backup.sql
    ├── TextQuestion.sql
    ├── ITI_Examination_System.sqlproj
    └── ITI_Examination_System.sln
```

### Data Files

Contains CSV files used to feed system tables with initial data.

### Docs

Contains project documentation and testing materials:
- ERD.png → database entity relationship diagram
- Mapping.png → relational schema mapping
- Users.txt → system accounts & roles
- DB Objects.txt → description of database objects
- Procedures & Views Testing.txt → testing procedures & views
- Testing.xlsx → test cases and results
- iti_examination_system.bak → backup file for the whole database

### Examination_System (ProjectCode)

This folder contains core SQL Server project scripts.

## Authors 

- Doha Ragab Abd El-Hamid 
- Ibrahim Ahmed Mohammed 
- Omar Marwan Ahmed
