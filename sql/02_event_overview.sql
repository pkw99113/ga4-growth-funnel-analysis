-- 02. 이벤트 분포 (2020-12-01)
-- 이벤트별 발생 건수와 도달 유저 수. 결과 1행 = 이벤트 1종

SELECT
  event_name,
  COUNT(*) AS events,
  COUNT(DISTINCT user_pseudo_id) AS users
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20201201`
GROUP BY event_name
ORDER BY events DESC;
