-- 05. 순서 기반 퍼널: 미국·캐나다·인도 (2020-11-01 ~ 2021-01-31)
-- 1층 user_steps: 유저별 각 단계의 최초 발생 시각
-- 2층 ordered:    시각 비교로 "직전 단계 이후에 발생했는가"를 0/1로 기록 (앞 단계 조건을 누적)
-- 3층:            국가별 단계 전환율

WITH user_steps AS (
  SELECT
    geo.country AS country,
    user_pseudo_id,
    MIN(IF(event_name = 'view_item', event_timestamp, NULL))      AS t_viewed,
    MIN(IF(event_name = 'add_to_cart', event_timestamp, NULL))    AS t_carted,
    MIN(IF(event_name = 'begin_checkout', event_timestamp, NULL)) AS t_checkout,
    MIN(IF(event_name = 'purchase', event_timestamp, NULL))       AS t_purchased
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
    AND geo.country IN ('United States', 'Canada', 'India')
  GROUP BY country, user_pseudo_id
),

ordered AS (
  SELECT
    country,
    user_pseudo_id,
    IF(t_viewed IS NOT NULL, 1, 0) AS s_view,
    IF(t_carted > t_viewed, 1, 0) AS s_cart,
    IF(t_checkout > t_carted AND t_carted > t_viewed, 1, 0) AS s_checkout,
    IF(t_purchased > t_checkout AND t_checkout > t_carted AND t_carted > t_viewed, 1, 0) AS s_purchase
  FROM user_steps
)

SELECT
  country,
  COUNT(*) AS users,
  ROUND(AVG(s_view) * 100, 1)                                   AS visit_to_view_pct,
  ROUND(SAFE_DIVIDE(SUM(s_cart), SUM(s_view)) * 100, 1)         AS view_to_cart_pct,
  ROUND(SAFE_DIVIDE(SUM(s_checkout), SUM(s_cart)) * 100, 1)     AS cart_to_checkout_pct,
  ROUND(SAFE_DIVIDE(SUM(s_purchase), SUM(s_checkout)) * 100, 1) AS checkout_to_buy_pct
FROM ordered
GROUP BY country
ORDER BY users DESC;
