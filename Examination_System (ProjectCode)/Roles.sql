--==============================================Roles===============================================
-- 4 different roles
--student, instructor, training manager, admin
--login ==> user ==> role
--login with server, user with database, and role for permissioins

--never deal with tables directly except for admin
--specify procedures, functions & views to each role

--login, on server level
create login AdminLogin with password = 'admin123'
create login TrainingMgrLogin with password = 'mgr123'
create login Instructor1Login with password = 'inst123'
create login Instructor2Login with password = 'inst23'
create login Student1Login with password = 'stud123'
create login Student2Login with password = 'stud23'
create login Student3Login with password = 'stud3'


--users, related to database
use iti_examination_system

create user Admin1 for login AdminLogin

create user TrainingMgr1 for login TrainingMgrLogin

create user Instructor1 for login Instructor1Login
create user Instructor2 for login Instructor2Login

create user Student1 for login Student1Login
create user Student2 for login Student2Login
create user Student3 for login Student3Login

--create 4 roles
create role AdminRole
create role TrainingMgrRole
create role InstructorRole
create role StudentRole

--assign users to roles
alter role AdminRole add member Admin1

alter role TrainingMgrRole add member TrainingMgr1

alter role InstructorRole add member Instructor1
alter role InstructorRole add member Instructor2

alter role StudentRole add member Student1
alter role StudentRole add member Student2
alter role StudentRole add member Student3

--Any control of permissions will be with roles not the users
--Can't deny access to tables as views rely on them

--full control for the admin role
grant control to AdminRole

--assign procedures & functions to different roles
--StudentRole
grant execute 
on usp_Student_SubmitAnswer to StudentRole
grant execute 
on usp_Student_SubmitExam to StudentRole

--InstructorRole
grant execute 
on usp_Exam_Create to InstructorRole
grant execute 
on usp_Exam_Add_Question_Manual to InstructorRole
grant execute 
on usp_Exam_GenerateQuestions_Random to InstructorRole
grant execute 
on usp_Question_Add to InstructorRole
grant execute 
on usp_Question_Update to InstructorRole
grant execute 
on usp_Exam_AssignStudent to InstructorRole
grant execute 
on usp_RecalcStudentCourseGrade_LatestExam to InstructorRole
grant execute 
on usp_RecalcCourseGrades_LatestExam to InstructorRole
grant execute 
on InsAssignTextGrades to InstructorRole

--TrainingMgrRole
grant execute 
on addBranch to TrainingMgrRole
grant execute 
on editBranch to TrainingMgrRole
grant execute 
on addIntake to TrainingMgrRole
grant execute 
on editIntake to TrainingMgrRole
grant execute 
on addTrack to TrainingMgrRole
grant execute 
on editTrack to TrainingMgrRole
grant execute 
on add_student to TrainingMgrRole


--assign views to different roles
grant select
on vw_Exam_Header to StudentRole, InstructorRole
grant select
on vw_ExamQuestions to StudentRole, InstructorRole
grant select
on vw_StudentExamResult to StudentRole, InstructorRole, TrainingMgrRole
grant select
on vw_StudentCourseFinalResult to StudentRole, InstructorRole, TrainingMgrRole
grant select
on vw_StudentExamAnswer to InstructorRole
grant select
on ReviewTextQuestions to InstructorRole
grant select
on vw_QuestionPool to InstructorRole

grant select
on vw_allStudents to TrainingMgrRole
grant select
on vw_allCourses to TrainingMgrRole
grant select
on vw_allInstructors to TrainingMgrRole
grant select
on vw_allQuestions to TrainingMgrRole
grant select
on vw_allExams to TrainingMgrRole
