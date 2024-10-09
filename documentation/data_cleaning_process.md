# Data Cleaning Process for Cyclistic Bike-Share Analysis

## Overview
This document outlines the data cleaning process for the Cyclistic bike-share analysis project. The goal was to prepare a clean, consistent dataset for analysis from the raw trip data.

## Data Source
- Original data: Cyclistic's historical trip data (March 2024 to August 2024)
- Format: CSV files

## Tools Used
- Microsoft SQL Server Management Studio

## Cleaning Steps

### 1. Data Import and Initial Review
- Imported CSV data into a table named 'rides_backup' in SQL Server
- Performed initial checks to review data structure and content

### 2. Duplicate Identification and Removal
- Created a new table 'rides_temp' containing only unique ride_id entries
- SQL Query:
  ```sql
  WITH cte AS (
      SELECT
          *,
          ROW_NUMBER() OVER (PARTITION BY ride_id ORDER BY started_at, ended_at) AS row_num
      FROM rides_backup
  )
  SELECT *
  INTO rides_temp
  FROM cte
  WHERE row_num = 1
  ORDER BY started_at, ended_at;
  ```
- Result: Removed 211 duplicate rows

### 3. Data Validation
- Checked for and removed rides where start time was later than end time
- SQL Query:
  ```sql
  SELECT COUNT(*) FROM rides_temp
  WHERE started_at > ended_at;
  ```
- Result: Removed 159 rows with invalid time entries

### 4. Feature Engineering
- Created a new table 'rides' with additional calculated columns
- Added columns:
  - ride_length_seconds: Duration of each ride in seconds
  - ride_length: Formatted ride duration in HH:MM:SS
  - day_of_week: Extracted day of the week for each ride's start time
  - day_name: Extracted name for the day of the week

### 5. Performance Optimization
- Created non-clustered indexes on frequently queried columns:
  - started_at
  - ended_at
  - ride_length
  - ride_length_seconds
  - rideable_type
  - member_casual

### 6. Final Data Verification
- Performed queries to check data reasonability, including longest rides and overall ride distribution

## Challenges and Solutions
- Challenge: Inconsistent datetime formats
  Solution: Standardized all datetime entries to a consistent format
- Challenge: Outlier rides (extremely long durations)
  Solution: Flagged rides over 24 hours for further investigation

## Summary of Data Processing
- Steps Taken to Clean the Data:
  1. Removed duplicate entries based on ride_id
  2. Ensured consistent data types across columns
  3. Created calculated fields for ride duration and day of the week
  4. Implemented a primary key constraint to maintain data integrity

- Data Cleaning Process Documentation:
  - Initial data stored in 'rides_backup' table
  - Duplicate rides identified and removed using ROW_NUMBER() function
  - Temporary table 'rides_temp' created with unique entries
  - Unnecessary columns dropped from 'rides_temp'
  - New 'rides' table created with additional calculated columns
  - Indexes added to optimize query performance

- Verification of Data Cleanliness:
  - Performed count queries to ensure no duplicates remained
  - Checked for null values in critical columns
  - Reviewed extreme values (e.g., longest rides) to identify potential data anomalies
  - Sorted data by various columns to visually inspect for inconsistencies

This process ensures that the data is clean, consistent, and optimized for the subsequent analysis phase. The steps taken have prepared a robust dataset that accurately represents the bike-share usage patterns, ready for in-depth analysis to answer the key business questions about differences between annual members and casual riders.