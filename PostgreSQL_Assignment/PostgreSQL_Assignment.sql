-- create DATABASE  "conservation_db";




CREATE TABLE rangers (
    ranger_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    region VARCHAR(100) NOT NULL
);
DROP TABLE rangers;
INSERT INTO rangers (name, region) VALUES
('Alice Green', 'Northern Hills'),
('Bob White', 'River Delta'),
('Carol King', 'Mountain Range');



DROP TABLE species;
CREATE TABLE species (
    species_id SERIAL PRIMARY KEY,
    common_name VARCHAR(100) NOT NULL,
    scientific_name VARCHAR(150) NOT NULL,
    discovery_date DATE NOT NULL,
    conservation_status VARCHAR(50)
);

SELECT * from species;
SELECT * from rangers;
SELECT * from sightings;

CREATE TABLE sightings (
    sighting_id SERIAL PRIMARY KEY,
    species_id INT ,
    ranger_id INT ,
    location VARCHAR(100) ,
    sighting_time TIMESTAMP ,
    notes TEXT,
    FOREIGN KEY (ranger_id) REFERENCES rangers(ranger_id),
    FOREIGN KEY (species_id) REFERENCES species(species_id)
);
DROP Table sightings;

-- Insert rangers
INSERT INTO rangers (name, region) VALUES
('Alice Green', 'Northern Hills'),
('Bob White', 'River Delta'),
('Carol King', 'Mountain Range');

-- Insert species
INSERT INTO species (common_name, scientific_name, discovery_date, conservation_status) VALUES
('Snow Leopard', 'Panthera uncia', '1775-01-01', 'Endangered'),
('Bengal Tiger', 'Panthera tigris tigris', '1758-01-01', 'Endangered'),
('Red Panda', 'Ailurus fulgens', '1825-01-01', 'Vulnerable'),
('Asiatic Elephant', 'Elephas maximus indicus', '1758-01-01', 'Endangered');

-- Insert sightings
INSERT INTO sightings (species_id, ranger_id, location, sighting_time, notes) VALUES
(1, 1, 'Peak Ridge', '2024-05-10 07:45:00', 'Camera trap image captured'),
(2, 2, 'Bankwood Area', '2024-05-12 16:20:00', 'Juvenile seen'),
(3, 3, 'Bamboo Grove East', '2024-05-15 09:10:00', 'Feeding observed'),
(1, 2, 'Snowfall Pass', '2024-05-18 18:30:00', NULL);


--1 Register a new ranger with provided data with name = 'Derek Fox' and region = 'Coastal Plains'
INSERT INTO rangers (name, region) 
VALUES ('Derek Fox', 'Coastal Plains');


--2 Count unique species ever sighted.
SELECT COUNT(DISTINCT species_id) AS unique_species_count
FROM sightings;

3--Find all sightings where the location includes "Pass".
SELECT * 
FROM sightings
WHERE location ILIKE '%Pass%';

--4 Ranger Name & Total Sightings
SELECT rang.name, COUNT(sight.sighting_id) AS total_sightings
FROM rangers rang
LEFT JOIN sightings sight ON rang.ranger_id = sight.ranger_id
GROUP BY rang.name
ORDER BY rang.name;


--5 Species Never Sighted
SELECT s.common_name
FROM species s
LEFT JOIN sightings si ON s.species_id = si.species_id
WHERE si.sighting_id IS NULL;
 
--6  Most Recent 2 Sightings
SELECT sp.common_name, si.sighting_time, r.name
FROM sightings si
JOIN species sp ON si.species_id = sp.species_id
JOIN rangers r ON si.ranger_id = r.ranger_id
ORDER BY si.sighting_time DESC
LIMIT 2;
--7  Update Old Species to “Historic”

UPDATE species
SET conservation_status = 'Historic'
WHERE discovery_date < '1800-01-01';
--8  Label Time of Day
CREATE OR REPLACE FUNCTION get_time_of_day(timestamp) RETURNS text AS $$
BEGIN
    RETURN CASE 
        WHEN EXTRACT(HOUR FROM $1) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM $1) < 18 THEN 'Afternoon'
        ELSE 'Evening'
    END;
END;
$$ LANGUAGE plpgsql;

SELECT sighting_id, get_time_of_day(sighting_time) AS time_of_day
FROM sightings;

--9  Delete Rangers Without Sightings
DELETE FROM rangers
WHERE ranger_id NOT IN (
    SELECT DISTINCT ranger_id FROM sightings
);

