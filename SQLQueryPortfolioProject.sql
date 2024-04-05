--select * 
--From [Portfolio Project]..
--CovidDeaths
--order by 3,4

--select * from [Portfolio Project]..CovidVaccination
--order by 3

--select location, date, total_cases, new_cases, total_deaths, population
--from [Portfolio Project]..CovidDeaths
--order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where location like '%pal%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
select location, date,population,total_cases,(total_cases/population)*100 as InfectionPercentage
from [Portfolio Project]..CovidDeaths
where location like '%nepal%'
order by 1,2

-- Looking at Countries at Highest Infection Rate Comapared to Population
select location,population,Max(total_cases) as HighestInfectionCount,Max(total_cases/population)*100 as InfectionPercentage
from [Portfolio Project]..CovidDeaths
Group by Location, Population
order by InfectionPercentage desc

-- Showing Countries with Highest Death Count per Population
select location,Max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

-- Based on Continent
select location,Max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc

-- showing continents with the highest death count 
select continent ,Max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers

select date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
--where location like '%pal%'
where continent is not null
group by date
order by 1,2


select *
from [Portfolio Project]..CovidVaccination


-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccination vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

with PopvsVac (continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccination vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp Table
Drop Table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccination vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Total vaccinations based on location
select location, population, Max(RollingPeopleVaccinated) as TotalVaccination,(Max(RollingPeopleVaccinated)/Population)*100 as Percentile
from #PercentPopulationVaccinated
group by location, population
order by 1

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccination vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null

select * 
From PercentPopulationVaccinated