select *
from project1..CovidDeaths$
where continent is not null
order by 3,4

--select *
--from project1..CovidVaccinations$
--order by 3,4
--select data we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from project1..CovidDeaths$
where continent is not null
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of death if you contracted covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from project1..CovidDeaths$
where location like  '%india%'
and continent is not null
order by 1,2

--looking at total cases vs population-hat percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as percentPopulationInfected
from project1..CovidDeaths$
where continent is not null
--where location like  '%india%'
order by 1,2

--looking at countries with highest infection rate compared to population
select location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as percentPopulationInfected
from project1..CovidDeaths$
--where location like  '%india%'
where continent is not null
Group by location, population
order by percentPopulationInfected desc

--showing countries with highest death count per population
select location, MAX(cast(total_deaths as int)) as totaldeathCount
from project1..CovidDeaths$
--where location like  '%india%'
where continent is not null
Group by location
order by totaldeathCount desc


--let's break things down by continent
--showing continents with highest death count per population
select continent, MAX(cast(total_deaths as int)) as totaldeathCount
from project1..CovidDeaths$
--where location like  '%india%'
where continent is not null
Group by continent
order by totaldeathCount desc

--global numbers
select  sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
From project1..CovidDeaths$
--where location like  '%india%'
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccinations
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from project1..CovidDeaths$ dea
Join  project1..CovidVaccinations$ vac
   On dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
order by 2,3

--USE CTE
with popvsvac(continent,location,date,population,new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from project1..CovidDeaths$ dea
Join  project1..CovidVaccinations$ vac
   On dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvac

--temp table
drop table if exists #percentpopvac
create table #percentpopvac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #percentpopvac
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from project1..CovidDeaths$ dea
Join  project1..CovidVaccinations$ vac
   On dea.location=vac.location
   and dea.date=vac.date
--where dea.continent is not null
--order by 2,3
select *, (rollingpeoplevaccinated/population)*100
from #percentpopvac

--creating view to store data for later visualizations
Create View PercentPopVacc as
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from project1..CovidDeaths$ dea
Join  project1..CovidVaccinations$ vac
   On dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
--order by 2,3



 
