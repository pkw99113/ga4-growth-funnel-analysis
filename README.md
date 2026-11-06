# GA4 E-commerce Growth Analysis: 신규 유저 Activation과 리텐션

Google Merchandise Store의 GA4 이벤트 로그(약 3개월, 일 4천여 명 방문)를 BigQuery로 분석해, **신규 방문자가 구매와 재방문에 이르지 못하는 지점**을 찾고 개선 우선순위와 검증용 A/B 테스트를 설계한다.

## Business Question

> 신규 방문자의 대부분이 첫 구매 없이 이탈한다. **어느 단계에서, 어떤 유저가** 이탈하며, 무엇을 먼저 개선해야 하는가?

세부 질문
1. 첫 방문에서 구매까지의 퍼널 중 이탈이 가장 큰 구간은 어디인가
2. 재방문(리텐션)을 예측하는 초기 행동, 즉 Activation 기준은 무엇인가
3. 국가(미국, 캐나다, 인도)와 유입 채널, 기기에 따라 퍼널과 리텐션은 어떻게 다른가
4. 가장 큰 개선 기회를 검증하려면 어떤 실험을 설계해야 하는가

## Key Findings

> 분석 진행에 따라 업데이트

- 2020-12-01 기준 유저 4,308명이 이벤트 71,804건을 남겼다(1인당 약 16.7건). 유저 여정 샘플에서 프로모션 배너에는 반응했지만 상품 상세에 도달하지 못하고 첫 세션에서 이탈하는 패턴을 확인했고, 이를 이후 퍼널 분석의 가설로 삼았다. ([01](notes/01_explore_data.md))
- 방문자의 구매 전환율은 2.3%이며, **가장 큰 이탈은 방문 → 상품 조회 구간**이다. 방문자의 72.5%가 상품 상세를 보지 않고 이탈한 반면, 결제 시작 이후 단계의 전환율은 51~73%로 상대적으로 높다. 결제 개선보다 첫 방문 유저의 상품 도달이 우선 과제라는 가설을 세웠다. ([02](notes/02_event_overview.md))

## Approach

| # | 분석 | 핵심 방법 | 결과 |
| --- | --- | --- | --- |
| 01 | 데이터 구조 및 유저 여정 탐색 | 이벤트 로그 단위 파악, 유저 단위 시계열 추적 | [notes](notes/01_explore_data.md) · [sql](sql/01_explore_data.sql) |
| 02 | 이벤트 분포 | 이벤트별 건수·도달 유저 집계, 단계별 전환율 | [notes](notes/02_event_overview.md) · [sql](sql/02_event_overview.sql) |
| 03 | 국가별 구매 전환 | 조건부 집계, CTE, 윈도우 함수 | 진행 예정 |
| 04 | 유저 단위 퍼널 | 유저별 단계 도달 플래그 | 진행 예정 |
| 05 | 순서 기반 퍼널 | 타임스탬프 기반 단계 순서 검증 | 진행 예정 |
| 06 | 코호트 리텐션 | 첫 방문 주차 코호트, N-day 리텐션 | 진행 예정 |
| 07 | Activation 정의 및 국가 비교 | 초기 행동별 리텐션 비교 | 진행 예정 |
| 08 | A/B 테스트 설계 및 검정 | 표본 크기 산정, 두 비율 z-검정 | 진행 예정 |
| 09 | 대시보드 및 최종 보고서 | Tableau | 진행 예정 |

## Data

| 항목 | 내용 |
| --- | --- |
| 출처 | BigQuery 공개 데이터셋 `bigquery-public-data.ga4_obfuscated_sample_ecommerce` |
| 기간 | 2020-11-01 ~ 2021-01-31 (일별 파티션 테이블 `events_YYYYMMDD`) |
| 단위 | 1 row = 1 event (유저의 행동 하나) |
| 주요 필드 | `user_pseudo_id`, `event_timestamp`, `event_name`, `event_params`, `geo.country`, `device.category`, `traffic_source` |

**한계**: 공개용으로 일부 값이 난독화(obfuscated)되어 있어 절대 수치보다 구간 간 상대 비교에 초점을 둔다. 실험 데이터가 없어 A/B 테스트는 설계와 공개 실험 데이터 기반 검정으로 대체한다.

## Repository Structure

```
.
├── sql/      분석 단계별 BigQuery 쿼리
└── notes/    단계별 분석 목적, 결과, 해석
```

## Tech Stack

BigQuery (Standard SQL) · Python (pandas, statsmodels) · Tableau
