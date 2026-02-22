/*===========================================================
1) Functions
===========================================================*/
-- 1.1) fn_CalcAutoGrade: MCQ/TF auto grade; TEXT => NULL
Create or alter function fn_CalcAutoGrade
	(@EID int, @QID int, @StudentAnswer Varchar(100))
returns int
as
begin
	----declare variables
	Declare @QType Char(5), @Correct Varchar(100), @Deg int
	---Assign Variables
	select @QType =q.Type, @Correct =q.CorrectAns
	from Question q where q.QID=@QID

	select @Deg =EQ.QDegree
	from Exam_Question EQ where EQ.EID =@EID and EQ.QID= @QID
	--- Logic loop
	--1- QUestion not found or not attrached to exam
	if @QType is null or @Deg is null
		Return null;
	if LOWER(TRIM(@QType)) ='text'
		return null;
	return case when @StudentAnswer= @Correct then isnull(@deg,0) else 0 end;
end
-----------------------------------------------------------------------
-- 1.2) fn_ExamTotalDegree: Sum degrees in Exam_Question
create or alter function fn_ExamTotalDegree 
	(@EID int)
returns int
as
begin
	Declare @total int
	select @total = sum(isnull(QDegree,0))
	from Exam_Question where EID = @EID

	return isnull(@total,0);
end

/*===========================================================
2) Procedures
===========================================================*/
-- 2.1) usp_Exam_Create
create or alter proc usp_Exam_Create
	@CID int, @IID int, @intakeID int, @ExamDate date=null, @STime time(7), @ETime time(7),
	@type varchar(20)=null,@TID int=null,@BID int=null, @allowoptions varchar (50)=null, @NewEID int output
as
begin
	set nocount on
	-- first check the inserted time
	if @STime is null or @ETime is null or @ETime <=@Stime
		Throw 50001, 'Invalid Exam time Window (Etime must be > STime)',1;
	-- Second check the instructor is assgined
	if not exists(select 1 from Instructor_Course IC where IC.IID = @IID and IC.CID=@CID)
		Throw 50002, 'Instructor is not assigned to this course',1;
	-- Check Course, intake, Track, and branch ared existed
	if not exists(select 1 from Course c where c.CID= @CID)
		Throw 50003, 'Course doesnt exist',1;
	if not exists(select 1 from Intake i where i.IntakeID=@intakeID)
		Throw 50004, 'Intake is not existed',1;
	if @TID is not null and not exists(select 1 from Track T where t.TID =@TID)
		Throw 50005, 'Track is not existed',1;
	if @BID is not null and not exists(select 1 from Branch b where b.BID=@BID)
		Throw 50006, 'Branch not existed',1;
	--insert with trans to apply atmicity 'All or Not'
	begin try
		begin tran
			insert into Exam 
			(CID,IID,IntakeID,ExamDate,Type,STime,ETime,TotalDegree,TID,BID,allowoptions)
			Values
			(@CID,@IID,@intakeID,@ExamDate,@type,@STime,@ETime,0,@TID,@BID,@allowoptions)
			set @NewEID = convert(int,SCOPE_IDENTITY());
		commit
	end try
	begin catch
		if @@TRANCOUNT > 0 rollback;
		Throw
	End Catch
End
-----------------------------------------------------------------------
-- 2.2) usp_Exam_Question_Manual (manual add/update question degree)
Create or alter proc usp_Exam_Add_Question_Manual
	@EID int, @QID int, @QDegree int
