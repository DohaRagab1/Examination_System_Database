--==============================================Text Questions===============================================
--Text Questions

--question.CorrectAns, answer.StudentAns
--answer.Qgrade ==> grade assigned by instructor
--Exam_Question.QDegree ==> full mark question degree

--compare answer.StudentAns with question.CorrectAns
--evaluate and display result to instructors to review and enter marks manually
--instructor see evaluated result, valid answers, not valid answers
--and enter the grade manually answer.Qgrade

--function to normalize text
create or alter function normalizeText (@text nvarchar(max))
returns nvarchar(max)
as
begin
    set @text = lower(@text)
    set @text = ltrim(rtrim(@text))
    set @text = replace(@text, '.','')
    set @text = replace(@text, ',','')
    set @text = replace(@text, '?','')
    return @text

end

--function to get similarity between student & correct answer
create or alter function Text_Similarity (@CorrectAns nvarchar(max), @StudentAns nvarchar(max))
returns decimal (5,2) --5 digits, 2 after the decimal
as
begin
    if @CorrectAns is null or @StudentAns is null
        return 0

    set @CorrectAns = dbo.normalizeText(@CorrectAns)
    set @StudentAns = dbo.normalizeText(@StudentAns)

    declare @LenCorrect int = len(@CorrectAns)
    declare @LenStudent int = len(@StudentAns)
    if @LenCorrect =0 or @LenStudent=0
        return 0

    --matches
    if @CorrectAns=@StudentAns
        return 100
    if @CorrectAns like '%'+@StudentAns+'%' --correct part of student, student more
        return 85
    if @StudentAns like '%'+@CorrectAns+'%' --student part of correct, correct more
        return 75
    if DIFFERENCE(@StudentAns, @CorrectAns) >=3 --phonetic similarity
        return 60
    if DIFFERENCE(@StudentAns, @CorrectAns) =2
        return 20
    
    return 0

end


--function for the instructor review
-- Tried with view but displays all the questions ==> did a function with examid

create or alter function ReviewTextQuestions (@Examid int)
returns table
as
return(
    select q.QuestionText as Question, q.qid as QuestionID, q.CorrectAns as CorrectAnswer,
        a.StudentAns as StudentAnswer, eq.Qdegree as QuestionFullDegree,
        dbo.Text_Similarity(q.CorrectAns, a.StudentAns) as EvaluatedPercentage,
        case
            when dbo.Text_Similarity(q.CorrectAns, a.StudentAns) > 70 then 'Valid'
            when dbo.Text_Similarity(q.CorrectAns, a.StudentAns) > 50 then 'Paritally Valid'
            else 'InValid'
        end as Evaluation
    

    from Question q, Answer a, Exam_Question eq
    where q.qid = a.qid and a.qid = eq.qid and a.eid = eq.eid and eq.eid = @Examid
    and lower(trim(q.type))='text' and a.QGrade is null
)

--procedure for instructor to assign the grades
create or alter proc InsAssignTextGrades
@questionid int,
@AssignedGrade int
as
begin
    declare @MaxDegree int
    select @MaxDegree = Qdegree
    from Exam_Question
    where qid = @questionid

    if @AssignedGrade>@MaxDegree or @AssignedGrade<0
        begin
        raiserror('Error, grade can''t be negative or larger than the maximum degree',10,1)
        return
    end

    update answer
    set qgrade= @AssignedGrade
    where qid = @questionid

end

--test procedures individually

--select dbo.normalizeText('     te.s? t  ') --tes t
--select dbo.Text_Similarity('cairo',' Cairo') --100
--select dbo.Text_Similarity('Albert Einstein',' Einstein') --85
--select dbo.Text_Similarity('Carbon dioxide',' plants absorb carbon dioxide gas') --75
--select dbo.Text_Similarity('Cipher',' Sypher') --60
--select dbo.Text_Similarity('Juice', 'Banana') --0
--select * from ReviewTextQuestions(1) --prints the answered text questions in this exam to be assigned
----What is the capital of Egypt?  	3	Cairo	cair	20	85.00	Valid
--select * from ReviewTextQuestions(2) --empty view, no text questions in this exam
--InsAssignTextGrades 3,21 --Error, grade can't be negative or larger than the maximum degree
--InsAssignTextGrades 3,19 --successful
--select * from ReviewTextQuestions(1) --empty now as the question has been assigned
