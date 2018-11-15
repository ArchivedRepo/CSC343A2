-- Participate

SET SEARCH_PATH TO parlgov;
drop table if exists q3 cascade;

-- You must not change this table definition.

create table q3(
        countryName varchar(50),
        year int,
        participationRatio real
);

DROP VIEW IF EXISTS Ratio CASCADE;

CREATE VIEW Ratio AS
SELECT id, country_id, EXTRACT(YEAR FROM e_date) as year, (CAST(votes_cast AS FLOAT) / electorate) AS participationRatio
FROM Election
WHERE e_date >= '2001-01-01' AND e_date <= '2016-12-31';

DROP VIEW IF EXISTS YearAverage;

CREATE VIEW YearAverage AS
SELECT country_id, year, avg(participationRatio) as participationRatio
FROM Ratio
GROUP BY country_id, year;

DROP VIEW IF EXISTS NotSatisfy CASCADE;

CREATE VIEW NotSatisfy AS
SELECT DISTINCT ya1.country_id
FROM YearAverage ya1, YearAverage ya2
WHERE ya1.country_id = ya2.country_id AND 
ya1.year < ya2.year AND ya1.participationRatio > ya2.participationRatio;

DROP VIEW IF EXISTS Satisfy CASCADE;

CREATE VIEW Satisfy AS
(SELECT country_id
FROM Ratio) EXCEPT
(SELECT country_id FROM NotSatisfy);

DROP VIEW IF EXISTS Result CASCADE;

CREATE VIEW Result AS
SELECT country.name as countryName, YearAverage.year AS year,
YearAverage.participationRatio AS participationRatio
FROM Satisfy, YearAverage, country 
WHERE Satisfy.country_id = YearAverage.country_id AND country.id = Satisfy.country_id;

insert into q3 (SELECT * FROM Result); 

