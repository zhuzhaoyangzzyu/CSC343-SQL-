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
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS percentage CASCADE;
DROP VIEW IF EXISTS names CASCADE;
DROP VIEW IF EXISTS full_table CASCADE;

-- Define views for your intermediate steps here.
CREATE VIEW percentage AS SELECT election_result.party_id,AVG(1.0 * election_result.votes/election.votes_valid) AS percentage, DATE_PART('year',e_date) AS year FROM election,election_result WHERE election.id = election_result.election_id AND e_date >= '1996-01-01' AND e_date <= '2016-12-31' GROUP BY election_result.party_id, year; 
CREATE VIEW names AS SELECT party.name AS party_name, party.id,country.name AS country_name FROM party join country on party.country_id = country.id;
CREATE VIEW full_table AS SELECT names.party_name,names.country_name, percentage.percentage, percentage.year FROM percentage join names on names.id = percentage.party_id;
-- the answer to the query 
INSERT INTO q1 (year,countryName,voteRange,partyName) SELECT year,country_name,'(0-5]',party_name FROM full_table WHERE full_table.percentage <= 0.05 AND full_table.percentage > 0 AND EXISTS(SELECT year,country_name,'(0-5]',party_name FROM full_table WHERE full_table.percentage <= 0.05 AND full_table.percentage > 0);
INSERT INTO q1 (year,countryName,voteRange,partyName) SELECT year,country_name,'(5-10]',party_name FROM full_table WHERE full_table.percentage <= 0.1 AND full_table.percentage > 0.05 AND EXISTS(SELECT year,country_name,'(5-10]',party_name FROM full_table WHERE full_table.percentage <= 0.1 AND full_table.percentage > 0.05);
INSERT INTO q1 (year,countryName,voteRange,partyName) SELECT year,country_name,'(10-20]',party_name FROM full_table WHERE full_table.percentage <= 0.2 AND full_table.percentage > 0.1 AND EXISTS(SELECT year,country_name,'(10-20]',party_name FROM full_table WHERE full_table.percentage <= 0.2 AND full_table.percentage > 0.1);
INSERT INTO q1 (year,countryName,voteRange,partyName) SELECT year,country_name,'(20-30]',party_name FROM full_table WHERE full_table.percentage <= 0.3 AND full_table.percentage > 0.2 AND EXISTS(SELECT year,country_name,'(20-30]',party_name FROM full_table WHERE full_table.percentage <= 0.3 AND full_table.percentage > 0.2);
INSERT INTO q1 (year,countryName,voteRange,partyName) SELECT year,country_name,'(40-100]',party_name FROM full_table WHERE full_table.percentage > 0.4 AND EXISTS(SELECT year,country_name,'(40-100]',party_name FROM full_table WHERE full_table.percentage > 0.4);
