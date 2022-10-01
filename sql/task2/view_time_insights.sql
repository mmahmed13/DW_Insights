-- Sums per post for each gender
SELECT post_id, gender, SUM(view_time) as total_time
FROM fb_insights.view_time_stats
GROUP BY post_id, gender
ORDER BY post_id, gender;


-- Sum for age 18-34 of all genders
SELECT SUM(view_time)
FROM fb_insights.view_time_stats
WHERE age_group IN ('18-24', '25-34')

