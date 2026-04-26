/*
  Project: AB_NYC_2019 Data Cleaning
  Section: Database & Table Schema
  Purpose: Initialize database and listings table structure
  */

-- DROP DATABASE IF EXISTS
DROP DATABASE IF EXISTS ab_nyc_2019;

-- CREATE FRESH DATABASE 
CREATE DATABASE ab_nyc_2019;
USE ab_nyc_2019;

-- DROP TABLE IF ALREADY EXISTS 
DROP TABLE IF EXISTS listings;

-- CREATE TABLE SCHEMA
CREATE TABLE listings (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    host_id INT,
    host_name VARCHAR(255),
    neighbourhood_group VARCHAR(50),
    neighbourhood VARCHAR(100),
    latitude DECIMAL(10,6),
    longitude DECIMAL(10,6),
    room_type VARCHAR(50),
    price INT,
    minimum_nights INT,
    number_of_reviews INT,
    last_review DATE,
    reviews_per_month DECIMAL(5,2),
    calculated_host_listings_count INT,
    availability_365 INT
);

USE ab_nyc_2019;

