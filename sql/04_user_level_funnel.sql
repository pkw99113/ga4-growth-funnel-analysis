-- 04. 유저 단위 퍼널: 미국·캐나다·인도 비교 (2020-11-01 ~ 2021-01-31)
-- 1단계(CTE): 이벤트 로그를 유저당 1행으로 변환하고, 단계별 도달 여부를 0/1 플래그로 기록
-- 2단계: 국가별로 플래그를 집계. SUM(flag) = 도달 유저 수, AVG(flag) = 도달 비율

WITH user_steps AS (
  SELECT
    geo.country AS country,
    user_pseudo_id,
    MAX(IF(event_name = 'view_item', 1, 0))      AS viewed,
    MAX(IF(event_name = 'add_to_cart', 1, 0))    AS carted,
    MAX(IF(event_name = 'begin_checkout', 1, 0)) AS checkout,
    MAX(IF(event_name = 'purchase', 1, 0))       AS purchased
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
    AND geo.country IN ('United States', 'Canada', 'India')
  GROUP BY country, user_pseudo_id
)

SELECT
  country,
  COUNT(*) AS users,
  ROUND(AVG(viewed) * 100, 1)                                AS visit_to_view_pct,
  ROUND(SAFE_DIVIDE(SUM(carted), SUM(viewed)) * 100, 1)      AS view_to_cart_pct,
  ROUND(SAFE_DIVIDE(SUM(checkout), SUM(carted)) * 100, 1)    AS cart_to_checkout_pct,
  ROUND(SAFE_DIVIDE(SUM(purchased), SUM(checkout)) * 100, 1) AS checkout_to_buy_pct
FROM user_steps
GROUP BY country
ORDER BY users DESC;
