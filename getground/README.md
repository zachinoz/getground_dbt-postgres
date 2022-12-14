## Questions and Exercises

All database processes were done with Postgres

1. Please insert the data provided as CSV into tables in an SQL database. Please include SQL queries used throughout the assignment.

Creating sql tables

```
-- partners table
CREATE TABLE IF NOT EXISTS dbt_zac_getground.partners (
   id integer,
   created_at numeric,
   updated_at numeric,
   partner_type text,
   lead_sales_contact text
);

-- sales_people table
CREATE TABLE IF NOT EXISTS dbt_zac_getground.sales_people (
   name text,
   country text
);

-- referrals table
CREATE TABLE IF NOT EXISTS dbt_zac_getground.referrals (
   id integer,
   created_at numeric,
   updated_at numeric,
   company_id integer,
   partner_id integer,
   consultant_id integer,
   status text,
   is_outbound integer
);
```

Loading data was done via sql query as well

```
-- partners
copy dbt_zac_getground.partners(
	id
	,created_at
	,updated_at
	,partner_type
	,lead_sales_contact)
FROM 'C:\Users\Zac\Downloads\GetGround_technical_task\partners.csv'
DELIMITER ','
CSV HEADER;

-- referrals
copy dbt_zac_getground.referrals(
	id
	,created_at
	,updated_at
	,company_id
	,partner_id
	,consultant_id
	,status
	,is_outbound)
FROM 'C:\Users\Zac\Downloads\GetGround_technical_task\referrals.csv'
DELIMITER ','
CSV HEADER;

-- sales_people
copy dbt_zac_getground.sales_people(
	name
	, country)
FROM 'C:\Users\Zac\Downloads\GetGround_technical_task\sales_people.csv'
DELIMITER ','
CSV HEADER;
```

2. Use dbt to pre-precess the data and output dbt models for analysis. Include appropriate data quality tests and documentation.

