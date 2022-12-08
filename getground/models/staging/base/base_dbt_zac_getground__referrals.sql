{{ config(materialized='table') }}

with source_data as (
    select * from {{ source('dbt_zac_getground','referrals')}}
),

transformed as (

    select 
        -- ids
        id as referral_id
        ,company_id
        ,partner_id
        ,consultant_id

        -- dimensions
        ,status as referral_status
        ,is_outbound

        -- date/time
        ,to_timestamp(created_at / 1000000000.0) as created_at
        ,to_timestamp(updated_at / 1000000000.0) as updated_at
    from source_data

)

select *
from transformed

/*
    - converted created_at and updated_at, original format being in unix nano
*/
