{{ config(materialized='table') }}

with partner_sales_people as (
    select * from {{ ref('stg_dbt_zac_getground__partners_sales_people')}}
),

referrals as (
    select * from {{ ref('base_dbt_zac_getground__referrals')}}
),

transformed as (

    select 
        -- ids
        referral_id
        ,company_id
        ,r.partner_id
        ,consultant_id
        ,lead_sales_contact

        -- dimensions
        ,lead_sales_country
        ,partner_type
        ,referral_status
        ,is_outbound

        -- date/time
        ,r.created_at
        ,r.updated_at
    from referrals r
    left join partner_sales_people p
        on r.partner_id = p.partner_id

)

select *
from transformed

/*
    - joined partner, sales people, to referrals table together to combine data across the three tables
*/