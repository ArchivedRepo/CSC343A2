-- VoteRange

SET SEARCH_PATH TO parlgov;
drop table if exists q1 cascade;

-- You must not change this table definition.

create table q1(
year INT,
countryName VARCHAR(50),
voteRange VARCHAR(20),
partyName VARCHAR(100)
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS SupportRate CASCADE;

CREATE VIEW SupportRate AS
SELECT e.id, e.country_id, e.e_date, er.party_id, CAST(er.votes AS FLOAT)/e.votes_valid * 100 as support_rate
FROM election e JOIN election_result er ON e.id = er.election_id
WHERE e.e_date >= '1996-01-01' AND e.e_date <= '2016-12-31';

-- Define views for your intermediate steps here.
DROP VIEW IF EXISTS NameSupport CASCADE;

CREATE VIEW NameSupport AS
SELECT EXTRACT(YEAR FROM s.e_date) as year, c.name as countryName, p.name_short as partyName, s.support_rate
FROM country c, party p, SupportRate s
WHERE c.id = s.country_id and p.id = s.party_id;

DROP VIEW IF EXISTS NameSupportAvg CASCADE;

CREATE VIEW NameSupportAvg AS
SELECT year, countryName, partyName, avg(support_rate) as support_rate
FROM NameSupport
GROUP BY year, countryName, partyName;

DROP VIEW IF EXISTS Range0to5 CASCADE;

CREATE VIEW Range0to5 AS
SELECT year, countryName, '(0-5]' as voteRange, partyName
FROM NameSupportAvg
WHERE support_rate > 0 and support_rate <= 5;

DROP VIEW IF EXISTS Range5to10 CASCADE;

CREATE VIEW Range5to10 AS
SELECT year, countryName, '(5-10]' as voteRange, partyName
FROM NameSupportAvg
WHERE support_rate > 5 and support_rate <= 10;

DROP VIEW IF EXISTS Range10to20 CASCADE;

CREATE VIEW Range10to20 AS
SELECT year, countryName, '(10-20]' as voteRange, partyName
FROM NameSupportAvg
WHERE support_rate > 10 and support_rate <= 20;

DROP VIEW IF EXISTS Range20to30 CASCADE;

CREATE VIEW Range20to30 AS
SELECT year, countryName, '(20-30]' as voteRange, partyName
FROM NameSupportAvg
WHERE support_rate > 20 and support_rate <= 30;

DROP VIEW IF EXISTS Range30to40 CASCADE;

CREATE VIEW Range30to40 AS
SELECT year, countryName, '(30-40]' as voteRange, partyName
FROM NameSupportAvg
WHERE support_rate > 30 and support_rate <= 40;

DROP VIEW IF EXISTS RangeAbove40 CASCADE;

CREATE VIEW RangeAbove40 AS
SELECT year, countryName, '(40-100]' as voteRange, partyName
FROM NameSupportAvg
WHERE support_rate > 40;

-- the answer to the query 
insert into q1 ((SELECT * FROM Range0to5) 
UNION (SELECT * FROM Range5to10)
UNION (SELECT * FROM Range10to20) 
UNION (SELECT * FROM Range20to30)
UNION (SELECT * FROM Range30to40)
UNION (SELECT * FROM RangeAbove40));

