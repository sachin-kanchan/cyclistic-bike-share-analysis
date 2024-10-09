# Cyclistic Bike-Share Analysis: Detailed Project Documentation

## Table of Contents
1. [Introduction](#introduction)
2. [Business Task](#business-task)
3. [Data Sources](#data-sources)
4. [Methodology](#methodology)
5. [Analysis](#analysis)
6. [Key Findings](#key-findings)
7. [Recommendations](#recommendations)
8. [Limitations and Next Steps](#limitations-and-next-steps)

## Introduction
Cyclistic, a bike-share company in Chicago, aims to maximize annual memberships for future growth. This project analyzes how casual riders and annual members use Cyclistic bikes differently to inform marketing strategies for converting casual riders to members.

## Business Task
The primary task is to analyze Cyclistic's historical bike trip data to identify trends and patterns in usage behavior between annual members and casual riders.

## Data Sources
The analysis uses Cyclistic's trip data from March 2024 to August 2024, sourced from [Divvy Bikes](https://divvy-tripdata.s3.amazonaws.com/index.html). The data includes ride details such as start/end times, station information, and rider type (casual or member).

## Methodology
1. Data was imported into SQL Server for cleaning and analysis.
2. SQL queries were used to aggregate and analyze ride patterns. [View SQL queries](../sql/cyclistic_ride_analysis.sql)
3. Tableau was utilized for data visualization and dashboard creation. [View dashboard](../tableau/cyclistic_dashboard.png)

## Analysis
The analysis focused on several key areas:
1. Membership distribution and ride characteristics
2. Weekly usage patterns
3. Popular stations
4. Extreme usage cases

### Membership Distribution and Ride Characteristics
- 60.88% of rides are by annual members, 39.12% by casual riders
- Casual riders take longer trips (avg. 26.94 mins) compared to members (avg. 13.29 mins)

### Weekly Usage Patterns
- Weekdays dominated by member usage (up to 69.08% on Tuesdays)
- Weekends see increased casual rider usage (50.44% on Saturdays)

### Popular Stations
- "Streeter Dr & Grand Ave" identified as the busiest station

## Key Findings
1. Membership Advantage: 60.88% of rides are by annual members.
2. Usage Intensity: Casual riders take longer trips (avg. 26.94 mins) compared to members (avg. 13.29 mins).
3. Weekly Patterns: 
   - Weekdays dominated by member usage (up to 69.08% on Tuesdays)
   - Weekends see increased casual rider usage (50.44% on Saturdays)
4. Location Insights: High traffic at specific stations like "Streeter Dr & Grand Ave"

## Recommendations
1. Targeted Weekend Conversion Campaign
2. Introduce Tiered Membership Options
3. Location-Based Marketing

For a detailed presentation of findings and recommendations, please refer to our [presentation](../presentation/cyclistic_presentation.pdf).

## Limitations and Next Steps
- Weather data could be incorporated to understand its impact on ridership patterns.
- User surveys could provide qualitative insights into rider preferences and motivations.

Next steps include extending the analysis to a full year of data and potentially integrating weather and demographic data for a more comprehensive understanding of rider behavior.