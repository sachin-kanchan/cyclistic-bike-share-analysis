-- These steps and queries are for Microsoft SQL Server
-- PROCESS PHASE --------------------------------------------------------------------------------------

-- Use database
USE <database_name>;

-- Load CSV containing last 6 months data into schema, name the table as 'rides_backup'
-- For lats & lng - Select Decimal(18,10) datatype

SELECT * FROM rides_backup;

-- Count total rows, unique ride IDs, and duplicates in the backup table
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT ride_id) AS unique_ride_ids,
    COUNT(*) - COUNT(DISTINCT ride_id) AS duplicates
FROM rides_backup;

select top 5 * from rides_backup order by started_at, ended_at;

-- Step 1: Create a CTE to find unique rows based on ride_id
-- Step 2: Create the 'rides_temp' table with unique rows, ordered by started_at and ended_at
DROP TABLE IF EXISTS rides_temp;
WITH cte AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY ride_id ORDER BY started_at, ended_at) AS row_num
    FROM rides_backup
)
SELECT *
INTO rides_temp
FROM cte
WHERE row_num = 1  -- Select only unique rows
ORDER BY started_at, ended_at; 


-- Check the first 100 rows of the new temporary table
SELECT TOP 100 *
FROM rides_temp
ORDER BY started_at, ended_at;


-- Remove the 'row_num' column as it's no longer needed
ALTER TABLE rides_temp
DROP COLUMN row_num;


-- Verify the data in the temporary table
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT ride_id) AS unique_ride_ids,
    COUNT(*) - COUNT(DISTINCT ride_id) AS duplicates
FROM rides_temp;


-- Display information about the temporary table
EXEC sp_help 'rides_temp';


-- Check for records where Started At time > End At time
SELECT count(*) FROM rides_temp
WHERE started_at > ended_at;


-- Create the 'rides' table that we will be working on, with additional calculated columns
DROP TABLE IF EXISTS rides;
SELECT 
    *,
    DATEDIFF(SECOND, started_at, ended_at) AS ride_length_seconds,
    CAST(DATEDIFF(SECOND, started_at, ended_at) / 3600 AS VARCHAR) + ':' +  -- Total hours
    RIGHT('0' + CAST((DATEDIFF(SECOND, started_at, ended_at) % 3600) / 60 AS VARCHAR), 2) + ':' +  -- Total minutes
    RIGHT('0' + CAST(DATEDIFF(SECOND, started_at, ended_at) % 60 AS VARCHAR), 2) AS ride_length,  -- Total seconds
    DATEPART(WEEKDAY, started_at) AS day_of_week,
    DATENAME(WEEKDAY, started_at) AS day_name
INTO rides  -- Create the new table
FROM 
    rides_temp
WHERE started_at < ended_at 
ORDER BY
    started_at, ended_at;

/*
-- This query is for converting to Time data type instead of VARCHAR as shown above, 
-- But Time has its limitations since only 24 hours in day, whereas ride lengths in dataset go beyond 24 hours
SELECT 
    *,
    DATEDIFF(SECOND, started_at, ended_at) AS ride_length_seconds,  -- Store total seconds
    -- Convert seconds to TIME format for ride_length
    CAST(DATEADD(SECOND, DATEDIFF(SECOND, started_at, ended_at), '00:00:00') AS TIME) AS ride_length,  
    DATEPART(WEEKDAY, started_at) AS day_of_week,
    DATENAME(WEEKDAY, started_at) AS day_name
INTO rides  -- Create the new table
FROM 
    rides_temp
WHERE started_at < ended_at 
ORDER BY
    started_at, ended_at;
*/

DROP TABLE rides_temp;

SELECT COUNT(ride_id) AS total_rides
FROM rides;

SELECT TOP 5 * 
FROM rides;

-- Null check

SELECT 
    SUM(CASE WHEN ride_id IS NULL THEN 1 ELSE 0 END) AS null_ride_id,
    SUM(CASE WHEN rideable_type IS NULL THEN 1 ELSE 0 END) AS null_rideable_type,
    SUM(CASE WHEN started_at IS NULL THEN 1 ELSE 0 END) AS null_started_at,
    SUM(CASE WHEN ended_at IS NULL THEN 1 ELSE 0 END) AS null_ended_at,
    SUM(CASE WHEN start_station_name IS NULL THEN 1 ELSE 0 END) AS null_start_station_name,
    SUM(CASE WHEN start_station_id IS NULL THEN 1 ELSE 0 END) AS null_start_station_id,
    SUM(CASE WHEN end_station_name IS NULL THEN 1 ELSE 0 END) AS null_end_station_name,
    SUM(CASE WHEN end_station_id IS NULL THEN 1 ELSE 0 END) AS null_end_station_id,
    SUM(CASE WHEN start_lat IS NULL THEN 1 ELSE 0 END) AS null_start_lat,
    SUM(CASE WHEN start_lng IS NULL THEN 1 ELSE 0 END) AS null_start_lng,
    SUM(CASE WHEN end_lat IS NULL THEN 1 ELSE 0 END) AS null_end_lat,
    SUM(CASE WHEN end_lng IS NULL THEN 1 ELSE 0 END) AS null_end_lng,
    SUM(CASE WHEN member_casual IS NULL THEN 1 ELSE 0 END) AS null_member_casual,
    SUM(CASE WHEN ride_length_seconds IS NULL THEN 1 ELSE 0 END) AS null_ride_length_seconds,
    SUM(CASE WHEN ride_length IS NULL THEN 1 ELSE 0 END) AS null_ride_length,
    SUM(CASE WHEN day_of_week IS NULL THEN 1 ELSE 0 END) AS null_day_of_week