as
begin
	set nocount on
	--Logics Check
	if @QDegree is null or @QDegree <= 0
		throw 51001, 'QDegree must be > 0',1;
	-- Check exam, question exist and question match with course of this exam
	if not exists (select 1 from Exam E join Question q on e.CID = q.CID
					where e.EID =@EID and q.QID =@QID) 
		Throw 51002, 'exam not found or question not found or this q doesnt belong to this course',1;
	--- Course max degree
	Declare @CourseMax int
	select @CourseMax = c.MaxDegree from Exam e join Course c on c.CID =e.CID
	where e.EID=@EID

	if @CourseMax is null
		throw 51003, 'Course max degree is not set',1;
	---old degree for this question in this course
	Declare @OldDeg int
	select @OldDeg =EQ.QDegree from Exam_Question EQ where eq.EID=@EID and EQ.QID =@QID;
	--- total degrees for this exam
	Declare @CurrentTotal int = dbo.fn_ExamTotalDegree(@EID)
	Declare @NewTotal int =@CurrentTotal - isnull(@olddeg,0) + @Qdegree;
	if @NewTotal >@CourseMax
		throw 51004, 'Total exam degree will exceed Course.MaxDegree',1;

	begin try
		begin tran
			update Exam_Question
			set QDegree =@QDegree where EID=@EID and QID =@QID;
			
			if @@ROWCOUNT =0 
				insert into Exam_Question (EID,QID,QDegree)
				Values (@EID,@QID,@QDegree)
			update exam
				set TotalDegree = dbo.fn_ExamTotalDegree(@EID)
				where EID =@EID
		commit
	end try
	begin catch
	if @@TRANCOUNT >0 rollback;
		throw;
	End Catch
End
-----------------------------------------------------------------------
-- 2.3) usp_Exam_GenerateQuestions_Random 
create or alter proc usp_Exam_GenerateQuestions_Random
	@EID int, @MCQ_Count int=0,@TF_Count int =0, @Text_Count int=0, @DefaultQDegree int =1
as
begin
	set nocount on;
	if @MCQ_Count < 0 or @Text_Count <0 or @TF_Count <0 
		throw 52001, 'counts must be >= 0 ',1;
	if @DefaultQDegree is null or @DefaultQDegree <=0
		throw 52002, 'Default degree must be >0',1
	if not exists (select 1 from Exam e where e.EID =@EID)
		throw 52003, 'Exam Not Found',1

	Declare @CID int, @CourseMax int
	select @CID =e.CID, @CourseMax =c.MaxDegree
	from Exam e join Course c on c.CID=e.CID where e.EID =@EID

	if @CourseMax is null
		throw 52004, 'Course Max Degree is not set', 1;

	Declare @CurrentTotal int = dbo.fn_ExamTotalDegree(@EID)
	if @CurrentTotal +(@MCQ_Count+@Text_Count+@TF_Count)*@DefaultQDegree >@CourseMax
		throw 52005, 'Would Exceed Course.MaxDegree',1
	
	if @MCQ_Count >(select count(*) from Question q where q.CID = @CID and LOWER(TRIM(type)) ='mcq'
					and not exists (select 1 from Exam_Question eq where eq.EID =@EID and eq.QID =q.QID)
					)
		or @TF_Count >(select count(*) from Question q where q.CID = @CID and LOWER(TRIM(type)) ='TF'
					and not exists (select 1 from Exam_Question eq where eq.EID =@EID and eq.QID =q.QID)
					)
		or @Text_Count >(select count(*) from Question q where q.CID = @CID and LOWER(TRIM(type)) ='text'
					and not exists (select 1 from Exam_Question eq where eq.EID =@EID and eq.QID =q.QID)
					)
			Throw 52006, 'Not enogh Questions Available',1;
	begin try
	begin tran
		insert into  Exam_Question (EID,QID,QDegree)
		select @EID,x.QID,@DefaultQDegree
		from(
			select top (@MCQ_Count) q.qid from Question q where q.CID =@CID and lower(trim(q.type)) ='mcq'
			and not exists (select 1 from Exam_Question EQ where eq.EID=@EID and eq.QID =q.QID
			)
			order by NEWID()
			union all
			select top (@tf_Count) q.qid from Question q where q.CID =@CID and lower(trim(q.type)) ='tf'
			and not exists (select 1 from Exam_Question EQ where eq.EID=@EID and eq.QID =q.QID
			)
			order by newid()
			union all
			select top (@Text_Count) q.qid from Question q where q.CID =@CID and lower(trim(q.type)) ='text'
			and not exists (select 1 from Exam_Question EQ where eq.EID=@EID and eq.QID =q.QID
			)
			order by NEWID()
			)as x;

			update exam 
			set TotalDegree = dbo.fn_ExamTotalDegree(@EID)
			where EID =@EID
		commit
	end try
	begin catch
		if @@TRANCOUNT >0 rollback;
			throw;
	end catch
