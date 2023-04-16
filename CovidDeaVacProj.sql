-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
FROM CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2

-- Looking at Countries with highest infection rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Showing continents with the highest death count per population
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS totalcases, SUM(new_deaths) AS totaldeaths, SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 as DeathPercentage
FROM CovidDeaths
where continent is not null
group by date
order by 1,2

--Looking at Total Population vs Vaccinations
-- Using CTE
WITH PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--USING TEMP TABLE (remember to have DROP TABLE as a good rule of thumb for temp tables)
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population float,
new_vaccinations float,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store date for later visualizations
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated

