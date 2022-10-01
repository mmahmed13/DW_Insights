-- What was the most liked video from August, in Sports Category pages?
 SELECT (ps.interactions->>'likes')::int likes, page_name, url, post.post_created
        FROM daily_reports.post
        JOIN daily_reports.post_statistics as ps 
                ON post.page_facebook_id = ps.page_facebook_id 
                AND post.post_created = ps.post_created AND post.page_facebook_id = ps.page_facebook_id
        JOIN daily_reports.page 
              ON page.facebook_id = ps.page_facebook_id
        WHERE post.post_created BETWEEN '2022-08-01 00:00:00' AND '2022-08-30 23:59:59' AND page.page_category='SPORTS'
        ORDER BY likes DESC 
        LIMIT 1

