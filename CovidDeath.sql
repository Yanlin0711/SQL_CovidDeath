Select *
From ProfolioProject..CovidDeath
order by 3,4

--Select *
--From ProfolioProject..CovidVac
--order by 3,4

--Select data we are going to use
Select location, date, total_cases, new_cases, total_deaths, population
From ProfolioProject..CovidDeath
order by 1, 2

--Looking at Total_Deaths vs Total_Cases(DeathPercentage) in the United States
Select location, date, total_cases, total_deaths, ((total_deaths)/(total_cases))*100 as 'DeathPercentage'
From ProfolioProject..CovidDeath
Where location like '%states%'
order by 1, 2

--Looking at Total_Cases vs Poplulation(InfectPercentage) in the United States
Select location, date, total_cases, population, ((total_cases)/(population))*100 as 'InfectPercentage'
From ProfolioProject..CovidDeath
Where location like '%states%'
order by 1, 2

--Looking at Countries with Highest INfection Rate compared to Population
Select location, population, Max(total_cases) as 'HighestInfectionNumber', Max(((total_cases)/(population)))*100 as 'InfectPercentage'
From ProfolioProject..CovidDeath
Group By location, population
order by InfectPercentage DESC

--Showing Countries  with Highest Death Count per Population
Select location, Max(cast(total_deaths as int)) as 'HighestDeathNumber', Max(((total_deaths)/(population)))*100 as 'DeathPercentage'
From ProfolioProject..CovidDeath
where continent is not null
Group By location
order by DeathPercentage DESC

--Looking at Total_population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER(partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
From ProfolioProject..CovidDeath as dea Join ProfolioProject..CovidVac as vac
On dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--Use CTE
with Pop_vs_Vac(Continent, Location, Date, population, New_vaccinations, RollingPeopleVaccinated)
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER(partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
From ProfolioProject..CovidDeath as dea Join ProfolioProject..CovidVac as vac
On dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)
Select *, ((RollingPeopleVaccinated)/(population))*100
From Pop_vs_Vac

-- Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into  #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER(partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
From ProfolioProject..CovidDeath as dea Join ProfolioProject..CovidVac as vac
On dea.location = vac.location and dea.date = vac.date

Select *, ((RollingPeopleVaccinated)/(population))*100
From #PercentPopulationVaccinated