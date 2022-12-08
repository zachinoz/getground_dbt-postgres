{{ config(materialized='table') }}

with source_data as (
    select * from {{ source('dbt_zac_getground','partners')}}
),

renamed as (

    select id as partner_id
        ,to_timestamp(created_at/1000000.0) as created_at_ts
        ,to_timestamp(updated_at/1000000.0) as updated_at_ts
        ,partner_type
        ,case when lead_sales_contact = '0'
            then null
            else lead_sales_contact
            end as lead_sales_contact
    from source_data

)

select *
from renamed

/*
    - not sure why partner id starts at 2, but if this is changed, would have to change where partner ids in other tables such as referrals
    - included case when for lead_sales as any records without a lead_sales_contact name results in 0 which could cause issue mixing data types so made it null instead as its easier to identify
*/
