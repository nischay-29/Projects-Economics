# Student Time Allocation, Sleep & Productivity

This project examines the relationship between students' **academic workload and sleep sacrifice** using survey data and ordinal logistic regression.

## Model

An **ordinal logistic regression** is estimated because sleep sacrifice is an ordered categorical outcome:

```
m1 <- polr(
  sleep_sacrifice ~ academic_hrs,
  data = df,
  Hess = TRUE
)
```

**Dependent variable — `sleep_sacrifice`:**
Never → Rarely → Sometimes → Often → Almost every day

**Independent variable — `academic_hrs`:**
Less than 10 hrs → 10–20 hrs → 21–30 hrs → 31–40 hrs → More than 40 hrs

The model estimates the relationship between academic workload and the likelihood of being in a higher sleep-sacrifice category. Predicted probabilities are used to visualize the fitted relationship across workload categories.

## Insights

| Component    | Odds Ratio |    95% CI |
| ------------ | ---------: | --------: |
| Linear       |       1.31 | 0.63–2.75 |
| Quadratic    |       1.56 | 0.77–3.19 |
| Cubic        |       0.82 | 0.42–1.58 |
| Fourth-order |       0.63 | 0.33–1.19 |

* None of the polynomial components is statistically significant at the **5% level**.
* The model therefore does **not provide strong statistical evidence of a systematic relationship between academic workload and sleep sacrifice** in this sample.
* The fitted-probability graph provides a visual representation of how predicted sleep-sacrifice outcomes vary across academic-workload categories.
* The findings are **associational, not causal**.
