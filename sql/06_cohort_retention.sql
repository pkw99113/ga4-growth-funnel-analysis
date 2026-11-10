-- 06. 신규 유저 주간 코호트 리텐션 (첫 방문 2020-11-01 ~ 2020-12-31)
-- 리텐션 정의(누적): 첫 방문일 이후 N일 이내에 한 번이라도 재방문한 비율
--   d1 = 1일차, w1 = 1~7일 이내, m1 = 1~30일 이내 (첫 방문일 당일 제외)
-- 관찰 기간 확보: 데이터가 2021-01-31에 끝나므로 2020-12-31까지 첫 방문한 유저만 포함(최소 31일 관찰)

WITH new_users AS (
  -- 기간 중 first_visit 이벤트가 있는 유저 = 신규 유저
  SELECT
    user_pseudo_id,
    MIN(PARSE_DATE('%Y%m%d', event_date)) AS first_date
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
    AND event_name = 'first_visit'
  GROUP BY user_pseudo_id
),

visits AS (
  -- 유저 × 방문일 (하루 여러 이벤트는 1행으로)
  SELECT DISTINCT
    user_pseudo_id,
    PARSE_DATE('%Y%m%d', event_date) AS visit_date
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
),

user_retention AS (
  -- 유저당 1행: 코호트(첫 방문 주) + 기간별 재방문 플래그
  SELECT
    n.user_pseudo_id,
    DATE_TRUNC(n.first_date, WEEK) AS cohort_week,
    MAX(IF(DATE_DIFF(v.visit_date, n.first_date, DAY) = 1, 1, 0))             AS d1,
    MAX(IF(DATE_DIFF(v.visit_date, n.first_date, DAY) BETWEEN 1 AND 7, 1, 0))  AS w1,
    MAX(IF(DATE_DIFF(v.visit_date, n.first_date, DAY) BETWEEN 1 AND 30, 1, 0)) AS m1
  FROM new_users AS n
  JOIN visits AS v
    ON n.user_pseudo_id = v.user_pseudo_id
  WHERE n.first_date <= DATE '2020-12-31'
  GROUP BY n.user_pseudo_id, cohort_week
)

SELECT
  cohort_week,
  COUNT(*) AS new_users,
  ROUND(AVG(d1) * 100, 2) AS d1_pct,
  ROUND(AVG(w1) * 100, 2) AS w1_pct,
  ROUND(AVG(m1) * 100, 2) AS m1_pct
FROM user_retention
GROUP BY cohort_week
ORDER BY cohort_week;
