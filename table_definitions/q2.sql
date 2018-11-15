-- Winners

SET SEARCH_PATH TO parlgov;
drop table if exists q2 cascade;

-- You must not change this table definition.

create table q2(
countryName VARCHaR(100),
partyName VARCHaR(100),
partyFamily VARCHaR(100),
wonElections INT,
mostRecentlyWonElectionId INT,
mostRecentlyWonElectionYear INT
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS WinningParty CASCADE;

CREATE VIEW WinningParty AS
SELECT er.election_id, e.e_date, er.party_id, p.name, c.name as countryName
FROM Election_result er, party p, country c, election e
WHERE er.votes >=ALL(
    SELECT er1.votes
    FROM Election_result er1
    WHERE er1.election_id = er.election_id AND er1.votes IS NOT NULL
) AND p.id = er.party_id AND e.id = er.election_id AND e.country_id = c.id;

DROP VIEW IF EXISTS Wincount CASCADE;

CREATE VIEW WinCount AS
SELECT w.party_id, w.countryName, count(*) as winNum
FROM WinningParty w
GROUP BY w.party_id, w.countryName;

DROP VIEW IF EXISTS EPCount CASCADE;

CREATE VIEW EPCount AS
SELECT p.country_id, count(DISTINCT e.id) as electionNum, count(DISTINCT p.id) as partyNum
FROM election e, party p
WHERE p.country_id = e.country_id
GROUP BY p.country_id;

DROP VIEW IF EXISTS Average CASCADE;

CREATE VIEW Average AS
SELECT c.name, (CAST(ep.electionNum AS FLOAT) / ep.partyNum) as Average
FROM EPCount ep, country c
WHERE ep.country_id = c.id;

DROP VIEW IF EXISTS ExcelParty CASCADE;

CREATE VIEW ExcelParty AS
SELECT w.party_id, w.countryName
FROM Wincount as w, Average as a
WHERE w.countryName = a.name AND w.winNum > 3 * a.Average;

DROP VIEW IF EXISTS ResultFamily CASCADE;

-- Combine with party family.
CREATE VIEW ResultFamily AS
SELECT ExcelParty.countryName, ExcelParty.party_id, Party_family.family
FROM ExcelParty LEFT JOIN Party_family ON ExcelParty.party_id = Party_family.party_id;

DROP ViEW IF EXISTS ResultRecent CASCADE;

-- Combine with the most recently won election Id and its election date.
CREATE VIEW ResultRecent AS
SELECT rf.countryName, rf.party_id, wp.name, rf.family, wp.election_id, wp.e_date
FROM ResultFamily as rf JOIN WinningParty as wp ON rf.party_id = wp.party_id
WHERE wp.e_date >= ALL(
    SELECT e_date 
    FROM WinningParty as wp2
    WHERE wp2.party_id = rf.party_id
);

DROP VIEW IF EXISTS Result CASCADE;

CREATE VIEW Result AS
SELECT wr.countryName, wr.name AS partyName, wr.family AS partyFamily, 
wc.winNum AS wonElections,
wr.election_id AS mostRecentlyWonElectionId, 
CAST(EXTRACT(YEAR FROM wr.e_date) AS INT) AS mostRecentlyWonElectionYear
FROM ResultRecent as wr, Wincount as wc
WHERE wr.party_id = wc.party_id;


-- Define views for your intermediate steps here.


-- the answer to the query 
insert into q2 (SELECT * FROM Result);




