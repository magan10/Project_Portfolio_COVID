
Select *
From Project_Portfolio..CovidDeaths1
where continent is not null
order by 3,4

--select *
--from Project_Portfolio..CovidVaccinations1
--order by 3,4

-- select the data that we are going to be using

select Location, date, population, total_cases, new_cases, total_deaths
from Project_Portfolio..CovidDeaths1 
where continent is not null
order by 1,2

-- Looking at Total cases vs Total Deaths
-- Shows likehood of dying if you contact covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
from Project_Portfolio..CovidDeaths1
where location like '%states%'
and continent is not null
order by 1,2

-- looking at total cases vs population
--Shows what percentage of population got covid
Select Location, date, population, total_cases,  (total_cases/population)* 100 as PercentPopulationInfected
from Project_Portfolio..CovidDeaths1
where location like '%states%'
and continent is not null
order by 1,2

--looking at countries with highest infection rate compared to population
Select Location, population, max(total_cases) as HighestInfection,  max((total_cases/population))* 100 as PercentPopulationInfected
from Project_Portfolio..CovidDeaths1
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc

-- showing the countries with the highest death count per population

Select Location , Max(cast(total_deaths as int)) as TotalDeathCount
from Project_Portfolio..CovidDeaths1
--where location like '%states%'
where continent is not null
group by Location 
order by TotalDeathCount desc

-- lets break things down by continent

-- showing continents with the highest death count per population

Select continent , Max(cast(total_deaths as int)) as TotalDeathCount
from Project_Portfolio..CovidDeaths1
--where location like '%states%'
where continent is not null
group by continent 
order by TotalDeathCount desc

-- global numbers

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) as DeathPercentage
from Project_Portfolio..CovidDeaths1
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

-- looking total population vs vaccination
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by 
dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) * 100
from Project_Portfolio..CovidDeaths1 dea
join Project_Portfolio..CovidVaccinations1 vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE
with PopvsVac (Continent, Location, Date, Population,New_Vaccination, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by 
dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) * 100
from Project_Portfolio..CovidDeaths1 dea
join Project_Portfolio..CovidVaccinations1 vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select * , (RollingPeopleVaccinated/Population)* 100
from PopvsVac

-- temp table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from Project_Portfolio..CovidDeaths1 dea
join Project_Portfolio..CovidVaccinations1 vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- Creating view to store data for later visualization
create view PercentPopulationVaccinated as 
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from Project_Portfolio..CovidDeaths1 dea
join Project_Portfolio..CovidVaccinations1 vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated