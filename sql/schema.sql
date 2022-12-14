PGDMP                     	    z        
   dw_reports    14.5    14.5                0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false                       0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false                       0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false                       1262    16394 
   dw_reports    DATABASE     h   CREATE DATABASE dw_reports WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'English_Germany.1252';
    DROP DATABASE dw_reports;
                postgres    false                        2615    16395    daily_reports    SCHEMA        CREATE SCHEMA daily_reports;
    DROP SCHEMA daily_reports;
                postgres    false                        2615    17219    fb_insights    SCHEMA        CREATE SCHEMA fb_insights;
    DROP SCHEMA fb_insights;
                postgres    false            ?            1255    17286    extract_json()    FUNCTION     ?  CREATE FUNCTION public.extract_json() RETURNS void
    LANGUAGE plpgsql
    AS $$
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
$$;
 %   DROP FUNCTION public.extract_json();
       public          postgres    false            ?            1255    17223 "   load_csv_file(text, text, integer)    FUNCTION     ?  CREATE FUNCTION public.load_csv_file(target_table text, csv_path text, col_count integer) RETURNS void
    LANGUAGE plpgsql
    AS $$

declare

iter integer; -- dummy integer to iterate columns with
col text; -- variable to keep the column name at each iteration
col_first text; -- first column name, e.g., top left corner on a csv file or spreadsheet

begin
    set schema 'fb_insights';

    create table temp_table ();

    -- add just enough number of columns
    for iter in 1..col_count
    loop
        execute format('alter table temp_table add column col_%s text;', iter);
    end loop;

    -- copy the data from csv file
    execute format('copy temp_table from %L with delimiter '','' quote ''"'' csv ', csv_path);

    iter := 1;
    col_first := (select col_1 from temp_table limit 1);

    -- update the column names based on the first row which has the column names
    for col in execute format('select unnest(string_to_array(trim(temp_table::text, ''()''), '','')) from temp_table where col_1 = %L', col_first)
    loop
        execute format('alter table temp_table rename column col_%s to %s', iter, col);
        iter := iter + 1;
    end loop;

    -- delete the columns row
    execute format('delete from temp_table where %s = %L', col_first, col_first);

    -- change the temp table name to the name given as parameter, if not blank
    if length(target_table) > 0 then
        execute format('alter table temp_table rename to %I', target_table);
    end if;

end;

$$;
 Y   DROP FUNCTION public.load_csv_file(target_table text, csv_path text, col_count integer);
       public          postgres    false            ?            1259    16410    page    TABLE     ,  CREATE TABLE daily_reports.page (
    page_name text NOT NULL,
    user_name text NOT NULL,
    facebook_id bigint NOT NULL,
    page_category text NOT NULL,
    page_admin_top_country character varying(2) NOT NULL,
    page_description text,
    page_created timestamp without time zone NOT NULL
);
    DROP TABLE daily_reports.page;
       daily_reports         heap    postgres    false    6            ?            1259    16890    post    TABLE     ?  CREATE TABLE daily_reports.post (
    post_created timestamp with time zone NOT NULL,
    page_facebook_id bigint NOT NULL,
    video_share_status text,
    "is_video_owner?" boolean,
    video_length time without time zone,
    url text NOT NULL,
    message text,
    link text,
    final_link text,
    image_text text,
    sponsor_id bigint,
    likes_at_posting numeric,
    followers_at_posting numeric
);
    DROP TABLE daily_reports.post;
       daily_reports         heap    postgres    false    6            ?            1259    17077    post_statistics    TABLE     H  CREATE TABLE daily_reports.post_statistics (
    statistics_id uuid NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    interactions json NOT NULL,
    post_views numeric,
    total_views numeric,
    total_views_for_all_crossposts numeric,
    post_created timestamp with time zone,
    page_facebook_id bigint
);
 *   DROP TABLE daily_reports.post_statistics;
       daily_reports         heap    postgres    false    6            ?            1259    16451    sponsor    TABLE     ?   CREATE TABLE daily_reports.sponsor (
    sponsor_id bigint NOT NULL,
    sponsor_name text NOT NULL,
    sponsor_category text
);
 "   DROP TABLE daily_reports.sponsor;
       daily_reports         heap    postgres    false    6            ?            1259    17266    insights    TABLE       CREATE TABLE fb_insights.insights (
    insights_created_date text,
    post_activity bigint,
    post_activity_by_action_type text,
    post_activity_by_action_type_unique text,
    post_activity_unique bigint,
    post_clicks bigint,
    post_clicks_by_type text,
    post_clicks_by_type_unique text,
    post_clicks_unique bigint,
    post_engaged_fan bigint,
    post_engaged_users bigint,
    post_id text,
    post_impressions bigint,
    post_impressions_by_story_type text,
    post_impressions_by_story_type_unique text,
    post_impressions_fan bigint,
    post_impressions_fan_paid bigint,
    post_impressions_fan_paid_unique bigint,
    post_impressions_fan_unique bigint,
    post_impressions_nonviral bigint,
    post_impressions_nonviral_unique bigint,
    post_impressions_organic bigint,
    post_impressions_organic_unique bigint,
    post_impressions_paid bigint,
    post_impressions_paid_unique bigint,
    post_impressions_unique bigint,
    post_impressions_viral bigint,
    post_impressions_viral_unique bigint,
    post_negative_feedback bigint,
    post_negative_feedback_by_type text,
    post_negative_feedback_by_type_unique text,
    post_negative_feedback_unique bigint,
    post_reactions_anger_total bigint,
    post_reactions_by_type_total text,
    post_reactions_haha_total bigint,
    post_reactions_like_total bigint,
    post_reactions_love_total bigint,
    post_reactions_sorry_total bigint,
    post_reactions_wow_total bigint,
    post_video_avg_time_watched bigint,
    post_video_complete_views_organic bigint,
    post_video_complete_views_organic_unique bigint,
    post_video_complete_views_paid bigint,
    post_video_complete_views_paid_unique bigint,
    post_video_length bigint,
    post_video_retention_graph text,
    post_video_retention_graph_autoplayed text,
    post_video_retention_graph_clicked_to_play text,
    post_video_view_time bigint,
    post_video_view_time_by_age_bucket_and_gender text,
    post_video_view_time_by_country_id text,
    post_video_view_time_by_distribution_type text,
    post_video_view_time_by_region_id text,
    post_video_view_time_organic bigint,
    post_video_views bigint,
    post_video_views_10s bigint,
    post_video_views_10s_autoplayed bigint,
    post_video_views_10s_clicked_to_play bigint,
    post_video_views_10s_organic bigint,
    post_video_views_10s_paid bigint,
    post_video_views_10s_sound_on bigint,
    post_video_views_10s_unique bigint,
    post_video_views_autoplayed bigint,
    post_video_views_by_distribution_type text,
    post_video_views_clicked_to_play bigint,
    post_video_views_organic bigint,
    post_video_views_organic_unique bigint,
    post_video_views_paid bigint,
    post_video_views_paid_unique bigint,
    post_video_views_sound_on bigint,
    post_video_views_unique bigint,
    period text
);
 !   DROP TABLE fb_insights.insights;
       fb_insights         heap    postgres    false    4            ?            1259    17287    view_time_stats    TABLE     ?   CREATE TABLE fb_insights.view_time_stats (
    post_id text NOT NULL,
    age_group text,
    gender text,
    view_time numeric
);
 (   DROP TABLE fb_insights.view_time_stats;
       fb_insights         heap    postgres    false    4            t           2606    16416    page page_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY daily_reports.page
    ADD CONSTRAINT page_pkey PRIMARY KEY (facebook_id);
 ?   ALTER TABLE ONLY daily_reports.page DROP CONSTRAINT page_pkey;
       daily_reports            postgres    false    211            x           2606    16896    post post_pkey 
   CONSTRAINT     o   ALTER TABLE ONLY daily_reports.post
    ADD CONSTRAINT post_pkey PRIMARY KEY (post_created, page_facebook_id);
 ?   ALTER TABLE ONLY daily_reports.post DROP CONSTRAINT post_pkey;
       daily_reports            postgres    false    213    213            z           2606    17083 $   post_statistics post_statistics_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY daily_reports.post_statistics
    ADD CONSTRAINT post_statistics_pkey PRIMARY KEY (statistics_id);
 U   ALTER TABLE ONLY daily_reports.post_statistics DROP CONSTRAINT post_statistics_pkey;
       daily_reports            postgres    false    214            v           2606    16457    sponsor sponsor_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY daily_reports.sponsor
    ADD CONSTRAINT sponsor_pkey PRIMARY KEY (sponsor_id);
 E   ALTER TABLE ONLY daily_reports.sponsor DROP CONSTRAINT sponsor_pkey;
       daily_reports            postgres    false    212            {           2606    16897    post fk_facebook_id    FK CONSTRAINT     ?   ALTER TABLE ONLY daily_reports.post
    ADD CONSTRAINT fk_facebook_id FOREIGN KEY (page_facebook_id) REFERENCES daily_reports.page(facebook_id) ON DELETE CASCADE;
 D   ALTER TABLE ONLY daily_reports.post DROP CONSTRAINT fk_facebook_id;
       daily_reports          postgres    false    3188    211    213            }           2606    17084    post_statistics fk_post    FK CONSTRAINT     ?   ALTER TABLE ONLY daily_reports.post_statistics
    ADD CONSTRAINT fk_post FOREIGN KEY (page_facebook_id, post_created) REFERENCES daily_reports.post(page_facebook_id, post_created) MATCH FULL ON DELETE CASCADE;
 H   ALTER TABLE ONLY daily_reports.post_statistics DROP CONSTRAINT fk_post;
       daily_reports          postgres    false    214    214    3192    213    213            |           2606    16902    post fk_sponsor    FK CONSTRAINT     ?   ALTER TABLE ONLY daily_reports.post
    ADD CONSTRAINT fk_sponsor FOREIGN KEY (sponsor_id) REFERENCES daily_reports.sponsor(sponsor_id) ON DELETE CASCADE;
 @   ALTER TABLE ONLY daily_reports.post DROP CONSTRAINT fk_sponsor;
       daily_reports          postgres    false    3190    213    212           