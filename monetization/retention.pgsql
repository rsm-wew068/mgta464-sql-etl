-- Table: `user_activity`
--
-- `user_id`: unique user ID
-- `login_date`: login date
--
-- Task:
-- Calculate next-day retention for February 1, 2026:
-- among users who logged in on 2026-02-01, what fraction also logged in on 2026-02-02?

WITH day1_login AS (
    SELECT DISTINCT user_id
    FROM user_activity
    WHERE login_date = '2026-02-01'
),
retained_users AS (
    SELECT DISTINCT a.user_id
    FROM user_activity AS a
    JOIN user_activity AS b
      ON a.user_id = b.user_id
    WHERE a.login_date = '2026-02-01'
      AND b.login_date = '2026-02-02'
)
SELECT
    CAST(COALESCE(COUNT(r.user_id), 0) AS FLOAT) / NULLIF(COUNT(d.user_id), 0) AS retention_rate
FROM day1_login d
LEFT JOIN retained_users r
  ON r.user_id = d.user_id;
