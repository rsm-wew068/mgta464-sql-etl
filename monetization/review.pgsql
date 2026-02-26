-- 1) Advertiser Performance Reporting
--
-- Core issue: prevent double counting.
-- Key technique: CTE + aggregate before join.
-- Interview example: report ROAS (revenue/spend) per campaign in the last 30 days.
-- Logic: compute spend and revenue in separate CTEs, then join by `campaign_id`.

-- 2) User Retention and Growth
--
-- Core issue: track the same user cohort across time.
-- Key technique: self-join.
-- Interview example: next-day retention or weekly retention.
-- Logic: use users active today as the left table and left join users active tomorrow
-- on same `user_id` and date difference = 1.

-- 3) Ranking and Filtering
--
-- Core issue: find top records within groups without collapsing raw rows.
-- Key technique: window function (`ROW_NUMBER`).
-- Interview example: top 3 ads by category, or most-liked video per creator.
-- Logic: `PARTITION BY [group field] ORDER BY [metric] DESC`.

-- 4) Data Quality and Anomaly Detection
--
-- Core issue: ensure reporting quality and avoid junk data.
-- Key techniques: `CASE WHEN`, `NULLIF`, `COALESCE`.
-- Interview example: handle zero denominator and detect campaigns with high clicks but zero conversion.
-- Logic: use `NULLIF` to avoid errors, `COALESCE` for null handling,
-- and `HAVING` to filter anomalies after aggregation.

-- Final advice:
-- Interviewers may combine all four modules in one question, e.g.:
-- "Find the top 5 ad categories with the highest retention rate in the past 7 days."
--
-- Build it like Lego:
-- 1. Use self-join to compute retention.
-- 2. Use CTEs to map retained users to ad categories.
-- 3. Use a window function to rank and take top 5.

-- This is a "boss-level" question that combines retention logic, multi-table joins,
-- and window functions.
--
-- Clarification:
-- 1) Confirm retention definition:
--    - ad-click retention (clicked again next day), or
--    - advertiser retention (advertiser runs campaigns again next day)?
-- 2) Common interview assumption: user retention,
--    i.e., users who viewed category A ads and were active again the next day.
--
-- Assumed schema:
-- `ad_clicks(user_id, ad_id, category, click_date)`
-- `user_login(user_id, login_date)`

-- Prompt:
-- Find the top 5 ad categories with the highest retention rate in the past 7 days.

-- Logic steps:
-- CTE 1 (Retention): within last 7 days, find user-days that were active and also active next day.
-- CTE 2 (Category Mapping): map each user's retention status to viewed ad categories.
-- Final step: compute average retention by category and rank top 5.

-- Notes:
-- `login_date = click_date + 1`
-- `click` means active today
-- `login` means came back the next day

WITH daily_base AS (
    -- User-category activity base in the last 7 days
    SELECT DISTINCT user_id, category, click_date
    FROM ad_clicks
    WHERE click_date >= CURRENT_DATE - INTERVAL '7 days'
),
retention_flag AS (
    -- Mark retained users: 1 if user logged in next day, else 0
    SELECT
        d.user_id,
        d.category,
        d.click_date,
        u.login_date,
        CASE WHEN u.user_id IS NOT NULL THEN 1 ELSE 0 END AS is_retained
    FROM daily_base d
    LEFT JOIN user_login u
      ON d.user_id = u.user_id
     AND u.login_date = d.click_date + 1
),
category_scores AS (
    SELECT
        category,
        CAST(SUM(is_retained) AS FLOAT) / NULLIF(COUNT(*), 0) AS avg_retention
    FROM retention_flag
    GROUP BY category
),
ranked_categories AS (
    SELECT
        category,
        avg_retention,
        ROW_NUMBER() OVER (ORDER BY avg_retention DESC) AS ranking
    FROM category_scores
)
SELECT category, avg_retention, ranking
FROM ranked_categories
WHERE ranking <= 5;

-- Tip:
-- The hardest part is that one user may view multiple categories.
-- For each category, denominator = users who viewed that category;
-- numerator = those users who came back the next day.
