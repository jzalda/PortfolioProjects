
SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%states%' AND continent IS NOT NULL
ORDER BY 1,2


-- Total Cases vs Population
SELECT location, date, population, total_cases,  (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2


-- Countries with Highest Infection Rate Compared to Population
SELECT  location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/ population) * 100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population
SELECT  location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Show continent with highest death count per population
SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT 
    continent, SUM(TotalDeathCount) as OverallTotalDeathCount
FROM (
    SELECT continent, location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
    FROM PortfolioProject.dbo.CovidDeaths
    WHERE continent IS NOT NULL 
    GROUP BY continent, location) AS PerCountry
GROUP BY 
    continent;


-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, SUM(CAST(new_deaths as INT))/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, SUM(CAST(new_deaths as INT))/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2



-- Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3


-- USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeoplevaccinated) AS (
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
	FROM PortfolioProject.dbo.CovidDeaths dea
	JOIN PortfolioProject.dbo.CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent is NOT NULL
	--ORDER BY 2,3
)
SELECT *, (RollingPeoplevaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3
SELECT *, (RollingPeoplevaccinated/Population)*100
FROM #PercentPopulationVaccinated




-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated