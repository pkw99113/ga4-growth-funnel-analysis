# data/

BigQuery 쿼리 결과를 집계 수준으로 저장한 CSV. Tableau 대시보드의 데이터 원본으로 쓴다.

| 파일 | 출처 | 내용 |
| --- | --- | --- |
| `funnel_by_country.csv` | [sql/05](../sql/05_ordered_funnel.sql) | 미국·인도·캐나다 순서 기반 퍼널. `reach_from_visit_pct`는 단계 전환율을 곱해 계산한 방문 대비 도달률(근사치) |
| `cohort_retention.csv` | [sql/06](../sql/06_cohort_retention.sql) | 신규 유저 주간 코호트별 d1 / w1 / m1 리텐션 |
| `activation_segments.csv` | [sql/07](../sql/07_activation.sql) | 첫날 도달 단계별 유저 수와 30일 리텐션 |
| `ab_test_result_simulated.csv` | [notebooks/08](../notebooks/08_ab_test_analysis.py) | **가상 데이터** A/B 테스트 결과. 그룹별 비율과 95% 신뢰구간 |