dbt log file link [here](https://github.com/zachinoz/getground_dbt-postgres/blob/1f803031e5e2073cb61200c5d8f4943576d077f7/logs/dbt.log)

3. Analyse the data using SQL. Be sure to include your investigative thought process, findings, limitations, and assumptions.

**Thought Process**

My first thought was investigating gaps in data, so looking at the zero values in partner table for example. It wasn't until I created the staging partner and sales people tables in dbt, and finally the model in marts which combined all three tables that highlighted the gaps in data.

**Findings**

Notably, lead sales contact/sales person 'Potato' does not have a country or entry in the sales_people table. If we apply this to the joint referral_partner_sales dbt table, it results in almost 25% of country data missing.

```
    with total as (
    select
        max(referral_id) as total
    from source.dbt_zac_getground__referrals_partners_sales_people
    )
    select
        lead_sales_country
        ,count(*) as ref_count
        ,round(count(*)*100.0/total.total,2) as ref_percent
    from source.dbt_zac_getground__referrals_partners_sales_people,total
    group by lead_sales_country,total
```        

'Potato' did not have a record in the sales_persons table, despite holding over 20% of the partner key accounts as seen in this query:

```
    with total as (
            select
                count(*) as total
            from source.stg_dbt_zac_getground__partners_sales_people
            )
    select
        lead_sales_contact
        ,count(*) as partner_count
        ,round(count(*)*100.0/total.total,2) as partner_percent
    from source.stg_dbt_zac_getground__partners_sales_people,total
    group by lead_sales_contact,total
```

And over 15% of total consultants managed when applying it to joint dbt table dbt_zac_getground__referrals_partners_sales_people

```
    with total as (
            select
                count(consultant_id) as total
            from source.dbt_zac_getground__referrals_partners_sales_people
            )
    select
        lead_sales_contact
        ,count(consultant_id) as consultant_count
        ,round(count(*)*100.0/total.total,2) as consultant_percent
    from source.dbt_zac_getground__referrals_partners_sales_people,total
    group by lead_sales_contact,total
```

Following on from this, we can also apply the same query to the partner and sales people joint dbt table and see almost 22% of partners table is missing country data

```
    with total as (
            select
                count(*) as total
            from source.stg_dbt_zac_getground__partners_sales_people
            )
    select
        lead_sales_country
        ,count(*) as partner_count
        ,round(count(*)*100.0/total.total,2) as partner_percent
    from source.stg_dbt_zac_getground__partners_sales_people,total
    group by lead_sales_country,total
```

Combining country and referral status shows a spread of referral status that are missing country data, ranging from 2%(disinterest) to almost 16% (successful) of data missing.

```
with total as (
            select
                count(*) as total
            from source.dbt_zac_getground__referrals_partners_sales_people
            )
select
	count(*) referral_count
	,round(count(*)*100.0/total.total,2) as referral_percent
	,referral_status
	,lead_sales_country
from source.dbt_zac_getground__referrals_partners_sales_people,total
group by referral_status,lead_sales_country,total
order by referral_status,referral_count desc
```

With is_outbound field, we can see over 7% of upsells are missing country data, while over 16% in 'not an upsell' are missing country data.

```
    with total as (
                select
                    count(*) as total
                from source.dbt_zac_getground__referrals_partners_sales_people
                )
    select
        count(*) outbound_count
        ,round(count(*)*100.0/total.total,2) as outbound_percent
        ,is_outbound
        ,lead_sales_country
    from source.dbt_zac_getground__referrals_partners_sales_people,total
    group by is_outbound,lead_sales_country,total
    order by is_outbound,outbound_count desc
```
Partner_id 7 had the highest number of successful referrals, with almost 16% of total successful referrals attributed to them.

```
    with total as (
                    select
                        count(*) as total
                    from source.dbt_zac_getground__referrals_partners_sales_people
                    )
    select 
        count(*) as n_successful_ref
        ,round(count(*)*100.0/total.total,2) as success_ref_percent
        ,partner_id
    from source.dbt_zac_getground__referrals_partners_sales_people,total
    where referral_status = 'successful'
    group by partner_id,total
    order by n_successful_ref desc
```

We can also breakdown referral status rates within each partner, and see with partner_id 7, they have over 92% success rate with their referrals which is pretty good when considering their total referral share is 16% (n = 253)

```
    select 
        partner_id
        ,referral_status
        ,count(*) n_referrals
        ,round(COUNT(*) * 100 / SUM(count(*)) over (partition by partner_id),2) as percent
    from source.dbt_zac_getground__referrals_partners_sales_people
    group by partner_id,referral_status
    order by partner_id,percent desc
```

**Limitations**

A limitation that seemed evident to me was the sales people table, it relied on names instead of an id like the other two tables which I think should have an index applied for multiple reasons, a unique id would be far more practical than using names, and would eliminate issues like multiplicate names, easier joins and querying for particular people etc.

I did try to implement this in the base_dbt_zac_getground__sales_people.sql file but couldn't figure out why dbt wasnt building it in the log file.

Another limitation is determining customer numbers rather than just referrals, I think having a customer table would be useful here to see the referral to customer ratio to ascertain the value of each referral.

**Assumptions**

A major assumption is that there is no duplicate rows in referral and partner data tables, based on unique index and timestamps in created_at field.

This would be tied to the customer table mentioned in Limitations, as it would help breakdwon each referral further.

4. Based on your analysis, how would you reccomend GG improve the quality of the analyses we can deliver.

- Address missing data where its feasible to correct, for example sales person 'Potato' and their country

- Include an index to provide a unique id for each of the sales persons to avoid use of their name due to reasons highlighted in limitations

- Check the indexing/id allocation of partners and company ids

- Applying the renaming conventions used in the sql files of base folder to minimise confusion between which table an id belonged to
  
- Partners table starts with an ID of 2, instead of 1, which I'm not sure if its by design, but changing it to start at 1 would mean changing all the partner id's in the referral tables as well

- Company_id starts at 0, so these inconsistencies should be addressed ideally to ensure standardisation of unique identification numbers across the datasets 