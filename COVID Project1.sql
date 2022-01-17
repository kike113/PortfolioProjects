Select * 
From Project1..CovidDeaths
where continent is not null
order by 3,4

--Select * 
--From Project1..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From Project1..CovidDeaths
order by 1,2


--Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From Project1..CovidDeaths
--where location like '%states%'
order by 1,2


--Total Cases vs Population

Select Location, date, population, total_cases, (total_cases/population)*100 as sick_percentage
From Project1..CovidDeaths
order by 1,2


-- Countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as 
	HighestInfectionCount, MAX((total_cases/population))*100 as 
	infected_percentage
From Project1..CovidDeaths
Group by location, population
order by infected_percentage desc


-- Countries with highest Death count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Project1..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc


-- Showing continents with highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Project1..CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From Project1..CovidDeaths
Where location like '%world%'
Group by date, total_cases, total_deaths
order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as rolling_vaccinated
From Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, rolling_vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as rolling_vaccinated
From Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (rolling_vaccinated/population)*100
From PopvsVac



-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_vaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as rolling_vaccinated
From Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select *, (rolling_vaccinated/population)*100
From #PercentPopulationVaccinated


--Creating View for data visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as rolling_vaccinated
From Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select * 
From PercentPopulationVaccinated