use[random]
go

delete from [dbo].['Random generator$'] where [Last Name] is null

--additional gender_id
select [Last_Name],[Gender], iif([Gender]='male','1','2') as gender_id
from [dbo].['Random generator$']


--ten top salary between doctoral and master
select top 10 ID,[Last_Name], Salary, Education
from random..['Random generator$']
where Education = 'Doctoral' or Education = 'Master'
order by salary desc

--average salary upon by occupation
select occupation, round(avg(salary),0) as 'average_salary'
from ['Random generator$']
group by Occupation
order by average_salary Desc

--categorization
select [Last_Name],[question_1], case
when[question_1] <=3 then 1
when[question_1] <=6 then 2
when[question_1] <=9 then 3
end as groups
from ['Random generator$']

--acid transaction
begin tran
update [dbo].['Random generator$']
set [Salary]=[Salary] - 200
where [Occupation] = 'Medic'
commit

--pivot
select[Marital Status], [Male],[Female]
from
(select[Marital Status], [question_1], [Gender]
from [dbo].['Random generator$']
where [question_1]> 5
 ) as SRC
pivot( count ([question_1]) 
for gender in (Male, Female)
) as Pvt

--grouping sets
SELECT [Education], [Occupation], SUM(Salary) as Salary 
FROM [dbo].['Random generator$']
GROUP BY GROUPING SETS(([Education],[Occupation]),()) 

SELECT [Education], [Occupation], round (avg (cast([question_1] as float)),2) as Avg_question_1 , round (avg (cast ([question_2] as float)),2) as Avg_question_2
FROM [dbo].['Random generator$']
GROUP BY GROUPING SETS(([Education],[Occupation]),(), ()) 

--coursor
begin
declare @Last_Name nvarchar(255)
declare @Gender nvarchar(255)
declare @Age float
declare @Salary float
declare list_of_name cursor
for select [Last_Name], [Gender], [Age], Salary from [dbo].['Random generator$'] where[Occupation] = 'Lecturer'
open  list_of_name
fetch next from list_of_name into @Last_Name, @Gender, @Age, @Salary
while @@FETCH_STATUS=0
begin
if @Salary < 3000
begin set @Salary = @Salary+ 400 end
else
begin set @Salary = @Salary end
update [dbo].['Random generator$'] set Salary = @Salary where [Last_Name] = @Last_Name
print @Last_Name + ' earns ' + cast (@Salary as varchar)
fetch next from list_of_name into @Last_Name, @Gender, @Age, @Salary
end
close list_of_name
deallocate list_of_name
end

--statistical information
select 
((select MAX ([question_1]) from
(select top 50 percent[question_1]from [dbo].['Random generator$'] order by [question_1]) as bottom)
+
(select Min ([question_1]) from
(select top 50 percent[question_1] from [dbo].['Random generator$'] order by [question_1]Desc) as up)
)/2 as Median
select 
((select MAX ([question_2]) from
(select top 50 percent[question_2]from [dbo].['Random generator$'] order by [question_2]) as bottom)
+
(select Min ([question_2]) from
(select top 50 percent[question_2] from [dbo].['Random generator$'] order by [question_2]Desc) as up)
)/2 as Median
--
select VAR ([question_1])
FROM [dbo].['Random generator$']

select VAR ([question_2])
FROM [dbo].['Random generator$']
--
create view IQRQ1 as
select NTILE(3) OVER ( ORDER BY [question_1] ) AS Quartile,[question_1]
from[dbo].['Random generator$']

select Quartile, avg([question_1]) 
from [dbo].[IQRQ1]
WHERE Quartile <= 3
GROUP BY Quartile
--
create view IQRQ2 as
select NTILE(3) OVER ( ORDER BY [question_2] ) AS Quartile,[question_2]
from[dbo].['Random generator$']

select Quartile, avg([question_2]) 
from [dbo].[IQRQ2]
WHERE Quartile <= 3
GROUP BY Quartile
--
select round( stdev ([question_1]),3)
from [dbo].['Random generator$']

select round( stdev ([question_2]),3)
from [dbo].['Random generator$']

