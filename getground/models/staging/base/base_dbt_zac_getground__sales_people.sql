{{ config(
    materialized='table',
    indexes=[
        {'columns':['sales_person_name', 'country'], 'type':'btree', 'unique': True}
    ]) }}

with source_data as (
    select * from {{ source('dbt_zac_getground','sales_people')}}
),

transformed as (

    select name as sales_person_name
        ,country
    from source_data

)

select *
from transformed

/*
    Added an index to this as we would want there to be unique identifier for each sales_person, for many reasons eg. text name won't be feasible as number of persons increase, duplicate names, etc.
*/
