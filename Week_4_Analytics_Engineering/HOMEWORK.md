## Module 4 Homework 

In this homework, we'll use the models developed during the week 4 videos and enhance the already presented dbt project using the already loaded Taxi data for fhv vehicles for year 2019 in our DWH.

This means that in this homework we use the following data [Datasets list](https://github.com/DataTalksClub/nyc-tlc-data/)
* Yellow taxi data - Years 2019 and 2020
* Green taxi data - Years 2019 and 2020 
* fhv data - Year 2019. 

We will use the data loaded for:

* Building a source table: `stg_fhv_tripdata`
* Building a fact table: `fact_fhv_trips`
* Create a dashboard 

If you don't have access to GCP, you can do this locally using the ingested data from your Postgres database
instead. If you have access to GCP, you don't need to do it for local Postgres - only if you want to.

> **Note**: if your answer doesn't match exactly, select the closest option 

### Question 1: 

**What happens when we execute dbt build --vars '{'is_test_run':'true'}'**
You'll need to have completed the ["Build the first dbt models"](https://www.youtube.com/watch?v=UVI30Vxzd6c) video. 
- It's the same as running *dbt build*
- It applies a _limit 100_ to all of our models
- It applies a _limit 100_ only to our staging models
- Nothing

### Question 2: 

**What is the code that our CI job will run? Where is this code coming from?**  

- The code that has been merged into the main branch
- The code that is behind the creation object on the dbt_cloud_pr_ schema
- The code from any development branch that has been opened based on main
- The code from the development branch we are requesting to merge to main


### Question 3 (2 points)

**What is the count of records in the model fact_fhv_trips after running all dependencies with the test run variable disabled (:false)?**  
Create a staging model for the fhv data, similar to the ones made for yellow and green data. Add an additional filter for keeping only records with pickup time in year 2019.
Do not add a deduplication step. Run this models without limits (is_test_run: false).

Create a core model similar to fact trips, but selecting from stg_fhv_tripdata and joining with dim_zones.
Similar to what we've done in fact_trips, keep only records with known pickup and dropoff locations entries for pickup and dropoff locations. 
Run the dbt model without limits (is_test_run: false).

- 12998722
- 22998722
- 32998722
- 42998722

### Question 4 (2 points)

**What is the service that had the most rides during the month of July 2019 month with the biggest amount of rides after building a tile for the fact_fhv_trips table?**

Create a dashboard with some tiles that you find interesting to explore the data. One tile should show the amount of trips per month, as done in the videos for fact_trips, including the fact_fhv_trips data.

- FHV
- Green
- Yellow
- FHV and Green


## Submitting the solutions

* Form for submitting: https://courses.datatalks.club/de-zoomcamp-2024/homework/hw4

Deadline: 22 February (Thursday), 22:00 CET


## Solution (To be published after deadline)

* Video: 
* Answers:
  * Question 1: 
  * Question 2: 
  * Question 3: 
  * Question 4:
 
  * Prep queries from Week 4 assignment
 ----------------------------------------Table creation and load green_tripdata--------------------------------------------------------
-- Create a non partitioned green_tripdata table from google public dataset table tlc_green_trips_2019
CREATE OR REPLACE TABLE dw-bigquery-week-3.trips_data_all.green_tripdata AS
SELECT * FROM `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2019`;

-- Check count(*) of newly created green_tripdata-->6300974
select count(*)
from dw-bigquery-week-3.trips_data_all.green_tripdata;

-- Insert data from tlc_green_trips_2020-->green_tripdata
insert into dw-bigquery-week-3.trips_data_all.green_tripdata
SELECT * FROM `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2020`;

-- Check count(*) of green_tripdata after inserting 2020 data-->8035139
select count(*)
from dw-bigquery-week-3.trips_data_all.green_tripdata;

----------------------------------------Table creation and load yellow_tripdata--------------------------------------------------------
-- Create a non partitioned yellow_tripdata table from google public dataset table tlc_yellow_trips_2019
CREATE OR REPLACE TABLE dw-bigquery-week-3.trips_data_all.yellow_tripdata AS
SELECT * FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2019`;

-- Check count(*) of newly created yellow_tripdata-->84598433
select count(*)
from dw-bigquery-week-3.trips_data_all.yellow_tripdata;

-- Insert data from tlc_yellow_trips_2020-->yellow_tripdata
insert into dw-bigquery-week-3.trips_data_all.yellow_tripdata
SELECT * FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2020`;

-- Check count(*) of yellow_tripdata after inserting 2020 data--->109247514
select count(*)
from dw-bigquery-week-3.trips_data_all.yellow_tripdata;

---------------------------------------------------------Alter column names to match the expected value for dbt project input----------------------
  -- Fixes green table schema
ALTER TABLE `dw-bigquery-week-3.trips_data_all.green_tripdata`
  RENAME COLUMN vendor_id TO VendorID;
ALTER TABLE `dw-bigquery-week-3.trips_data_all.green_tripdata`
  RENAME COLUMN pickup_datetime TO lpep_pickup_datetime;
ALTER TABLE `dw-bigquery-week-3.trips_data_all.green_tripdata`
  RENAME COLUMN dropoff_datetime TO lpep_dropoff_datetime;
ALTER TABLE `dw-bigquery-week-3.trips_data_all.green_tripdata`
  RENAME COLUMN rate_code TO RatecodeID;
ALTER TABLE `dw-bigquery-week-3.trips_data_all.green_tripdata`
  RENAME COLUMN imp_surcharge TO improvement_surcharge;
ALTER TABLE `dw-bigquery-week-3.trips_data_all.green_tripdata`
  RENAME COLUMN pickup_location_id TO PULocationID;
ALTER TABLE `dw-bigquery-week-3.trips_data_all.green_tripdata`
  RENAME COLUMN dropoff_location_id TO DOLocationID;

  -- Fixes yellow table schema
ALTER TABLE `dw-bigquery-week-3.trips_data_all.yellow_tripdata`
  RENAME COLUMN vendor_id TO VendorID;
ALTER TABLE `dw-bigquery-week-3.trips_data_all.yellow_tripdata`
  RENAME COLUMN pickup_datetime TO tpep_pickup_datetime;
ALTER TABLE `dw-bigquery-week-3.trips_data_all.yellow_tripdata`
  RENAME COLUMN dropoff_datetime TO tpep_dropoff_datetime;
ALTER TABLE `dw-bigquery-week-3.trips_data_all.yellow_tripdata`
  RENAME COLUMN rate_code TO RatecodeID;
ALTER TABLE `dw-bigquery-week-3.trips_data_all.yellow_tripdata`
  RENAME COLUMN imp_surcharge TO improvement_surcharge;
ALTER TABLE `dw-bigquery-week-3.trips_data_all.yellow_tripdata`
  RENAME COLUMN pickup_location_id TO PULocationID;
ALTER TABLE `dw-bigquery-week-3.trips_data_all.yellow_tripdata`
  RENAME COLUMN dropoff_location_id TO DOLocationID;

  
-- Creating external table referring to gcs path where I have uploaded parquet file downloaded from https://d37ci6vzurychx.cloudfront.net/trip-data/fhv_tripdata_2019-*.parquet


-----Correct load with schema defination----will not throw error----------------------
CREATE OR REPLACE EXTERNAL TABLE `dw-bigquery-week-3.trips_data_all.external_tlc_fhv_trips_2019` (
    dispatching_base_num STRING,
    pickup_datetime TIMESTAMP,
    dropoff_datetime TIMESTAMP,
    PUlocationID FLOAT64,
    DOlocationID FLOAT64,
    SR_Flag INT64,
    Affiliated_base_number STRING
)
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://dw-bigquery-week-3-bq1/fhv_tripdata_2019-*.parquet']
);

