--==============================================Triggers===============================================
-- t1 to ensure exams all degreees between course MinDegree & MaxDegree
-- between exam & course tables
-- handled also if instructor can delete exams
-- can handle multi rows

create trigger t1_ensureAllExamsDegreeInRange
on Exam
after insert, update, delete
as
begin
    
    declare @ChangedCourses table (cid int primary key)
    insert into @ChangedCourses(cid)
    --create var table for the affected courses
    --handle multi rows edit not only the last row 
    select cid from inserted
    union select cid from deleted
    
    declare @CourseInfo table(CourseID int primary key, TotalDegree int,
    Minimum int, Maximum int)
    insert into @CourseInfo
    select cc.cid, isnull(sum(e.TotalDegree),0), c.MinDegree, c.MaxDegree
    from course c join @ChangedCourses cc
    on c.cid=cc.cid
    left join exam e
    --left join if affected course has no exam (delete)
    on cc.cid=e.cid
    group by cc.cid, c.MinDegree, c.MaxDegree
    
    if exists (
    select 1 from @CourseInfo
    where TotalDegree not between Minimum and Maximum)
    begin
        raiserror ('Total exams degrees of the same course must be in the range of course Minimum degree and Maximum degree',10,1)
        rollback transaction   
    end
end

--t2 to ensure instructor can make exams for his courses only
-- between exam & instructor_course tables

create trigger t2_checkExamCreation
on exam
after insert
as
begin
    if exists (
        select 1 from inserted i
        where not exists (
            select 1 from instructor_course ic
            where i.iid = ic.iid and i.cid = ic.cid))
    begin
        raiserror('The instructor can make exams only for his courses. ',10,1)
        rollback transaction
    end
end


--t3 to ensure students answer exam in the allowed time only
-- between answer & exam tables

create trigger t3_checkAnswerTime
on answer
after insert
as
begin
    if exists (select 1 
        from inserted i join exam e
        on i.eid=e.eid and cast(GETDATE() as time) not between e.stime and e.etime)
    begin
        raiserror('The exam can be answered in the allowed time only. ',10,1)
        rollback transaction
    end
end

-- t4 to ensure exam end time > start time
-- on the exam table only
--found already done as check constraint, never fired
create trigger t4_checkExamEndTime
on exam
after insert
as
begin
    if exists (
        select 1 from inserted
        where stime > etime)
    begin
        raiserror('Error. The end time must be after the start',10,1)
        rollback transaction
    end
end

--t5 to ensure degree of question in each exam is positive
-- on the Exam_Question table
create trigger t5_checkExamQuestionSign
on Exam_Question
after insert
as
begin
    if exists (
        select 1 from inserted
        where QDegree<0)
    begin
        raiserror('Error. The degree must be positive',10,1)
        rollback transaction
    end
end

------testing triggers

----test trigger 1
----successful
--insert into exam(cid,iid,IntakeID, stime, etime, TotalDegree)
--values(3,3,1,'12:00:00', '13:00:00',100)
----Total exams degrees of the same course must be in the range of course Minimum degree and Maximum degree
----Msg 3609, Level 16, State 1, Line 109
----The transaction ended in the trigger. The batch has been aborted.

--delete from exam
--where eid=21
----Total exams degrees of the same course must be in the range of course Minimum degree and Maximum degree
----Msg 3609, Level 16, State 1, Line 116
----The transaction ended in the trigger. The batch has been aborted.

----test trigger 2, successful

--insert into exam(cid,iid,IntakeID, stime, etime)
--values(6,15,1,'12:00:00', '13:00:00')
----The instructor can make exams only for his courses. 
----Msg 3609, Level 16, State 1, Line 125
----The transaction ended in the trigger. The batch has been aborted.


----test trigger 3, successful
--insert into answer(eid,qid,sid, StudentAns)
--values(1,70,1, 'test')
----The exam can be answered in the allowed time only. 
----Msg 3609, Level 16, State 1, Line 134
----The transaction ended in the trigger. The batch has been aborted.


----test trigger 4, already constraint
--insert into exam(cid,iid,IntakeID, stime, etime)
--values(15,10,1,'12:00:00', '11:00:00')

----test trigger5, successful
--insert into Exam_Question(QID, EID, QDegree)
--values(70, 20, -5)
----Error. The degree must be positive
----Msg 3609, Level 16, State 1, Line 113
----The transaction ended in the trigger. The batch has been aborted.
