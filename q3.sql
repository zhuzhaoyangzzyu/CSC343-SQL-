-- Participate

SET SEARCH_PATH TO parlgov;
drop table if exists q3 cascade;

-- You must not change this table definition.

create table q3(
        countryName varchar(50),
        year int,
        participationRatio real
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS participation_ratio CASCADE;
DROP VIEW IF EXISTS all_country CASCADE;
DROP VIEW IF EXISTS decrease CASCADE;
-- Define views for your intermediate steps here.
CREATE VIEW participation_ratio as SELECT id,(1.0 * votes_cast/electorate) as part_ratio FROM election;
CREATE VIEW all_country as SELECT country.name as country_name, AVG(part_ratio) as average_part_ratio, DATE_PART('year', election.e_date) AS year FROM country JOIN election on election.country_id = country.id JOIN participation_ratio on participation_ratio.id = election.id where e_date >= '2001-01-01' AND e_date <= '2016-12-31' GROUP BY country.name, year;
CREATE VIEW decrease as SELECT DISTINCT c1.country_name FROM (SELECT * FROM all_country WHERE average_part_ratio IS NOT NULL) AS c1 WHERE EXISTS (SELECT * FROM (SELECT * FROM all_country WHERE average_part_ratio IS NOT NULL) AS c2 WHERE c1.country_name = c2.country_name AND c1.year < c2.year AND c1.average_part_ratio > c2.average_part_ratio);
CREATE VIEW never_decrease as SELECT * FROM all_country WHERE country_name IN ((SELECT DISTINCT country_name FROM all_country) EXCEPT (SELECT * FROM decrease));
-- the answer to the query 
insert into q3 (countryName, year, participationRatio) SELECT country_name, year, average_part_ratio FROM all_country WHERE country_name IN ((SELECT DISTINCT country_name FROM all_country) EXCEPT (SELECT * FROM decrease))