---Errornous load--will throw error while creating the landing tables-------------------------
CREATE OR REPLACE EXTERNAL TABLE `dw-bigquery-week-3.trips_data_all.external_tlc_fhv_trips_2019`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://dw-bigquery-week-3-bq1/fhv_tripdata_2019-01.parquet']);

-- Create a non partitioned fhv_tripdata table from external table fhv_green_trips_2019
CREATE OR REPLACE TABLE dw-bigquery-week-3.trips_data_all.fhv_tripdata 
(
    dispatching_base_num STRING,
    pickup_datetime TIMESTAMP,
    dropoff_datetime TIMESTAMP,
    PUlocationID FLOAT64,
    DOlocationID FLOAT64,
    SR_Flag FLOAT64,
    Affiliated_base_number STRING
) AS
SELECT * FROM `dw-bigquery-week-3.trips_data_all.external_tlc_fhv_trips_2019`;

-- Check count(*) of newly created fhv_tripdata_2019_01-->23159064
select count(1)
from dw-bigquery-week-3.trips_data_all.fhv_tripdata;

CREATE OR REPLACE EXTERNAL TABLE `dw-bigquery-week-3.trips_data_all.external_tlc_fhv_trips_2019`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://dw-bigquery-week-3-bq1/fhv_tripdata_2019-12.parquet']);


-- Insert data from external table fhv_green_trips_2019-->fhv_tripdata
insert into dw-bigquery-week-3.trips_data_all.fhv_tripdata
SELECT * FROM `dw-bigquery-week-3.trips_data_all.external_tlc_fhv_trips_2019`;

-- Check count(*) of newly created fhv_tripdata_2019_01-->23159064
-- Check count(*) of newly created fhv_tripdata_2019_02-->24866714
-- Check count(*) of newly created fhv_tripdata_2019_03-->26342283
-- Check count(*) of newly created fhv_tripdata_2019_04-->28280133
-- Check count(*) of newly created fhv_tripdata_2019_05-->30353178
-- Check count(*) of newly created fhv_tripdata_2019_06-->32363066
-- Check count(*) of newly created fhv_tripdata_2019_07-->34310809
-- Check count(*) of newly created fhv_tripdata_2019_08-->36191217
-- Check count(*) of newly created fhv_tripdata_2019_09-->37439737
-- Check count(*) of newly created fhv_tripdata_2019_10-->39337593
-- Check count(*) of newly created fhv_tripdata_2019_11-->41217080
-- Check count(*) of newly created fhv_tripdata_2019_12-->43261276
select count(1)
from dw-bigquery-week-3.trips_data_all.fhv_tripdata;



