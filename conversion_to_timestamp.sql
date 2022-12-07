/* change time columns from numeric to timestamp 
without timezone from the csv unix nano format and
dividing by 1000000 to remove the microseconds otherwise
error timestamp out of range will occur
*/
ALTER TABLE source.partners
	ALTER created_at TYPE timestamp without time zone
		USING (to_timestamp(created_at/1000000) AT TIME ZONE 'UTC');
		
ALTER TABLE source.partners
	ALTER updated_at TYPE timestamp without time zone
		USING (to_timestamp(updated_at/1000000) AT TIME ZONE 'UTC');
		
ALTER TABLE source.partners SET LOGGED;

ALTER TABLE source.referrals
	ALTER created_at TYPE timestamp without time zone
		USING (to_timestamp(created_at/1000000) AT TIME ZONE 'UTC');

ALTER TABLE source.referrals
	ALTER updated_at TYPE timestamp without time zone
		USING (to_timestamp(updated_at/1000000) AT TIME ZONE 'UTC');
		
ALTER TABLE source.referrals SET LOGGED;