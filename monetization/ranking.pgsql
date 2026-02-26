-- Case: Find the best-performing ads in each category
--
-- Prompt:
-- You have an ad performance summary table `campaign_performance`:
-- Columns: `campaign_id`, `category` (ad category, such as "gaming" or "beauty"), `clicks`.
-- Task: Find the top 3 campaigns by clicks within each category.

WITH ads_stats AS (
    SELECT
        campaign_id,
        category,
        clicks,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY clicks DESC) AS ranking
    FROM campaign_performance
)
SELECT *
FROM ads_stats
WHERE ranking <= 3; -- top 3 campaigns per category


-- Case: Find each creator's most-liked video
--
-- Table: `videos`
-- Columns:
-- `video_id` (unique video ID)
-- `creator_id` (unique creator ID)
-- `likes` (total likes for the video)

WITH video_likes AS (
    SELECT
        video_id,
        creator_id,
        likes,
        ROW_NUMBER() OVER (PARTITION BY creator_id ORDER BY likes DESC) AS ranking
    FROM videos
)
SELECT *
FROM video_likes
WHERE ranking = 1;
