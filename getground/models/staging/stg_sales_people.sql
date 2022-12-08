{{ config(
    materialized='table',
    indexes=[
        {'columns':['sales_person_name'], 'type':'btree', 'unique': True}
    ]) }}

with source_data as (
    select * from {{ source('dbt_zac_getground','sales_people')}}
),

renamed as (

    select name as sales_person_name
        ,country
    from source_data

)

select *
from renamed

/*
    Added an index to this as we would want there to be unique identifier for each sales_person, for many reasons eg. text name won't be feasible as number of persons increase, duplicate names, etc.
*/
