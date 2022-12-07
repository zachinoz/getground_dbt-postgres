-- partners table
CREATE TABLE IF NOT EXISTS source.partners (
   id integer,
   created_at numeric,
   updated_at numeric,
   partner_type text,
   lead_sales_contact text
);

-- sales_people table
CREATE TABLE IF NOT EXISTS source.sales_people (
   name text,
   country text
);

-- referrals table
CREATE TABLE IF NOT EXISTS source.referrals (
   id integer,
   created_at numeric,
   updated_at numeric,
   company_id integer,
   partner_id integer,
   consultant_id integer,
   status text,
   is_outbound integer
);
