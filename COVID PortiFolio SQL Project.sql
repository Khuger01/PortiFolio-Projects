--SELECT *
--FROM CovidDeaths 
--order by 3,4

--SELECT *
--FROM CovidVaccinations 
--order by 3,4

--Selecting Usefuldata for this Project

SELECT Location,[date], total_cases , new_cases, total_deaths, population
FROM CovidDeaths 
order by 1,2

--- Break things by Continent

Select continent , MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by continent 
order by TotalDeathCount desc

--Looking at Total cases vs Total Deaths
--Shows the likelihood of dying if one gets covid

SELECT Location,[date], total_cases , total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths 
WHERE location = 'Africa'
order by 1,2

--Looking at the Total Cases Vs Population
--shows what percentage of population has covid

SELECT Location,[date], population, total_cases  ,(total_cases/population)*100 as InfectedPopulationPercentage
FROM CovidDeaths 
WHERE location = 'Africa'
order by 1,2

--Highest Infection Rate Compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount  ,Max((total_cases/population))*100 as InfectedPopulationPercentage
FROM CovidDeaths 
Group by location, population 
order by InfectedPopulationPercentage DESC

--Highest Death Count per population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount  
FROM CovidDeaths 
--WHERE location = 'Africa'
Group by location 
order by TotalDeathCount DESC

--Continents with the highest death count per population


Select continent , MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by continent 
order by TotalDeathCount DESC 

---Global STATISTICS 

SELECT /*[date],*/ SUM(new_cases) AS totalcases, SUM(cast(new_deaths as int)) as totaldeaths,  (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM  CovidDeaths
WHERE continent IS NOT NULL
--WHERE location = 'Africa'
--GROUP BY [date] 
order by 1,2

--Total Population vs Vaccinaations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


--use CTE  

With PopvsVac (Continent, Location, [date], Population,new_vaccinations ,RollingPeopleVaccinated )
AS (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
SELECT *
FROM PopvsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE Table #PercentagePopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
[Date] datetime,
Population INT,
New_vaccinations INT,
RollingPeopleVaccinated INT
)

INSERT INTO #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


--Creating View to store for later visualisation

CREATE VIEW PercentagePopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


Select *
from PercentagePopulationVaccinated ppv 



