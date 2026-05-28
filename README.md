# NZ Household Income Prediction

Predictive modelling of regional household income across New Zealand (2000–2019) using education and employment data.

## Key Results

- **Random Forest model achieves R² = 0.92** on 2018–2019 test data
- Historical income (lagged 1 year) is the **13x more important** than current education/employment
- **RMSE: $4,230** | Average prediction error < $3,400
- Dramatically outperforms baseline linear regression (R² = 0.03)

## Project Overview

This analysis addresses: **Can we predict regional household income from education and employment trends?**

**Answer:** Not well with simple models. A Random Forest incorporating historical income patterns achieves 92% accuracy—revealing that regional economic momentum dominates current demographics.

## Data & Methods

- **Data Source:** NZ SA2 Education, Income & Employment (2000–2019) | 115 regions × 20 years
- **Variables:** Tertiary education %, employment rate, household income
- **Models:** 
  - Linear Regression (baseline)
  - Random Forest (500 trees)
- **Train/Test Split:** 2000–2017 train, 2018–2019 test (respects temporal structure)
- **Features:** Current education/employment + lagged values (1-year lag) + year trend

## Files

- **nz_income_prediction.html** — Full interactive report (open in browser)
- **nz_income_prediction.Rmd** — R Markdown source code
- **education-income-emp_rate_nz_2000-2019.xlsx** — Raw data

## Key Findings

### 1. Historical Performance Dominates
Lagged income explains ~65% of variance alone. Regions follow stable economic trajectories.

### 2. Current Employment & Education Matter Less
- Employment rate importance: 3–4%
- Tertiary education importance: 3%
- Suggests long-term structural factors outweigh recent labor market changes

### 3. Model Selection is Critical
Random Forest captures non-linear regional dynamics that linear models completely miss.

## Business & Policy Implications

- **For investors:** Historical income stability predicts future income better than current employment. Focus on regions with upward trajectories.
- **For policymakers:** Shifting regional income requires addressing *persistent structural factors*, not just employment. Education may have long-term effects not visible here.
- **For analysts:** Tree-based methods superior for regional economic prediction.

## How to Use This Code

### View the Report
Download and open `nz_income_prediction.html` in any web browser.

### Reproduce the Analysis
```R
# Install dependencies (if needed)
install.packages(c("tidyverse", "readxl", "ranger"))

# Render the R Markdown report
rmarkdown::render("nz_income_prediction.Rmd")
```

## Limitations

- **Regional aggregation:** SA2 diversity hidden; within-region inequality not captured
- **Confounding variables:** Industry mix, age demographics, migration patterns not included
- **Time period:** 2000–2019 pre-dates COVID-19 and recent policy shifts
- **Predictive, not causal:** Cannot claim education *causes* income changes

## Future Directions

- Hierarchical models accounting for regional clusters
- Industry composition & occupational data
- Time-series forecasting (ARIMA, Prophet) for out-of-sample prediction
- Causal inference (instrumental variables) to isolate education effects

## Technical Stack

- **Language:** R
- **Libraries:** tidyverse, readxl, ranger, ggplot2
- **Modeling:** Machine Learning (Random Forest)
- **Reporting:** R Markdown + HTML

## Contact & Attribution

Analysis by Lakshiyien Namasivayam
Data source: Kaggle | NZ Stats NZ

---

**Want to explore this further?** Check out the interactive report or reach out with questions!
