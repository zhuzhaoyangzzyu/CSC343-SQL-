Retrieve the parties that have won more than three times the average number of elections won by the parties
in the same country. List the country name, party name, its party family name as well as the total number
of elections won, as well as the id and the year of the most recently won election.



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
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS most_votes CASCADE;
DROP VIEW IF EXISTS winning_parties CASCADE;
DROP VIEW IF EXISTS country_ave CASCADE;
DROP VIEW IF EXISTS result_parties CASCADE;
DROP VIEW IF EXISTS result_parties_id CASCADE;
-- Define views for your intermediate steps here.
CREATE VIEW most_votes AS SELECT MAX(votes) as max_vote,election_id FROM election_result GROUP BY election_id;
CREATE VIEW winning_parties AS SELECT party_id,count(party_id) AS winnings,max(e_date) AS recent_date FROM most_votes, election_result, election WHERE most_votes.election_id = election_result.election_id  AND election.id = election_result.election_id AND votes = max_vote GROUP BY party_id;
CREATE VIEW country_ave AS SELECT country.name, avg(winnings) AS ave_winnings FROM winning_parties, party, country WHERE winning_parties.party_id = party.id AND party.country_id = country.id GROUP BY country.name;
CREATE VIEW result_parties AS SELECT DISTINCT winning_parties.party_id, winning_parties.recent_date, winning_parties.winnings FROM winning_parties,country_ave WHERE winning_parties.winnings > 3 * country_ave.ave_winnings;
CREATE VIEW result_parties_id AS SELECT DISTINCT result_parties.party_id, DATE_PART('year',result_parties.recent_date) AS recent_year, result_parties.winnings, election.id AS recent_id FROM result_parties, party, election WHERE result_parties.party_id = party.id AND result_parties.recent_date = election.e_date AND party.country_id = election.country_id;

-- the answer to the query 
insert into q2 (countryName, partyName, partyFamily, wonElections, mostRecentlyWonElectionId, mostRecentlyWonElectionYear) SELECT DISTINCT country.name, party.name, party_family.family,result_parties_id.winnings,result_parties_id.recent_id, result_parties_id.recent_year FROM result_parties_id LEFT OUTER JOIN party ON result_parties_id.party_id = party.id LEFT OUTER JOIN country ON party.country_id = country.id LEFT OUTER JOIN party_family ON party.id = party_family.party_id;

