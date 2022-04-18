use[PortfolioProject]
go

--beetween
select * 
from [dbo].['covid-vaccination$']
where [date] between '2021-01-01 00:00:00.000' and '2021-01-31 00:00:00.000'
and continent not like ''
order by location

-- all countries, where had more deaths than 30000 and they are part of europe 
Select SUBSTRING (dea.continent,1,2), dea.location, population, max (cast(dea.total_deaths as int)) as death
from PortfolioProject..[covid-deaths] dea
where dea.continent like '%europ%'
group by dea.continent, dea.location, population
having max (cast(dea.total_deaths as int)) > 30000
order by max (cast(dea.total_deaths as int)) desc

--solution through subqueries
Select dea.location, population, max (cast(dea.total_deaths as int)) as death
from PortfolioProject..[covid-deaths] dea
Where dea.location in  (
	select dea.location
	from portfolioProject..[covid-deaths]
	where dea.continent like '%europ%'
	)
group by dea.continent, dea.location, population
having max (cast(dea.total_deaths as int)) > 30000
order by max (cast(dea.total_deaths as int)) DESC


--Lag and lead
select [date], [total_cases], [new_cases], (LAG (total_cases) over(partition by location order by [date]))as prev_value
from [dbo].[covid-deaths]
where continent not like ''
and location like 'Slovakia'

select [date], [total_cases], [new_cases], (Lead (total_cases) over(partition by location order by [date]))as prev_value
from [dbo].[covid-deaths]
where continent not like ''
and location like 'Slovakia'

--10 % totals deaths 
SELECT top 10 percent location, MAX ([total_deaths]) as Maximum_total_deaths
	from PortfolioProject..[covid-deaths]
	where continent not like ''
	group by [location]
	order by Maximum_total_deaths Desc

--vaccination half population and totat death more than 10000
Select dea.continent, dea.location, population, max (cast(dea.total_deaths as bigint)) as death,  max (cast(vac.people_fully_vaccinated as bigint)) as vaccinated
from PortfolioProject..[covid-deaths] dea
join portfolioProject..['covid-vaccination$'] vac
on dea.location=vac.location
Where dea.continent like 'Europe'
group by dea.continent, dea.location, population
having max (cast(dea.total_deaths as bigint)) > 10000
and  (cast (population as numeric (18,0))-max (cast(vac.people_fully_vaccinated as bigint)))>(max (cast ([population] as int))*0.5)
		
--new database for possible research 
create table Deaths_improve
(continent nvarchar(255),
location nvarchar(255), 
total_deaths numeric (10)
)

--Case
select location,new_cases , case
When date between '2020-01-01 00:00:00.000' and '2020-01-31 00:00:00.000'
then 'January'
when date between '2020-02-01 00:00:00.000' and '2020-02-29 00:00:00.000'
then 'Februry'
when date between '2020-03-01 00:00:00.000' and '2020-03-31 00:00:00.000'
then 'March'
when date between '2020-04-01 00:00:00.000' and '2020-04-30 00:00:00.000'
then 'April'
when date between '2020-05-01 00:00:00.000' and '2020-05-31 00:00:00.000'
then 'May'
when date between '2020-06-01 00:00:00.000' and '2020-06-30 00:00:00.000'
then 'June'
when date between '2020-07-01 00:00:00.000' and '2020-07-31 00:00:00.000'
then 'July'
when date between '2020-08-01 00:00:00.000' and '2020-08-31 00:00:00.000'
then 'August'
when date between '2020-09-01 00:00:00.000' and '2020-09-30 00:00:00.000'
then 'September'
when date between '2020-10-01 00:00:00.000' and '2020-10-31 00:00:00.000'
then 'October'
when date between '2020-11-01 00:00:00.000' and '2020-10-30 00:00:00.000'
then 'November'
when date between '2020-11-01 00:00:00.000' and '2020-12-31 00:00:00.000'
then 'December'
end as 'month'
from [dbo].[covid-deaths]
where location like 'United States'
and date like '%2020-__-__%'


-- Find countries where extreme poverty and where possibility of death is more than average 
create view number_to_average
as 
select location, (SUM (cast ([new_deaths] as int))/(max (cast([total_cases] as float)))*100) as numbers
	from[dbo].[covid-deaths]
	where  continent not like ''
	and [total_deaths]>0
	group by location

select avg ([numbers])
from [dbo].[number_to_average]

(select [location]
from [dbo].[number_to_average]
group by location, [numbers]
having [numbers] >2.19474761644228)
intersect
(select location
from PortfolioProject..['covid-vaccination$'] vac
where vac.continent not like ''
group by location
having avg( cast (REPLACE(extreme_poverty,',','.') as numeric (10,2)))>10)

--procedures 

create proc Test_proc
as 
begin
select dea.location, max (cast([total_cases] as bigint)), max (cast ([total_vaccinations] as bigint))
from [dbo].[covid-deaths] dea
join [dbo].['covid-vaccination$'] vac
on dea.[location]=vac.location
where dea.[continent] is not null
group by dea.location
end

create procedure average_of_milion
as 
begin	
select location, avg ( cast ([new_cases_per_million] as float)) as average_milion
from [dbo].[covid-deaths]
where continent not like ''
group by location
end
exec [average_of_milion]


--percentage of deaths divided by population

Select location, population, sum (cast ([new_deaths] as float)) as deaths,max (cast (total_deaths as float))/max(cast (population as bigint))*100 as percentages
from [dbo].[covid-deaths]
where (continent) not like ''
group by location,population
having max (cast (total_deaths as float))> 0
order by  max (cast (total_deaths as float))/max(cast (population as float))*100 Desc

--Json 
select continent as [Country.continent], location as [Country.location]
from [dbo].[covid-deaths]
for Json Path, ROOT('Country')




