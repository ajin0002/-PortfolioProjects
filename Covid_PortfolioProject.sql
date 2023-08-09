-- EDA of Covid Data
Create database PortflioProject;
use PortflioProject;
-- changing datatypes 
select * from coviddeaths;
alter table coviddeaths change column ï»¿iso_code iso_code varchar(10);
update coviddeaths set date = str_to_date(date, '%m/%d/%Y') ;
alter table portflioproject.coviddeaths modify column new_cases int;
-- changing datatypes
select * from covidvaccinations;
alter table covidvaccinations change column ï»¿iso_code iso_code varchar(10);
update covidvaccinations set date = str_to_date(date, '%m/%d/%Y') ;
alter table portflioproject.covidvaccinations modify column new_vaccinations int;

-- Looking At Data
select location,date,total_cases,new_cases,total_deaths,population
 from portflioproject.coviddeaths order by location,date;
 
 -- Looking at Total Cases vs Total Deaths
 -- Shows likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 from portflioproject.coviddeaths  where location like '%india%' order by location,date;
 
 -- Looking at total cases vs total population
 -- this shows percentage of population which got covid
select location,date,population,total_cases, (total_cases/population)*100 as CasesPercentage
 from portflioproject.coviddeaths  where location like '%india%' order by location,date;

-- Looking at countries with highest infection rate

select location,population,max(total_cases) as highest_infection_count, max((total_cases/population)*100) as PercentageCases
 from portflioproject.coviddeaths group by location,population order by PercentageCases desc;
 
 -- Countires with the highest death count per population
 
select location,max(total_deaths) as TotalDeathCount
 from portflioproject.coviddeaths where continent is null group by location order by TotalDeathCount desc;
 
 -- Total deaths by Continent
 select continent,max(total_deaths) as TotalDeathCount
 from portflioproject.coviddeaths where continent is not null group by continent order by TotalDeathCount desc;
 
 -- View of total Deaths by Continent 
 create view DeathsContinent as 
 select continent,max(total_deaths) as TotalDeathCount
 from portflioproject.coviddeaths where continent is not null group by continent order by TotalDeathCount desc;
 
 -- Gloabl numbers
 
select date, sum(new_cases) as TotalNewCases,sum(new_deaths) as TotalNewDeaths , (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
 from portflioproject.coviddeaths  where continent is not null group by date order by 1,2;
 
 -- View For Global Numbers
 create view GlobalNumber as 
 select date, sum(new_cases) as TotalNewCases,sum(new_deaths) as TotalNewDeaths , (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
 from portflioproject.coviddeaths  where continent is not null group by date order by 1,2;
 
 -- Total Cases / Total death globaly
 select  sum(new_cases) as TotalNewCases,sum(new_deaths) as TotalNewDeaths , (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
 from portflioproject.coviddeaths  where continent is not null  order by 1,2;
 
 -- Looking at total population vs Vaccinations 
 
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(vac.new_vaccinations) over(partition by dea.location order by dea.location,dea.date) 
 as RollingPeopleVaccinated
 from portflioproject.coviddeaths as dea join PortflioProject.covidvaccinations as vac 
 on dea.location= vac.location and dea.date = vac.date where dea.continent is not null order by 2,3;
 
 -- Rolling Vaccination Percentage
 
 with PopvsVac (Continent,Loaction,date,population,new_vaccinations,Rolling_Count_Vaccinations)
 as
 (select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(vac.new_vaccinations) over(partition by dea.location order by dea.location,dea.date) 
 as Rolling_Count_Vaccinations
 from portflioproject.coviddeaths as dea join PortflioProject.covidvaccinations as vac 
 on dea.location= vac.location and dea.date = vac.date where dea.continent is not null )
 select *, (Rolling_Count_Vaccinations/population)*100 as Rolling_Vaccination_Percentage  from PopvsVac;
 
 -- Temp Table
drop table PercentagePopulationVaccinated;
 Create table PercentagePopulationVaccinated
 (
 Continent varchar(20),
 Location varchar(255),
 Date Date,
 Population bigint,
 New_vaccination bigint,
 RollingPeopleVaccinated bigint);
 
 insert into PercentagePopulationVaccinated
 (select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(vac.new_vaccinations) over(partition by dea.location order by dea.location,dea.date) 
 as RollingPeopleVaccinated
 from portflioproject.coviddeaths as dea join PortflioProject.covidvaccinations as vac 
 on dea.location= vac.location and dea.date = vac.date );
 
 select *,(RollingPeopleVaccinated/Population)*100 from portflioproject.percentagepopulationvaccinated;
 
 -- Create view to store data for later visulizations
 
 Create view PercentPopulationVaccinated as  
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(vac.new_vaccinations) over(partition by dea.location order by dea.location,dea.date) 
 as RollingPeopleVaccinated
 from portflioproject.coviddeaths as dea join PortflioProject.covidvaccinations as vac 
 on dea.location= vac.location and dea.date = vac.date where dea.continent is not null;
