--==============================================Indexes===============================================
-- by default all tables have clustered index on their primary keys
-- if the table has a composite primary key, the clustered index is done based on their combinations
-- keeping the rule that only one clustered index per table

-- For high performance, we made non clustered indices on the columns much quered or joined
use iti_examination_system

create nonclustered index in1_exam_course
on exam(cid)

create nonclustered index in2_exam_instructor
on exam(iid)

create nonclustered index in3_question_course
on question(cid)

create nonclustered index in4_student_branch
on student(bid)

create nonclustered index in5_student_track
on student(tid)

create nonclustered index in6_student_intake
on student(IntakeID)
