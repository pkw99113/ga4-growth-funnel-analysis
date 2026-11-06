-- 03. 국가별 구매 전환율 (2020-11-01 ~ 2021-01-31)
-- 결과 1행 = 국가 1개. 전환율 = 기간 중 구매한 유저 / 기간 중 방문한 유저

WITH country_stats AS (
  SELECT
    geo.country AS country,
    COUNT(DISTINCT user_pseudo_id) AS users,
    COUNT(DISTINCT IF(event_name = 'purchase', user_pseudo_id, NULL)) AS buyers
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  GROUP BY country
)

SELECT
  country,
  users,
  buyers,
  ROUND(SAFE_DIVIDE(buyers, users) * 100, 2) AS cvr_pct
FROM country_stats
ORDER BY users DESC
LIMIT 10;