end;
-----------------------------------------------------------------------
-- 2.4) usp_RecalcTotalDegree
create or alter proc usp_RecalcTotalDegree
	@EID int
as
begin
	set nocount on
	
	if not exists (select 1 from Exam where EID =@EID)
		throw 53001, 'Exam Not Found',1
	update exam
	set TotalDegree = dbo.fn_ExamTotalDegree(@EID)
	Where EID = @EID
end
-----------------------------------------------------------------------
-- 2.5) usp_Exam_AssignStudent
CREATE OR ALTER PROCEDURE dbo.usp_Exam_AssignStudent
    @EID INT, @SID INT
AS
BEGIN
    SET NOCOUNT ON;
	 -- 1) Validate Exam
    IF NOT EXISTS (SELECT 1 FROM dbo.Exam WHERE EID = @EID)
        THROW 60001, 'Exam not found.', 1;
    -- 2) Validate Student
    IF NOT EXISTS (SELECT 1 FROM dbo.Student WHERE SID = @SID)
        THROW 60002, 'Student not found.', 1;
    -- 3) Check if already assigned
    IF EXISTS (SELECT 1 FROM dbo.student_exam WHERE EID=@EID AND SID=@SID)
        THROW 60003, 'Student already assigned to this exam.', 1;

    BEGIN TRY
        BEGIN TRAN;

            -- Insert assignment (ExamGrade NULL initially)
            INSERT INTO dbo.student_exam (SID, EID, ExamGrade)
            VALUES (@SID, @EID, NULL);

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END
-----------------------------------------------------------------------
-- 2.6) usp_Student_SubmitAnswer (upsert answer + autograde for MCQ/TF +Time window Valid)
create or alter proc usp_Student_SubmitAnswer
	@EID int, @SID int , @QID int, @StudentAnswer varchar (max)
as
begin
	set nocount on

	if not exists (select 1 from student where SID= @SID)
		Throw 54001,'Student not found',1;
	if not exists (select 1 from Exam where EID=@EID)
		Throw 54002,'Exam not found',1;
	if not exists (select 1 from Exam_Question where EID=@EID and QID= @QID)
		Throw 54003,'Qusetion is not part of this exam',1;
	IF NOT EXISTS ( SELECT 1 FROM dbo.student_exam WHERE SID = @SID AND EID = @EID)
		THROW 60010, 'Student is not allowed to take this exam.', 1;
	DECLARE @ExamDate DATE,@STime TIME(7),@ETime TIME(7);
	SELECT @ExamDate = ExamDate,@STime = STime, @ETime = ETime FROM dbo.Exam WHERE EID = @EID;
	IF @ExamDate IS NULL
		THROW 60011, 'Exam date is not defined.', 1;
	
	DECLARE @Now DATETIME = GETDATE();
	DECLARE @StartDateTime DATETIME =
    CAST(@ExamDate AS DATETIME) + CAST(@STime AS DATETIME);
	
	DECLARE @EndDateTime DATETIME =
    CAST(@ExamDate AS DATETIME) + CAST(@ETime AS DATETIME);
	
	IF @Now < @StartDateTime OR @Now > @EndDateTime
		THROW 60012, 'Exam is not available at this time.', 1;
	Declare @AutoGrade int = dbo.fn_CalcAutoGrade(@EID,@QID,@StudentAnswer)

	begin try
		begin tran
			if exists(select 1 from Answer where SID=@SID and EID=@EID and QID =@QID)
			begin
				update Answer
				set StudentAns =@StudentAnswer, QGrade =@AutoGrade
				where sid=@SID and EID=@EID and QID =@QID
			end
			else
			begin
				insert into Answer (SID, EID,QID,StudentAns,QGrade)
				Values(@SID,@EID,@QID,@StudentAnswer,@AutoGrade);
			end
		commit;
	end try
	begin catch
		if @@TRANCOUNT >0 rollback;
		throw;
	end catch
end

-----------------------------------------------------------------------
-- 2.7) usp_Auto_Grade_Exam
create or alter proc usp_Auto_Grade_Exam
	@SID int, @EID int
as
begin
	set nocount on;

	if not exists (select 1 from student where SID=@SID)
		throw 55001, 'Student not found',1;
	if not exists (select 1 from exam where EID=@EID)
		throw  55002,'Exam Not found',1;
	begin try
		begin tran
			update a set a.QGrade = dbo.fn_CalcAutoGrade(a.EID,a.QID,a.StudentAns)
			from answer a join Question q on q.QID =a.QID
			where a.SID =@SID and a.EID=@EID
			and lower(trim(q.Type)) in ('mcq','tf')
		commit
	end try
	begin catch
	 if @@TRANCOUNT >0 rollback;
	 throw;
	end Catch
end
-----------------------------------------------------------------------
-- 2.8) usp_RecalcStudentExamSnapshot
create or alter proc usp_RecalcStudentExamSnapshot
 @SID int, @EID int 
 as
 begin
 set nocount on
	if not exists (select 1 from Student where SID =@SID)
		throw 56001, 'Student not found',1
	if not exists (select 1 from Exam where EID=@EID)
		throw 56002, 'Exam not found',1
	Declare @Total int
	select @Total = sum(isnull(QGrade,0))
	from Answer where SID =@SID and EID =@EID

	set @Total = ISNULL(@Total,0)

	begin try
		begin tran
			if exists (select 1 from student_exam where SID=@SID and EID=@EID)
			begin
				update student_exam
				set ExamGrade = @Total
				where SID =@SID and EID = @EID
			end
			else
			begin
				insert into student_exam (SID, EID, ExamGrade)
				Values (@SID, @EID, @Total)
			end
		commit
	end try
	begin catch
		if @@TRANCOUNT >0 rollback;
		Throw;
	end catch
end
-----------------------------------------------------------------------
-- 2.9) usp_Student_SubmitExam
create or alter proc usp_Student_SubmitExam
	@SID int, @EID int, @RequireAllAnswers bit =1
as
begin
	set nocount on;

	if not exists (select 1 from Student where SID =@SID)
		throw 56001, 'Student not found',1
	if not exists (select 1 from Exam where EID=@EID)
		throw 56002, 'Exam not found',1
	
	if @RequireAllAnswers =1
	begin
		declare @TotalQs int, @AnsweredQs int
		select @TotalQs = count(*)
		from Exam_Question where EID=@EID

		select @AnsweredQs = COUNT(*)
		from Answer where SID = @SID and EID=@EID

		if ISNULL(@TotalQs,0) =0
			throw 57001, 'Exam has no Questions',1
		if isnull (@AnsweredQs,0) < @TotalQs
			throw 57002, 'Not all question are answered',1
	end
	DECLARE @ExamDate DATE,@STime TIME(7),@ETime TIME(7);
	SELECT @ExamDate = ExamDate,@STime = STime, @ETime = ETime FROM dbo.Exam WHERE EID = @EID;
	IF @ExamDate IS NULL
		THROW 60011, 'Exam date is not defined.', 1;
	
	DECLARE @Now DATETIME = GETDATE();
	DECLARE @StartDateTime DATETIME =
    CAST(@ExamDate AS DATETIME) + CAST(@STime AS DATETIME);
	
	DECLARE @EndDateTime DATETIME =
    CAST(@ExamDate AS DATETIME) + CAST(@ETime AS DATETIME);
	
	IF @Now < @StartDateTime OR @Now > @EndDateTime
		THROW 60012, 'Exam is not available at this time.', 1;
	begin try
		begin tran
			Exec dbo.usp_Auto_Grade_Exam @SID=@SID, @EID=@EID
			Exec dbo.usp_RecalcStudentExamSnapshot @SID=@SID, @EID=@EID
		commit
	end try
	begin catch
		if @@TRANCOUNT > 0 Rollback;
			throw;
	end catch
