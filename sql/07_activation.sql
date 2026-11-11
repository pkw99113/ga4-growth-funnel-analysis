-- 07. Activation 정의: 첫날 행동과 30일 리텐션의 관계
-- 대상: 2020-11-01 ~ 2020-12-31 첫 방문 신규 유저 (06과 동일, 30일 관찰 가능)

-- 07-1. 신규 유저의 첫날 행동 비율
WITH new_users AS (
  SELECT
    user_pseudo_id,
    MIN(PARSE_DATE('%Y%m%d', event_date)) AS first_date
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
    AND event_name = 'first_visit'
  GROUP BY user_pseudo_id
),

events AS (
  SELECT
    user_pseudo_id,
    event_name,
    PARSE_DATE('%Y%m%d', event_date) AS event_day
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
),

first_day AS (
  -- 첫날 이벤트만 결합 (ON 조건에 날짜 포함)
  SELECT
    n.user_pseudo_id,
    MAX(IF(e.event_name = 'view_item', 1, 0))   AS fd_view,
    MAX(IF(e.event_name = 'add_to_cart', 1, 0)) AS fd_cart,
    MAX(IF(e.event_name = 'purchase', 1, 0))    AS fd_purchase
  FROM new_users AS n
  JOIN events AS e
    ON n.user_pseudo_id = e.user_pseudo_id
   AND e.event_day = n.first_date
  WHERE n.first_date <= DATE '2020-12-31'
  GROUP BY n.user_pseudo_id
)

SELECT
  COUNT(*) AS new_users,
  ROUND(AVG(fd_view) * 100, 2)     AS fd_view_pct,
  ROUND(AVG(fd_cart) * 100, 2)     AS fd_cart_pct,
  ROUND(AVG(fd_purchase) * 100, 2) AS fd_purchase_pct
FROM first_day;


-- 07-2. 첫날 도달 단계별 30일 리텐션
WITH new_users AS (
  SELECT
    user_pseudo_id,
    MIN(PARSE_DATE('%Y%m%d', event_date)) AS first_date
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
    AND event_name = 'first_visit'
  GROUP BY user_pseudo_id
),

events AS (
  SELECT
    user_pseudo_id,
    event_name,
    PARSE_DATE('%Y%m%d', event_date) AS event_day
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
),

user_flags AS (
  -- 전체 기간 이벤트를 결합하고, 조건은 IF 안에서 적용
  SELECT
    n.user_pseudo_id,
    MAX(IF(e.event_day = n.first_date AND e.event_name = 'view_item', 1, 0))   AS fd_view,
    MAX(IF(e.event_day = n.first_date AND e.event_name = 'add_to_cart', 1, 0)) AS fd_cart,
    MAX(IF(e.event_day = n.first_date AND e.event_name = 'purchase', 1, 0))    AS fd_purchase,
    MAX(IF(DATE_DIFF(e.event_day, n.first_date, DAY) BETWEEN 1 AND 30, 1, 0))  AS m1
  FROM new_users AS n
  JOIN events AS e
    ON n.user_pseudo_id = e.user_pseudo_id
  WHERE n.first_date <= DATE '2020-12-31'
  GROUP BY n.user_pseudo_id
),

segments AS (
  -- 첫날 가장 깊이 도달한 단계 (상호 배타적 세그먼트)
  SELECT
    user_pseudo_id,
    m1,
    CASE
      WHEN fd_purchase = 1 THEN '3_구매'
      WHEN fd_cart = 1     THEN '2_장바구니'
      WHEN fd_view = 1     THEN '1_상품조회'
      ELSE '0_상품 안 봄'
    END AS first_day_stage
  FROM user_flags
)

SELECT
  first_day_stage,
  COUNT(*) AS users,
  ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (), 1) AS share_pct,
  ROUND(AVG(m1) * 100, 2) AS m1_pct
FROM segments
GROUP BY first_day_stage
ORDER BY first_day_stage;
