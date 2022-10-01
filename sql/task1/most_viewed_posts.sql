-- What were the top 10 most views videos from August that were owned?
 SELECT DISTINCT ON (ps.post_views) ps.post_views, page_name, url
 	FROM daily_reports.post
 	JOIN daily_reports.post_statistics as ps 
 		ON post.page_facebook_id = ps.page_facebook_id 
 		AND post.post_created = ps.post_created AND post.page_facebook_id = ps.page_facebook_id
 	JOIN daily_reports.page ON page.facebook_id = ps.page_facebook_id
 	WHERE post.post_created BETWEEN '2022-08-01 00:00:00' AND '2022-08-30 23:59:59' AND "is_video_owner?"=True
 	ORDER BY ps.post_views DESC
 	LIMIT 10
