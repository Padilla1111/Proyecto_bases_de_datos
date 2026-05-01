-- Creating raw schema

DROP SCHEMA IF EXISTS raw CASCADE;
CREATE SCHEMA IF NOT EXISTS raw;



-- Creating table for raw data

DROP TABLE IF EXISTS raw.chicago_crimes;
CREATE TABLE raw.chicago_crimes (
    case_number TEXT,         
    date_occurrence TEXT,     
    block TEXT,                
    iucr TEXT,               
    primary_description TEXT,  
    secondary_description TEXT, 
    location_description TEXT, 
    arrest TEXT,             
    domestic TEXT,          
    beat TEXT,                
    ward TEXT,               
    fbi_cd TEXT,               
    x_coordinate TEXT,       
    y_coordinate TEXT,         
    latitude TEXT,            
    longitude TEXT,           
    location TEXT             
);


-- Loading data from CSV file
\COPY raw.chicago_crimes (case_number, date_occurrence, block, iucr, primary_description, secondary_description, location_description, arrest, domestic, beat, ward, fbi_cd, x_coordinate, y_coordinate, latitude, longitude, location) FROM './data/raw_data.csv' WITH (FORMAT CSV, HEADER true, DELIMITER ',');