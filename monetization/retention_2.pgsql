-- Scenario
-- You are given two tables:
--
-- `users`
-- `user_id`
-- `signup_date`
--
-- `transactions`
-- `transaction_id`, `user_id`, `transaction_date`, `amount`
--
-- Question
-- Calculate the 30-day retention rate for users who signed up in January 2024.
-- Definition:
-- A user is retained if they made at least one transaction within 30 days of signup.
-- Retention rate = retained users / total January signups.
--
-- Approach:
-- First filter users who signed up in January 2024 as the cohort,
-- then check whether they made any transaction within 30 days after signup,
-- and finally calculate the retained-user ratio.

WITH base_users AS (
    SELECT DISTINCT user_id, signup_date
    FROM users
    WHERE signup_date BETWEEN '2024-01-01' AND '2024-01-31'
),
retention_flag AS (
    SELECT *
    FROM transactions t
    JOIN base_users b
      ON t.user_id = b.user_id
     AND t.transaction_date >= b.signup_date
     AND t.transaction_date < b.signup_date + INTERVAL '30 days'
)
SELECT
    CAST(COALESCE(COUNT(d.user_id), 0) AS FLOAT) / NULLIF(COUNT(c.user_id), 0) AS retention_rate
FROM base_users c
LEFT JOIN retention_flag d
  ON c.user_id = d.user_id;
