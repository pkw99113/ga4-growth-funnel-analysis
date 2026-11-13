"""
08. A/B 테스트 분석 (가상 데이터로 분석 절차 시연)

실제 실험 데이터가 없으므로, 설계서(notes/08_ab_test_design.md)의 가정으로 유저 단위 데이터를 생성해
분석 절차(SRM 점검 → 두 비율 z-검정 → 차이의 95% 신뢰구간 → 시각화 → 판단)를 시연한다.
가정: 그룹당 7,000명, 첫날 상품 조회율 A 21.4% / B 23.6%, 첫날 구매율 A·B 모두 0.96%
"""
import numpy as np
import pandas as pd
from scipy.stats import chisquare
from statsmodels.stats.proportion import proportions_ztest, confint_proportions_2indep
import matplotlib.pyplot as plt

# 1. 가상 실험 데이터 (유저당 1행)
np.random.seed(42)
n = 7000
df = pd.DataFrame({
    'group':     ['A'] * n + ['B'] * n,
    'viewed':    np.concatenate([np.random.binomial(1, 0.214, n),
                                 np.random.binomial(1, 0.236, n)]),
    'purchased': np.concatenate([np.random.binomial(1, 0.0096, n),
                                 np.random.binomial(1, 0.0096, n)]),
})

# 2. 그룹별 요약
summary = df.groupby('group').agg(
    users=('viewed', 'size'),
    viewed=('viewed', 'sum'),
    view_rate=('viewed', 'mean'),
    purchased=('purchased', 'sum'),
    buy_rate=('purchased', 'mean'),
)
print(summary, '\n')

# 3. 배정 비율 점검 (Sample Ratio Mismatch)
stat, p_srm = chisquare(summary['users'])
print(f'SRM: A {summary.users["A"]}명, B {summary.users["B"]}명, p-value = {p_srm:.3f}\n')

# 4. 두 비율 z-검정 + 차이(B - A)의 95% 신뢰구간
def ab_test(col):
    xB, xA = summary.loc['B', col], summary.loc['A', col]
    nB, nA = summary.loc['B', 'users'], summary.loc['A', 'users']
    z, p = proportions_ztest([xB, xA], [nB, nA])
    low, high = confint_proportions_2indep(xB, nB, xA, nA, compare='diff', method='wald')
    diff = xB / nB - xA / nA
    print(f'[{col}] A {xA/nA:.2%}  B {xB/nB:.2%}  차이(B-A) {diff*100:+.2f}%p  '
          f'95% CI [{low*100:+.2f}, {high*100:+.2f}]%p  p = {p:.4f}')

ab_test('viewed')     # 주 지표
ab_test('purchased')  # 가드레일

# 5. 시각화: 그룹별 상품 조회율과 95% 신뢰구간
rates = summary['view_rate']
err = 1.96 * np.sqrt(rates * (1 - rates) / summary['users'])
plt.figure(figsize=(5, 4))
plt.bar(['A (control)', 'B (popular items)'], rates * 100, yerr=err * 100, capsize=8,
        color=['#9aa5b1', '#3b82f6'])
plt.ylabel('First-day product view rate (%)')
plt.title('A/B test result (simulated data)')
plt.tight_layout()
plt.savefig('images/08_ab_test_result.png', dpi=150)
