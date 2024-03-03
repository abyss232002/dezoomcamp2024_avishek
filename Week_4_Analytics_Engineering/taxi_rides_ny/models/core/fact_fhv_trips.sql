{{ config(materialized="table") }}

with
    trips_cleaned as (
        select *, 'FHV' as service_type from {{ ref("stg_fhv_tripdata") }}
    ),
    dim_zones as (select * from {{ ref("dim_zones") }} where borough != 'Unknown')
select
    trips_cleaned.tripid,
    trips_cleaned.service_type,
    trips_cleaned.pickup_locationid,
    pickup_zone.borough as pickup_borough,
    pickup_zone.zone as pickup_zone,
    trips_cleaned.dropoff_locationid,
    dropoff_zone.borough as dropoff_borough,
    dropoff_zone.zone as dropoff_zone,
    trips_cleaned.pickup_datetime,
    trips_cleaned.dropoff_datetime,
    trips_cleaned.dispatching_base_num,
    trips_cleaned.affiliated_base_number,
    trips_cleaned.sr_flag
from trips_cleaned
inner join
    dim_zones as pickup_zone on trips_cleaned.pickup_locationid = pickup_zone.locationid
inner join
    dim_zones as dropoff_zone
    on trips_cleaned.dropoff_locationid = dropoff_zone.locationid
