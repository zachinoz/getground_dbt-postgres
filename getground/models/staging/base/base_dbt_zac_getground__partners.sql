{{ config(materialized='table') }}

with source_data as (
    select * from {{ source('dbt_zac_getground','partners')}}
),

transformed as (

    select 
        -- ids
        id as partner_id

        -- dimensions
        ,partner_type
        ,case when lead_sales_contact = '0'
            then null
            else lead_sales_contact
            end as lead_sales_contact
        
        -- date/times
        ,to_timestamp(created_at / 1000000000.0) as created_at
        ,to_timestamp(updated_at / 1000000000.0) as updated_at
    from source_data

)

select *
from transformed

/*
    - converted created_at and updated_at, original format being in unix nano
    - lead_sales_contact changed '0' to null as this will better inform users that there 
    isn't a value rather than assigning '0' 
*/