FROM rides;


-- Add a primary key constraint to ensure uniqueness of ride_id
ALTER TABLE rides
ADD CONSTRAINT pk_ride_id PRIMARY KEY (ride_id);

-- Create non-clustered indexes for improved query performance

CREATE NONCLUSTERED INDEX idx_started_at ON rides(started_at);
CREATE NONCLUSTERED INDEX idx_ended_at ON rides(ended_at);
CREATE NONCLUSTERED INDEX idx_ride_length ON rides(ride_length);
CREATE NONCLUSTERED INDEX idx_ride_length_seconds ON rides(ride_length_seconds);

CREATE NONCLUSTERED INDEX idx_rideable_type ON rides(rideable_type);
CREATE NONCLUSTERED INDEX idx_member_casual ON rides(member_casual);

-- Display information about the rides table that we will be working on
EXEC sp_help 'rides';


-- Check the rides with the longest duration
SELECT *
FROM rides
ORDER BY ride_length_seconds DESC;

-- Check all rides ordered by start and end time
SELECT *
FROM rides
ORDER BY started_at, ended_at;


-- ANALYSIS --------------------------------------------------------------------------------------

-- Summary Data
-- Count the Total Number of Rows

SELECT COUNT(*) AS total_rides
FROM rides;

-- o/p - 3540761


-- Distinct Values of rideable_type

SELECT DISTINCT rideable_type
FROM rides;

-- output - classic_bike, electric_bike


-- Minimum, Maximum, and Average Ride Length in Minutes

SELECT 
    CAST(ROUND(MIN(ride_length_seconds / 60.0), 2) AS FLOAT) AS min_ride_length_minutes,
    CAST(ROUND(MAX(ride_length_seconds / 60.0), 2) AS FLOAT) AS max_ride_length_minutes,
    CAST(ROUND(AVG(ride_length_seconds / 60.0), 2) AS FLOAT) AS avg_ride_length_minutes
FROM rides;

-- min_ride_length_minutes - 0.02 minutes
-- max_ride_length_minutes - 1559.93 minutes
-- avg_ride_length_minutes - 18.63 minutes


-- Descriptive Analysis
-- Daywise Frequency of rides
SELECT 
	day_of_week,
	day_name,
	COUNT(*) as frequency
FROM rides
GROUP BY day_of_week, day_name
ORDER BY day_of_week;


-- Pivoted Analysis

-- Aggregate ride data by membership type: user counts, percentage distribution, and average ride lengths.

WITH ride_counts AS (
    SELECT 
        member_casual,
        COUNT(*) AS ride_count,
        CAST(ROUND(AVG(ride_length_seconds / 60.0), 2) AS FLOAT) AS avg_ride_length_minutes
    FROM rides
    GROUP BY member_casual
)
SELECT 
    member_casual,
    ride_count,
	CAST(ROUND(100.0 * ride_count / (SELECT SUM(ride_count) FROM ride_counts), 2) AS FLOAT) AS ride_percentage,
    avg_ride_length_minutes
FROM 
    ride_counts
ORDER BY 
    ride_count DESC;


-- Daily ride counts and percentages by membership type (casual and member) for each day of the week.

SELECT
    day_of_week,
    day_name,
    COUNT(CASE WHEN member_casual = 'member' THEN 1 END) AS member_rides,
    COUNT(CASE WHEN member_casual = 'casual' THEN 1 END) AS casual_rides,
    CAST(ROUND(COUNT(CASE WHEN member_casual = 'member' THEN 1 END) * 100.0 / COUNT(*), 2) AS FLOAT) AS member_ride_percent,
    CAST(ROUND(COUNT(CASE WHEN member_casual = 'casual' THEN 1 END) * 100.0 / COUNT(*), 2) AS FLOAT) AS casual_ride_percent
FROM rides
GROUP BY day_of_week, day_name
ORDER BY day_of_week;


-- Average ride lengths by membership type for each day of the week.

SELECT 
    day_of_week,
    day_name,
    CAST(ROUND(AVG(CASE WHEN member_casual = 'member' THEN ride_length_seconds / 60.0 END), 2) AS FLOAT) AS member_avg_ride_length_minutes,
    CAST(ROUND(AVG(CASE WHEN member_casual = 'casual' THEN ride_length_seconds / 60.0 END), 2) AS FLOAT) AS casual_avg_ride_length_minutes
FROM 
    rides
GROUP BY 
    day_of_week, day_name
ORDER BY 
    day_of_week;


-- Investigate Trends
-- Top 10 Stations by Number of Rides
SELECT 
	TOP 10
    start_station_name,
    COUNT(ride_id) AS ride_count
FROM rides
GROUP BY start_station_name
ORDER BY ride_count DESC;


-- Top 10 Longest Rides
SELECT 
	TOP 10 *
FROM rides
ORDER BY ride_length_seconds DESC;


-- Top 10 Longest Rides - smaller table
SELECT 
	TOP 10
	ride_id,
	start_station_name,
	end_station_name,
	ride_length,
	day_name
FROM rides
ORDER BY ride_length_seconds DESC;