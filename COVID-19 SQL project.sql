Select * 
From PortfolioProject..CovidDeaths
order by 3,4

--Select * 
--From PortfolioProject..Covidvaccinations
--order by 3,4
 
 --selecting the data that we are goimg to use

 select location, date, total_cases, new_cases, total_deaths, population
 from PortfolioProject..CovidDeaths
 order by 1,2

 --total cases vs the total deaths(%)

 select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as deathpercentage
 from PortfolioProject..CovidDeaths
 where location = 'india'
 order by 1,2


 --total cases vs population (%)


  select location, date, total_cases, population, (cast(total_cases as float)/cast(population as float))*100 as populationinfected
 from PortfolioProject..CovidDeaths
 where location = 'india'
 order by 1,2

 --countries with highest infection rate

   select location, population, max(total_cases) as highestinfectioncount, max(cast(total_cases as float)/cast(population as float))*100 as populationinfected
 from PortfolioProject..CovidDeaths
 group by location, population
 order by populationinfected desc

  --showing countries with highest death per population

 select location, max(cast(total_deaths as int)) as totaldeathcount
 from PortfolioProject..CovidDeaths
 where continent is not null
 group by location
 order by totaldeathcount desc

 ---now looking continent wise

select continent, max(cast(total_deaths as int)) as totaldeathcount
 from PortfolioProject..CovidDeaths
 where continent is not null
 group by continent
 order by totaldeathcount desc

 --breaking into datewise total cases and totaldeaths



  select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int))as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
 from PortfolioProject..CovidDeaths
 where continent is not null
 group by date
 order by 1,2

 --total cases vs total deaths

 
  select sum(new_cases) as total_cases, sum(cast(new_deaths as int))as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
 from PortfolioProject..CovidDeaths
 where continent is not null
 order by 1,2


 --joining both deaths and vaccinatons table 

 select*
 from PortfolioProject..CovidDeaths d
 join PortfolioProject..CovidVaccinations v
   on d.location = v.location
   and d.date = v.date
   
   --

   select d.continent, d.location, d.population, v.new_vaccinations
   from PortfolioProject..CovidDeaths d
 join PortfolioProject..CovidVaccinations v
 on d.location = v.location
 and d.date = v.date
 where d.continent is not null
 order by 1,2,3 


 --cummulative aggrigate using 'sum over' clause 

 select d.continent, d.location, d.date, d.population, v.new_vaccinations,
 sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as rollingpeoplevaccinated
 from PortfolioProject..CovidDeaths d
 join PortfolioProject..CovidVaccinations v
 on d.location = v.location
 and d.date = v.date
 where d.continent is not null
 order by 2,3 


 ---using cte

 with popvsvacc (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
 as
 (
  select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
on d.location = v.location
and d.date = v.date
where d.continent is not null
-- order by 2,3 (as order by clause cannot be ther in cte function)
 )
 select *, (rollingpeoplevaccinated/population)*100 as peoplevaccinated
 from popvsvacc
