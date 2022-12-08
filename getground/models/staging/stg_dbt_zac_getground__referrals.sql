{{ config(materialized='table') }}

with source_data as (
    select * from {{ ref('base_dbt_zac_getground__referrals')}}
)

select *
from source_data

/*
    - converted created_at and updated_at, original format being in unix nano
*/
