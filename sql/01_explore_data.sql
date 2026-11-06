-- 1단계. 데이터 구조 이해 (2020-12-01 하루치)

-- 1-1. 원본 데이터 살펴보기: 한 줄이 무엇을 뜻하는지 확인
SELECT
  event_date,
  event_timestamp,
  event_name,
  user_pseudo_id,
  geo.country
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20201201`
LIMIT 10;


-- 1-2. 한 유저의 하루 여정을 시간순으로 따라가기
SELECT
  event_date,
  event_timestamp,
  event_name,
  user_pseudo_id,
  geo.country
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20201201`
WHERE user_pseudo_id = '1002254.4814908022'
ORDER BY event_timestamp;


-- 1-3. 하루 규모: 전체 이벤트 수와 고유 유저 수
SELECT
  COUNT(*) AS events,
  COUNT(DISTINCT user_pseudo_id) AS users
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20201201`;
