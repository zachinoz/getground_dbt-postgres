{{ config(materialized='table') }}

with source_data as (
    select * from {{ source('dbt_zac_getground','referrals')}}
),

renamed as (

    select id as referral_id
        ,to_timestamp(created_at/1000000.0) as created_at_ts
        ,to_timestamp(updated_at/1000000.0) as updated_at_ts
        ,company_id
        ,partner_id
        ,consultant_id
        ,status as referral_status
        ,is_outbound 
    from source_data

)

select *
from renamed

/*
    Unsure if is_outbound should be converted from 1/0 to yes/no, would be easier for stakeholder understanding
*/
