{{
    config(
        materialized='view'
    )
}}

with 
tripdata as (
    select *,
    row_number() over(partition by dispatching_base_num, pickup_datetime) as rn
    from {{ source('staging','fhv_tripdata') }}
    where dispatching_base_num is not null
),

renamed as (

    select
        -- identifier
        {{dbt_utils.generate_surrogate_key(['dispatching_base_num','pickup_datetime'])}} as tripid,
        {{dbt.safe_cast('dispatching_base_num', api.Column.translate_type('string'))}} as dispatching_base_num,
        {{dbt.safe_cast('pulocationid', api.Column.translate_type('integer'))}} as pickup_locationid,
        {{dbt.safe_cast('dolocationid', api.Column.translate_type('integer'))}} as dropoff_locationid,
        {{dbt.safe_cast('sr_flag', api.Column.translate_type('integer'))}} as sr_flag,
        {{dbt.safe_cast('affiliated_base_number', api.Column.translate_type('string'))}} as affiliated_base_number,
        -- timestamps
        TIMESTAMP(CAST(tripdata.pickup_datetime AS STRING)) AS pickup_datetime,
        TIMESTAMP(CAST(tripdata.dropoff_datetime AS STRING)) AS dropoff_datetime,
    from tripdata
    where (DATE(TIMESTAMP(CAST(tripdata.pickup_datetime AS STRING))) >= '2019-01-01' and DATE(TIMESTAMP(CAST(tripdata.pickup_datetime AS STRING))) <= '2019-12-31')
    and (tripdata.pulocationid is not NULL and tripdata.dolocationid is not NULL)
    -- where rn=1
)

select * from renamed

-- dbt build --select <model_name> --vars '{'is_test_run': 'false'}'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}
