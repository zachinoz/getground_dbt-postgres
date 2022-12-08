{{ config(materialized='table') }}

with partners as (
    select * from {{ ref('base_dbt_zac_getground__partners')}}
),

sales_people as (
    select * from {{ ref('base_dbt_zac_getground__sales_people')}}
),

transformed as (

    select 
        -- ids
        partner_id

        -- dimensions
        ,partner_type
        ,lead_sales_contact
        ,country as lead_sales_country
        
        -- date/times
        ,created_at
        ,updated_at
    from partners p
    left join sales_people s
        on p.lead_sales_contact = s.sales_person_name

)

select *
from transformed

/*
    - joined partner and sales people tables together so you can query country along with lead contact persons name
*/