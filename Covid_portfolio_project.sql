SELECT *
FROM portfolio_project..CovidDeaths
ORDER BY 3,4

--SELECT *
--OM portfolio_project..CovidVaccinations
--ORDER BY 3,4

--Explore the data in the CovidDeaths and CovidVaccinations tables to understand the structure and content of the data. This will help in formulating queries to analyze the impact of COVID-19 on different locations and populations.

SELECT location, date, total_cases, total_deaths, new_deaths, population
FROM portfolio_project..CovidDeaths
WHERE  continent is not null
ORDER BY 1,2


-- Look for trends in the number of cases and deaths over time for different locations. This can help identify which areas were most affected by the pandemic and how the situation evolved over time.

SELECT  location, date, total_cases, total_deaths,ROUND((total_deaths/total_cases)*100,2) as death_rate
FROM portfolio_project..CovidDeaths
WHERE  continent is not null
ORDER BY 1,2


--Look for the trends in Canada, United States, and Mexico to compare the impact of COVID-19 in these neighboring countries. This can help identify differences in the spread of the virus and the effectiveness of public health measures in each country.

SELECT  location, date, total_cases, total_deaths,ROUND((total_deaths/total_cases)*100,2) as death_rate
FROM portfolio_project..CovidDeaths
WHERE location in ('Canada', 'United States', 'Mexico') 
AND  continent is not null
ORDER BY 1,2

--Look for the trends in Total Cases with the population to understand the spread of the virus in relation to the population size. This can help identify which locations had a higher number of cases relative to their population, indicating a more severe impact of the pandemic.

SELECT  location, date, total_cases, population, ((total_cases/population)*100) as Death_Rate_Percentage
FROM portfolio_project..CovidDeaths
WHERE location in ('Canada') 
AND  continent is not null
ORDER BY 1,2


--Look for the counrty with the highest number of cases compared to the population to identify which location had the most severe impact of the pandemic. This can help prioritize public health interventions and resources to areas that were most affected.

SELECT location,MAX(total_cases) as highest_infection, population, ((MAX(total_cases)/population)*100) as percentage_of_infection
FROM portfolio_project..CovidDeaths
WHERE  continent is not null
GROUP BY location, population
ORDER BY percentage_of_infection DESC


--Countries with Highest Death Rate with respect to the population to identify which locations had the highest death rates relative to their population size. This can help prioritize public health interventions and resources to areas that were most affected by the pandemic.

SELECT    location, MAX(CAST(total_deaths AS INT)) AS count_of_deaths
FROM portfolio_project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY count_of_deaths DESC


--compare the contients with the highest number of deaths to identify which regions were most affected by the pandemic. This can help prioritize public health interventions and resources to areas that were most affected.

SELECT    continent, MAX(CAST(total_deaths AS INT)) AS count_of_deaths
FROM portfolio_project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY count_of_deaths DESC


--Look for the global trends in Total new cases and new deaths over time to understand the progression of the pandemic..

SELECT  SUM (population) as total_population, SUM (new_cases) as total_new_cases, SUM (CAST(new_deaths AS INT)) as total_new_deaths,
SUM (CAST(new_deaths AS INT))/SUM (new_cases)*100 as case_to_death_ratio
FROM portfolio_project..CovidDeaths
WHERE  continent is not null
ORDER BY 1,2


--Join the CovidDeaths and CovidVaccinations tables to analyze the relationship between vaccination rates and COVID-19 outcomes. This can help identify whether higher vaccination rates are associated with lower case numbers and death rates.

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CAST(VAC.new_vaccinations AS INT)) OVER (PARTITION BY DEA.location ORDER BY DEA.date,DEA.location) as rolling_sum_vaccinations
FROM portfolio_project..CovidDeaths DEA
JOIN portfolio_project..CovidVaccinations VAC
ON DEA.location = VAC.location 
AND DEA.date = VAC.date
WHERE DEA.continent is not null
ORDER BY 2,3

--CTE

WITH CTE_Vaccinations (continent,location, date, population,new_vaccinations,rolling_sum_vaccinations) AS
(SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CAST(VAC.new_vaccinations AS INT)) OVER (PARTITION BY DEA.location ORDER BY DEA.date,DEA.location) as rolling_sum_vaccinations
FROM portfolio_project..CovidDeaths DEA
JOIN portfolio_project..CovidVaccinations VAC
ON DEA.location = VAC.location 
AND DEA.date = VAC.date
WHERE DEA.continent is not null
)

SELECT *,(rolling_sum_vaccinations/population)*100 as vaccination_rate_percentage
FROM CTE_Vaccinations


--temp table

DROP TABLE IF EXISTS #TempVaccinations

CREATE TABLE #TempVaccinations (
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATE,
    population BIGINT,
    new_vaccinations BIGINT,
    rolling_sum_vaccinations BIGINT
)   

INSERT INTO #TempVaccinations 
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CAST(VAC.new_vaccinations AS INT)) OVER (PARTITION BY DEA.location ORDER BY DEA.date,DEA.location) as rolling_sum_vaccinations
FROM portfolio_project..CovidDeaths DEA
JOIN portfolio_project..CovidVaccinations VAC
ON DEA.location = VAC.location 
AND DEA.date = VAC.date
WHERE DEA.continent is not null


SELECT *,(rolling_sum_vaccinations/population)*100 as vaccination_rate_percentage
FROM #TempVaccinations


-- create a view to analyze the relationship between vaccination rates and COVID-19 outcomes.

DROP VIEW IF EXISTS vw_VaccinationRates
GO

CREATE VIEW vw_VaccinationRates AS
SELECT 
DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CAST(VAC.new_vaccinations AS INT)) OVER (PARTITION BY DEA.location ORDER BY DEA.date,DEA.location) as rolling_sum_vaccinations
FROM portfolio_project..CovidDeaths DEA
JOIN portfolio_project..CovidVaccinations VAC
ON DEA.location = VAC.location 
AND DEA.date = VAC.date
WHERE DEA.continent is not null
GO

SELECT*
FROM vw_VaccinationRates