end

-----------------------------------------------------------------------
-- 2.10) usp_Question_Add
create or alter proc usp_Question_Add
	@CID int, @type char(5), @QuestionText NVarchar(max),@CorrectAnswer Varchar(100) = null,
	@Choice1 NVarchar (100)= null,@Choice2 NVarchar (100)= null,@Choice3 NVarchar (100)= null,
	@Choice4 NVarchar (100)= null, @NewQID int Output
as
begin
	set nocount on;
	
	if not exists(select 1 from Course where CID=@CID)
		throw 50011, 'Course not found',1
	if @QuestionText is null or trim(@QuestionText) = ''
		throw 50012, 'Question Text is Required', 1;
	
	declare @t Varchar (50)= lower(trim(convert(Varchar(10), @type)));
	if @t not in ('mcq','tf','text')
		throw 50013, 'Invalid question type. Allowed MCQ,TF,Text',1;

	if @t = 'mcq'
	begin
		if @Choice1 is null or @Choice2 is null or @Choice3 is null or @Choice4 is null
			throw 50014, 'MCQ requires 4 choices',1;
		if @CorrectAnswer is null or trim(@CorrectAnswer)=''
			throw 50015, 'MCQ requires Correct Answer',1;
		if convert(nvarchar(100),@CorrectAnswer) not in (@Choice1,@Choice2, @Choice3, @Choice4)
			throw 50016, 'MCQ Correct Ans must match one of the provided Choices',1;
	end
	else if @t= 'tf'
	begin
		if @CorrectAnswer is null or upper(trim(@CorrectAnswer)) not in ('T','F')
			throw 50017, 'Correct Answer must be T or F',1;
		set @Choice1=null; set @Choice2=null; set @Choice3=null; set @Choice4=null;
		set @CorrectAnswer=upper(trim(@CorrectAnswer))
	end
	else
	begin
		set @Choice1=null; set @Choice2=null; set @Choice3=null; set @Choice4=null;
		set @CorrectAnswer=''
	end
	begin try
		begin tran
			insert into Question (CID,QuestionText,CorrectAns,[Type],Choice1,Choice2,Choice3,Choice4)
			Values(@CID,@QuestionText,@CorrectAnswer,@type,@Choice1,@Choice2,@Choice3,@Choice4);
			set @NewQID = CONVERT(int,SCOPE_IDENTITY());
		commit
	end try
	begin catch
	if @@TRANCOUNT >0 rollback;
		throw;
	end catch
end
-----------------------------------------------------------------------
-- 2.11) usp_Question_Update
create or alter proc usp_Question_Update
	@QID int,@CID int, @type char(5), @QuestionText NVarchar(max),@CorrectAnswer Varchar(100) = null,
	@Choice1 NVarchar (100)= null,@Choice2 NVarchar (100)= null,@Choice3 NVarchar (100)= null,
	@Choice4 NVarchar (100)= null
as
begin
	set nocount on;

	if not exists(select 1 from question where QID=@QID)
		throw 50020, 'Question Not Found',1
	if not exists(select 1 from Course where CID=@CID)
		throw 50011, 'Course not found',1
	if @QuestionText is null or trim(@QuestionText) = ''
		throw 50012, 'Question Text is Required', 1;
	
	declare @t Varchar (50)= lower(trim(convert(Varchar(10), @type)));
	if @t not in ('mcq','tf','text')
		throw 50013, 'Invalid question type. Allowed MCQ,TF,Text',1;

	if @t = 'mcq'
	begin
		if @Choice1 is null or @Choice2 is null or @Choice3 is null or @Choice4 is null
			throw 50014, 'MCQ requires 4 choices',1;
		if @CorrectAnswer is null or trim(@CorrectAnswer)=''
			throw 50015, 'MCQ requires Correct Answer',1;
		if convert(nvarchar(100),@CorrectAnswer) not in (@Choice1,@Choice2, @Choice3, @Choice4)
			throw 50016, 'MCQ Correct Ans must match one of the provided Choices',1;
	end
	else if @t= 'tf'
	begin
		if @CorrectAnswer is null or upper(trim(@CorrectAnswer)) not in ('T','F')
			throw 50017, 'Correct Answer must be T or F',1;
		set @Choice1=null; set @Choice2=null; set @Choice3=null; set @Choice4=null;
		set @CorrectAnswer=upper(trim(@CorrectAnswer))
	end
	else
	begin
		set @Choice1=null; set @Choice2=null; set @Choice3=null; set @Choice4=null;
		set @CorrectAnswer=''
	end
	begin try
		begin Tran
			update Question
			set CID=@CID, [Type]=@type, QuestionText=@QuestionText,CorrectAns=@CorrectAnswer,
			Choice1=@Choice1, Choice2=@Choice2,Choice3=@Choice3,Choice4=@Choice4
			where QID=@QID
			if @@ROWCOUNT =0 
				throw 50021, 'Question not updated',1;
		commit
	end try
	begin catch
		if @@TRANCOUNT >0 rollback;
		throw;
	end catch
end
-----------------------------------------------------------------------
-- 2.12) usp_RecalcStudentCourseGrade_LatestExam

CREATE OR ALTER PROCEDURE dbo.usp_RecalcStudentCourseGrade_LatestExam
  @SID INT,
  @CID INT
AS
BEGIN
  SET NOCOUNT ON;

  IF NOT EXISTS (SELECT 1 FROM dbo.Student WHERE SID=@SID)
    THROW 62001, 'Student not found.', 1;

  IF NOT EXISTS (SELECT 1 FROM dbo.Course WHERE CID=@CID)
    THROW 62002, 'Course not found.', 1;

  DECLARE @LatestGrade INT;

  SELECT @LatestGrade =
  (
      SELECT TOP (1) se.ExamGrade
      FROM dbo.student_exam se
      JOIN dbo.Exam e ON e.EID = se.EID
      WHERE se.SID = @SID
        AND e.CID = @CID
        AND se.ExamGrade IS NOT NULL
      ORDER BY e.ExamDate DESC, e.STime DESC
  );

  SET @LatestGrade = ISNULL(@LatestGrade, 0);

  BEGIN TRY
    BEGIN TRAN;

      IF EXISTS (SELECT 1 FROM dbo.Student_Course WHERE SID=@SID AND CID=@CID)
        UPDATE dbo.Student_Course
          SET Grade = @LatestGrade
        WHERE SID=@SID AND CID=@CID;
      ELSE
        INSERT INTO dbo.Student_Course(SID,CID,Grade)
        VALUES(@SID,@CID,@LatestGrade);

    COMMIT;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    THROW;
  END CATCH
END
-----------------------------------------------------------------------
-- 2.13) usp_RecalcCourseGrades_LatestExam

CREATE OR ALTER PROCEDURE dbo.usp_RecalcCourseGrades_LatestExam
  @CID INT
AS
BEGIN
  SET NOCOUNT ON;

  IF NOT EXISTS (SELECT 1 FROM dbo.Course WHERE CID=@CID)
    THROW 62101, 'Course not found.', 1;

  BEGIN TRY
    BEGIN TRAN;

    UPDATE sc
    SET sc.Grade =
        ISNULL(
            (
                SELECT TOP (1) se.ExamGrade
                FROM dbo.student_exam se
                JOIN dbo.Exam e ON e.EID = se.EID
                WHERE se.SID = sc.SID
                  AND e.CID = sc.CID
                  AND se.ExamGrade IS NOT NULL
                ORDER BY e.ExamDate DESC, e.STime DESC
            ),
            0
        )
    FROM dbo.Student_Course sc
    WHERE sc.CID = @CID;

    INSERT INTO dbo.Student_Course (SID, CID, Grade)
    SELECT DISTINCT
        se.SID,
        e.CID,
        ISNULL(
            (
                SELECT TOP (1) se2.ExamGrade
                FROM dbo.student_exam se2
                JOIN dbo.Exam e2 ON e2.EID = se2.EID
                WHERE se2.SID = se.SID
                  AND e2.CID = e.CID
                  AND se2.ExamGrade IS NOT NULL
                ORDER BY e2.ExamDate DESC, e2.STime DESC
            ),
            0
        ) AS Grade
    FROM dbo.student_exam se
    JOIN dbo.Exam e ON e.EID = se.EID
    WHERE e.CID = @CID
      AND NOT EXISTS
      (
          SELECT 1
          FROM dbo.Student_Course sc
          WHERE sc.SID = se.SID
            AND sc.CID = e.CID
      );

    COMMIT;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    THROW;
  END CATCH
END
/*===========================================================
3) Views
===========================================================*/

-- 3.1) vw_Exam_Header
create or alter view vw_Exam_Header
as
select
	e.EID, e.CID,c.CName,e.IID,i.IName,e.IntakeID,k.InName,e.bid,b.BName,e.TID,t.TName,e.ExamDate,e.STime
	,e.ETime,e.[type] as ExamType,e.TotalDegree,e.allowoptions
from Exam e join Course c on c.CID =E.CID join Instructor i on i.IID =e.IID
	join Intake k on k.IntakeID = e.IntakeID left join Branch b on b.BID = e.BID
	left join track t on t.TID = e.TID
-----------------------------------------------------------------------
-- 3.2) vw_ExamQuestions
create or alter view vw_ExamQuestions
as
select EQ.EID, EQ.QID, Q.CID, q.[Type],q.QuestionText,q.Choice1, q.Choice2, q.Choice3,q.Choice4,
eq.QDegree
from Exam_Question EQ join Question Q on q.QID =EQ.QID
-----------------------------------------------------------------------
-- 3.3) vw_StudentExamAnswer
create or alter view vw_StudentExamAnswer
as
select a.SID, s.SName, a.EID,a.QID,q.Type,q.QuestionText,eq.QDegree as MaxDegree, a.StudentAns,
a.QGrade,dbo.fn_CalcAutoGrade(a.EID, a.QID,a.StudentAns)as AutoCalcGrade
from Answer a join Student s on s.SID = a.SID
join Question q on q.QID =a.QID
join Exam_Question eq on eq.EID = a.EID and eq.QID = a.QID
-----------------------------------------------------------------------
-- 3.4) vw_StudentExamResult
create or alter view vw_StudentExamResult
as
select se.SID, s.SName, c.CID, c.CName, e.IID, i.IName, e.ExamDate, e.STime, e.ETime, e.TotalDegree,
se.ExamGrade
from student_exam se join Student s on s.SID=se.SID
	join exam e on e.EID = se.EID
	join Course c on c.CID=e.CID
	join Instructor i on i.IID=e.IID
-----------------------------------------------------------------------
-- 3.5) vw_StudentCourseFinalResult
create or alter view vw_StudentCourseFinalResult
as
select SC.SID, s.SName,sc.CID, c.CName,sc.Grade
from Student_Course sc join Student s on sc.SID = s.SID
	join Course c on c.CID =sc.CID
