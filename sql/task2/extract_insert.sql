CREATE OR REPLACE FUNCTION extract_json() RETURNS VOID AS $$
DECLARE
	TABLE_RECORD RECORD;
	GENDER_AGE RECORD;
	_key   text;
   	_value NUMERIC;
BEGIN
	FOR TABLE_RECORD IN SELECT cast(post_video_view_time_by_age_bucket_and_gender AS jsonb) AS post_stats, post_id FROM fb_insights.insights
	LOOP
		-- iterate over json key value pairs
		FOR _key, _value IN SELECT * FROM jsonb_each_text(TABLE_RECORD.post_stats)
    	LOOP
			SELECT string_to_array(_key, '.') AS parts into GENDER_AGE;
			
			-- insert values
			INSERT INTO fb_insights.view_time_stats(
			gender, age_group, view_time, post_id) 
			VALUES (GENDER_AGE.parts[1], GENDER_AGE.parts[2], _value, TABLE_RECORD.post_id);
    	END LOOP;
	END LOOP;

    END;
$$ LANGUAGE plpgsql;

-- call function
SELECT extract_json();

-- -- uncomment to drop column in source table
-- ALTER TABLE fb_insights.insights DROP COLUMN post_video_view_time_by_age_bucket_and_gender;

-- view the extracted table
SELECT * FROM fb_insights.view_time_stats
