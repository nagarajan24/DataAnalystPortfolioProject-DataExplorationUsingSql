-- Tables which we created
select * from PortfolioProject.dbo.CovidDeaths
select * from PortfolioProject..CovidVaccinations

--Filtering out few columns from our main table
select Location, date, total_cases,new_deaths, total_deaths, population
from PortfolioProject..CovidDeaths

--Find Death%(using total cases and total deaths)
--Show number of ppl who can die if they get affected by covid
select Location, date, total_cases, total_deaths, (Cast(total_deaths as float)/Cast(total_cases as float))*100 as Death_Percentage
from PortfolioProject..CovidDeaths
order by 1,2

--Find total cases vs population %
--Shows what % of population got covid
select Location, date, population, total_cases, (Cast(total_cases as float)/Cast(population as float))* 100 as CovidAffectedPercentage
from PortfolioProject..CovidDeaths
order by 1,2

--Highest infection rate for a country, population wise
select Location, Population, Max(total_Cases) as HighestInfectionRate, Max(Cast(total_Cases as float)/Cast(population as float))*100 as HighestConvidAffectedPopulationPercentage
from PortfolioProject..CovidDeaths
group by Location, Population
order by 4 Desc

--Highest Death rate country wise
select Location, Max(total_deaths) as HighestDeathRate
from PortfolioProject..CovidDeaths
where continent is not null
group by Location
order by 2 desc

--Highest Death rate continent wise
select location, max(total_deaths) as HighestDeathRate
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by 2 desc

--or(this will not give the exact numbers, so use the above one)

select continent, max(total_deaths) as HighestDeathRate
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by 2 desc


--Global Cases numbers
select sum(cast(total_cases as bigint)) as SumTotalCase, Sum(total_deaths) as SumTotalDeaths
, Sum(cast(total_deaths as float))/sum(cast(total_cases as float))*100 as GlobalCasesPercentage 
from PortfolioProject..CovidDeaths
where continent is not null

--Rolling People Vaccinated(Location wise calculate the increase in vaccinations for each day)
select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,
sum(dea.new_vaccinations) over (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
inner join PortfolioProject..CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

--Total Population Vs Vaccinations

--A)With CTE
with CTE_POPVSVAC (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,
sum(dea.new_vaccinations) over (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
inner join PortfolioProject..CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null)
select * , (cast(RollingPeopleVaccinated as float)/cast(Population as float))*100 as PopVsVac
from CTE_POPVSVAC 


--OR

With CTE_POPVSVAC1
AS
(select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,
sum(dea.new_vaccinations) over (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
inner join PortfolioProject..CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null)
select *, (cast(RollingPeopleVaccinated as float)/cast(Population as float))*100 as PopVsVac
from CTE_POPVSVAC1


--B)With Temp Table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
( Continent varchar(50),
location varchar(50),
date date,
population int,
new_vaccinations int,
RollingPeopleVaccinated int)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,
sum(dea.new_vaccinations) over (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
inner join PortfolioProject..CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

select *, (cast(RollingPeopleVaccinated as float)/cast(Population as float))*100 as PopVsVac
from #PercentPopulationVaccinated

--Create views for our queries for later visualization

--A)View for Rolling People Vaccinated

Create View View_RollingPeopleVaccinated AS
select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,
sum(dea.new_vaccinations) over (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
inner join PortfolioProject..CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

select * from View_RollingPeopleVaccinated

--B)View for Global Case numbers

Create View View_GlobalCases AS
select sum(cast(total_cases as bigint)) as SumTotalCase, Sum(total_deaths) as SumTotalDeaths
, Sum(cast(total_deaths as float))/sum(cast(total_cases as float))*100 as GlobalCasesPercentage 
from PortfolioProject..CovidDeaths
where continent is not null

select * from View_GlobalCases
