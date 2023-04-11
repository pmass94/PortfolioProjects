Select *
From PortfolioProjectCorona..CovidDeaths$
order by 3,4

--Select *
--From PortfolioProjectCorona..CovidVaccinations$
--order by 3,4

-- Select Data that I am going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjectCorona..CovidDeaths$
order by 1,2


-- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths
,(CONVERT(decimal(12,3), total_deaths) / CONVERT(decimal(12,3), total_cases))*100 as DeathPercentage
From PortfolioProjectCorona..CovidDeaths$
where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population

Select Location, date, total_cases, population 
,(CONVERT(decimal(12,3), total_cases) / CONVERT(decimal(12,3), population))*100 as CasesPercantage
From PortfolioProjectCorona..CovidDeaths$
where location like '%states%'
order by 1,2

-- Looking at Countries with highest infection rate compared to population, death, etc.

Select Location, population, MAX(Cast(total_cases as bigint)) as TotalCases, Max(Cast(total_deaths as bigint)) as TotalDeaths
,MAX((CONVERT(decimal(15,3), total_cases) / CONVERT(decimal(15,3), population)))*100 as CasesPercantagePopulation
,MAX((CONVERT(decimal(12,3), total_deaths) / CONVERT(decimal(12,3), total_cases)))*100 as DeathPercentagePerCase
,MAX((CONVERT(decimal(15,3), total_deaths) / CONVERT(decimal(15,3), population)))*100 as DeathPercentagePopulation
From PortfolioProjectCorona..CovidDeaths$
where location like '%%'
and continent is not null
group by Location, population
order by 7 desc 

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVacc
From PortfolioProjectCorona..CovidDeaths$ dea
join PortfolioProjectCorona..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE

With PopvsVac (Continent, Location, Date, Population, new_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--, (rollingPeopleVaccinated/population)*100
From PortfolioProjectCorona..CovidDeaths$ dea
join PortfolioProjectCorona..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From PopvsVac
where new_Vaccinations is not null
and RollingPeopleVaccinated is not null


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--, (rollingPeopleVaccinated/population)*100
From PortfolioProjectCorona..CovidDeaths$ dea
join PortfolioProjectCorona..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

