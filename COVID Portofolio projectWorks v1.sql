select*
from PortofofioProject..CovidDeaths
Where continent is not null
order by 3,4

--select *
--from PortofofioProject..CovidVaccinations
--order by 3,4

--select Data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from PortofofioProject..CovidDeaths
order by 1,2

--Looking at Tatal Cases vs Total Deaths
--Shows likehood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from PortofofioProject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2


-- Looking at Total cases vs Population
-- Shows what perceentage of population got	Covid
select Location, date, population, total_cases, (total_deaths/population)*100 as PercentPopulationInfected
from PortofofioProject..CovidDeaths
--Where location like '%states%'
order by 1,2 

-- Looking at Country with Highest Infection Rate compared to Population

select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_deaths/population)*100 as PercentPopulationInfected
from PortofofioProject..CovidDeaths
--Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc 

-- Showing Countries with Highest Death Count per Population

select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortofofioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS BY CONTINENT

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortofofioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent 
order by TotalDeathCount desc


-- Showing continent with the highest death count per population

select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortofofioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc




-- GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as deathpercentage
from PortofofioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2 


-- Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(float,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date)
from PortofofioProject..CovidDeaths dea
join PortofofioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

with PopvsVac ( Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(float,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortofofioProject..CovidDeaths dea
join PortofofioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac 




--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(float,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortofofioProject..CovidDeaths dea
join PortofofioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(float,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortofofioProject..CovidDeaths dea
join PortofofioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated