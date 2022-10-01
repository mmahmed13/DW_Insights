-- Which posts generated the most negative reactions?
 SELECT page_name, url AS post_url, MAX(sad+angry) AS total_negative_reactions, MAX(sad) AS sad, MAX(angry) AS angry
 FROM (
         SELECT (ps.interactions->>'sad')::int sad, (ps.interactions->>'angry')::int angry, page_name, url, post.post_created AS posted
                FROM daily_reports.post
                JOIN daily_reports.post_statistics as ps 
                        ON post.page_facebook_id = ps.page_facebook_id 
                        AND post.post_created = ps.post_created AND post.page_facebook_id = ps.page_facebook_id
                JOIN daily_reports.page 
                      ON page.facebook_id = ps.page_facebook_id
        ) as negative_posts
 GROUP BY post_url, page_name
 ORDER BY total_negative_reactions DESC
 LIMIT 10
 