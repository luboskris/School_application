use[course]
go

--joins
select P.Name, concat (o.[Name],' ', o.Surname) as name
from [Pets] P
left join [Owners] O
on P.[OwnerID] = O.[OwnerID]
where left (p.Name, 1) = left (o.Name, 1)

select P.Petid, [Kind], [OwnerID] 
from[dbo].[ProceduresHistory] PH
inner join [dbo].[Pets] P
on PH.Petid = P.Petid
inner join [dbo].[ProceduresDetails] pd
on PH.[ProcedureSubCode] = PD.[ProcedureSubCode]
group by [OwnerID], P.Petid, [Kind]

select [OwnerID], [Name], A. [Petid], B.[ProcedureType],B.[ProcedureSubCode], [Price]
from [dbo].[Pets] A
inner join [dbo].[ProceduresHistory] B
on A.Petid = B.PetID
left Join [dbo].[ProceduresDetails] C
on B.[ProcedureSubCode] = C.[ProcedureSubCode]
and B.ProcedureType = C.ProcedureType

select *
from [dbo].[Pets] as a
full outer join [dbo].[ProceduresHistory] as b
on a.petid = b.PetID
where a.Petid is not null
and b.PetID is not null

--searching particular position 
select *,CHARINDEX ('Rochester Hills',City)
from [dbo].[Owners]
select *,PATINDEX ('%48302%',[ZipCode])
from [dbo].[Owners]

--history of procedures with price
select [Petid], [ProcedureDate], a.[ProcedureType], b.[ProcedureSubCode],[Description],[Price]
from [dbo].[ProceduresHistory] a
left join [dbo].[ProceduresDetails] b
on a.[ProcedureSubCode] = b.[ProcedureSubCode]
and a.ProcedureType = b.ProcedureType
order by [ProcedureDate]

--owners and their bills
select  OW.OwnerID, concat (ow.[Name],' ', ow.Surname) as Name, PH.[ProcedureType], PH.[ProcedureSubCode], PD.Price, PAO.[price_all_operations]
from [dbo].[Owners] OW
join [dbo].[Pets] PE
on OW.[OwnerID]= PE.[OwnerID]
join [dbo].[ProceduresHistory] PH
on PE.Petid = PH.PetID
join [dbo].[ProceduresDetails] PD
on PH.[ProcedureType]=PD.[ProcedureType]
and PD.[ProcedureSubCode]=PH.[ProcedureSubCode]
join [dbo].[price_all_operations] PAO
on ph.[Petid]=PAO.Petid
group by OW.OwnerID, ow.[Name], ow.Surname, PH.[ProcedureType], PH.[ProcedureSubCode], [price_all_operations], Price
having PH.[ProcedureType] is not null

create view price_all_operations as
select sum ([Price]) as price_all_operations, Petid
from [dbo].[ProceduresDetails] PD  
inner join [dbo].[ProceduresHistory] PH 
on PD.[ProcedureSubCode] = PH.[ProcedureSubCode]
and PH.ProcedureType = PD.ProcedureType 
group by [Petid]

--contol match pet and Owner
select PH.PetID, PE.[OwnerID]
from [dbo].[ProceduresHistory] PH
left join [dbo].[Pets] PE
on PH.[Petid] = PE.[PetID]
group by PH.PetID, PE.[OwnerID]
order by PE.[OwnerID] DESC

--vaccination after six years
select *,DATEDIFF(MONTH,[ProcedureDate],GETDATE()) AS DateDiff
from [dbo].[ProceduresHistory]
where DATEDIFF(MONTH,[ProcedureDate],GETDATE()) >= 72
and [ProcedureType]= 'vaccinations'

-- need for vaccination animals, which was vaccinated and are more than 8 years
select o.OwnerID, concat (o.[Name],' ', o.Surname) as name, p.Petid, p.Age
from [dbo].[Owners] o
inner join [dbo].[Pets] p
on o.[OwnerID] = p.[OwnerID]
inner join [dbo].[ProceduresHistory] h
on p.[PetID] = h.PetID
where p.[Age] > 8
and h.[ProcedureType] = 'VACCINATIONS'
group by o.OwnerID, o.[Name], o.Surname,p.Petid, p.Age

--discount for vaccinations
select OW.[OwnerID],PE.[Petid], [ProcedureDate], PH.[ProcedureType], PH.[ProcedureSubCode],[Price], 
case when Ph.ProcedureType= 'VACCINATIONS' then 0.10 else 0.00 end as Discount
from [dbo].[Owners] OW
join [dbo].[Pets] PE
on OW.[OwnerID]= PE.[OwnerID]
join[dbo].[ProceduresHistory] PH
on PH.[PetID] = PE.[Petid]
join [dbo].[RAW_ProceduresDetails] PD
on PH.[ProcedureType]=PD.[ProcedureType]
and PH.[ProcedureSubCode]=PD.ProcedureSubCode
where Ph.ProcedureType= 'VACCINATIONS'

-- pivot
select [ProcedureType], [January], [February], [March], [April]
from
(select [ProcedureType], DATENAME (MONTH, [ProcedureDate]) as [Month], [ProcedureSubCode]
from [dbo].[ProceduresHistory]
group by[ProcedureSubCode], [ProcedureType], [ProcedureDate]
 ) as Src
pivot (count ([ProcedureSubCode])
for [Month] in ([January], [February], [March], [april])) as Pvt
