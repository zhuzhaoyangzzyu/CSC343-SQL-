-- Left-right

SET SEARCH_PATH TO parlgov;
drop table if exists q4 cascade;

-- You must not change this table definition.


CREATE TABLE q4(
        countryName VARCHAR(50),
        r0_2 INT,
        r2_4 INT,
        r4_6 INT,
        r6_8 INT,
        r8_10 INT
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.
CREATE VIEW l0_2 AS SELECT party_id, '[0,2)' as position FROM party_position WHERE left_right >= 0 AND left_right < 2;
CREATE VIEW l2_4 AS SELECT party_id, '[2,4)' as position FROM party_position WHERE left_right >= 2 AND left_right < 4;
CREATE VIEW l4_6 AS SELECT party_id, '[4,6)' as position FROM party_position WHERE left_right >= 4 AND left_right < 6;
CREATE VIEW l6_8 AS SELECT party_id, '[6,8)' as position FROM party_position WHERE left_right >= 6 AND left_right < 8;
CREATE VIEW l8_10 AS SELECT party_id, '[8,10)' as position FROM party_position WHERE left_right >= 8 AND left_right < 10;
--CREATE VIEW final_table AS SELECT country.name, count(l0_2.position),count(l2_4.position),count(l4_6.position),count(l6_8.position),count(l8_10.position) FROM country LEFT JOIN party ON party.country_id = country.id LEFT JOIN l0_2 ON party.id = l0_2.party_id LEFT JOIN l2_4 ON -- party.id = l2_4.party_id LEFT JOIN l4_6 ON party.id = l4_6.party_id LEFT JOIN l6_8 ON party.id = l6_8.party_id LEFT JOIN l8_10 ON party.id = l8_10.party_id GROUP BY country.name;
-- the answer to the query 
INSERT INTO q4 (countryName, r0_2, r2_4, r4_6, r6_8, r8_10) SELECT country.name, count(l0_2.position),count(l2_4.position),count(l4_6.position),count(l6_8.position),count(l8_10.position) FROM country LEFT JOIN party ON party.country_id = country.id LEFT JOIN l0_2 ON party.id = l0_2.party_id LEFT JOIN l2_4 ON party.id = l2_4.party_id LEFT JOIN l4_6 ON party.id = l4_6.party_id LEFT JOIN l6_8 ON party.id = l6_8.party_id LEFT JOIN l8_10 ON party.id = l8_10.party_id GROUP BY country.name;
-- the answer to the query 