-----------------------------------------------------------------------
-- 3.6) vw_StudentCourseFinalResult
CREATE OR ALTER VIEW dbo.vw_QuestionPool
AS
SELECT
    q.QID, q.CID, c.CName,q.[Type],q.QuestionText, q.Choice1,q.Choice2, q.Choice3, q.Choice4,
    q.CorrectAns
FROM dbo.Question q
JOIN dbo.Course  c ON c.CID = q.CID;



--==============================================Some Procedures & Views for Roles===============================================
--Training manager can add and edit: Branches, tracks in each department, and add new intake.
--Training manager can add students, and define their personal data, intake, branch, and track

--branch
create or alter proc addBranch
@Bname nvarchar(20)
as
begin
	insert into Branch(BName)
	values(@Bname)
end

--addBranch 'Giza'

create or alter proc editBranch
@Bid int,
@Bname nvarchar(20)
as
begin
	if not exists(select 1 from Branch where BID=@Bid)
		begin
			raiserror('This branch doesn''t exist',10,1)
			return
		end
	update branch 
	set BName=@Bname where BID=@Bid
end

--editBranch 6, 'Gizaa'
--editBranch 7, 'Giza'

--intake
create or alter proc addIntake
@Intname varchar(20)
as
begin
	insert into Intake(InName)
	values(@Intname)
end

--addIntake 'nine'

create or alter proc editIntake
@Intid int,
@Intname varchar(20)
as
begin
	if not exists(select 1 from Intake where IntakeID=@Intid)
		begin
			raiserror('This intake doesn''t exist',10,1)
			return
		end
	update Intake 
	set InName=@Intname where IntakeID=@Intid
end

--editIntake 9,'eight'
--editIntake 10,'eight'

--track
create or alter proc addTrack
@tname varchar(20),
@Deptid int
as
begin
	if not exists (select 1 from Department where DID=@Deptid)
		begin
			raiserror('Department ID must exist',10,1)
			return
		end

	insert into Track(TName, DID)
	values(@tname, @Deptid)
end

--addTrack 'python',1
--addTrack 'AI',4

create or alter proc editTrack
@Tid int,
@Deptid int,
@Tname varchar(20)
as
begin
	if not exists(select 1 from Track where TID=@Tid)
		begin
			raiserror('This Track doesn''t exist',10,1)
			return
		end
	if not exists (select 1 from Department where DID=@Deptid)
		begin
			raiserror('This department doesn''t exist',10,1)
			return
		end
	update Track 
	set TName=@Tname, DID=@Deptid
	where TID=@Tid
end

--editTrack 7,1,'pythonADvanced'
--editTrack 8,2,'AI'

--add students
create or alter proc add_student
@name varchar(100), @address nvarchar(255), @age int, @mail nvarchar(100),
@phone varchar(11), @intakeid int, @trackid int, @branchid int
as
begin
	if not exists (select 1 from Intake_Branch_Track
	where IntakeID=@intakeid and BID=@branchid and TID=@trackid)
		begin
			raiserror('This info about track, branch, intake isn''t correct',10,1)
			return
		end
	insert into Student(SName, SAddress, SAge, SEmail, SPhone, IntakeID, TID, BID)
	values(@name, @address, @age, @mail, @phone, @intakeid, @trackid, @branchid)
end

--add_student 'doha','Fayoum',21,'doha.321@example.com',1001234987,8,5,9
--add_student 'doha','Fayoum',21,'doha.321@example.com',1001234987,8,5,1

--simple views
create or alter view vw_allStudents
as
select * from student

create or alter view vw_allCourses
as
select * from Course

create or alter view vw_allInstructors
as
select * from Instructor

create or alter view vw_allQuestions
as
select * from Question

create or alter view vw_allExams
as
select * from Exam

--select * from vw_allStudents
--select * from vw_allCourses
--select * from vw_allInstructors
--select * from vw_allQuestions
--select * from vw_allExams
