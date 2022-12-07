-- loading data from each csv to each table
-- partners
copy source.partners(
	id
	,created_at
	,updated_at
	,partner_type
	,lead_sales_contact)
FROM 'C:\Users\Zac\Downloads\GetGround_technical_task\partners.csv'
DELIMITER ','
CSV HEADER;

-- referrals
copy source.referrals(
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
copy source.sales_people(
	name
	, country)
FROM 'C:\Users\Zac\Downloads\GetGround_technical_task\sales_people.csv'
DELIMITER ','
CSV HEADER;