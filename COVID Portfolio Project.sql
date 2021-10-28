
SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT null
ORDER BY 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at the Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID

SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, MAX(total_cases) as HighestTotalCases, population, MAX((total_cases/population))*100 as MaxInfectionPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY location,population
ORDER BY MaxInfectionPercentage DESC

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
GROUP BY location
ORDER BY HighestDeathCount DESC

-- Let's break things down by Continent

SELECT location,MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Global Numbers
SELECT date,SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1

-- Global Overall Table
SELECT SUM(new_cases) as total_cases,SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases) as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL

-- Looking at Total Population vs Vaccinations

SELECT dea.continent,dea.location,dea.population,dea.date,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,cast(dea.date as datetime)) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	ORDER BY 2,3

	-- Using CTE

WITH PopvsVac (Continent,location,date,population,new_vaccinations,RollingPeopleVacinated)
as (
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,CONVERT(datetime,dea.date)) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVacinated/population)*100
FROM PopvsVac

-- TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,CONVERT(datetime,dea.date)) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating View to Store Data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,CONVERT(datetime,dea.date)) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL

SELECT * 
FROM PercentPopulationVaccinated