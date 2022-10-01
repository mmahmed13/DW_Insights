-- How many followers did DW Business gain since the upload of video 'https://www.facebook.com/85945845557/posts/10161961535635558' till latest posting?
WITH followers_then AS (
        SELECT page_name, post.post_created AS then_date, followers_at_posting, url
                FROM daily_reports.post
                JOIN daily_reports.page 
                      ON page.facebook_id = post.page_facebook_id
                WHERE page.page_name='DW Business' AND post.url='https://www.facebook.com/85945845557/posts/10161961535635558'
 ), followers_now AS (
        SELECT page_name, post.post_created AS now_date, followers_at_posting, url
                FROM daily_reports.post
                JOIN daily_reports.page 
                      ON page.facebook_id = post.page_facebook_id
                WHERE page.page_name='DW Business'
                ORDER BY now_date DESC
                LIMIT 1
)
SELECT followers_then.page_name AS page, followers_then.then_date, followers_now.now_date,  
followers_then.followers_at_posting AS followers_then, followers_now.followers_at_posting AS followers_now,
followers_now.followers_at_posting - followers_then.followers_at_posting AS increase, 
ROUND(((followers_now.followers_at_posting - followers_then.followers_at_posting)/followers_then.followers_at_posting)*100::numeric, 2) AS percentage_increase 
        FROM followers_then 
        JOIN followers_now 
                      ON followers_now.page_name = followers_then.page_name
                      