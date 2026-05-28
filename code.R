library(tidyverse)
library(readxl)
library(ranger)

# Load
df <- read_excel("education-income-emp_rate_nz_2000-2019.xlsx")

# Feature engineering
df_modeling <- df %>%
  arrange(`SA2 Code`, Year) %>%
  group_by(`SA2 Code`) %>%
  mutate(
    lag_income = lag(`Household Income`),
    lag_employment = lag(`Employment Rate`),
    lag_education = lag(`Tertiary Education Pct`),
    year_trend = Year - 2000
  ) %>%
  ungroup() %>%
  drop_na()

# Train/test
train <- df_modeling %>% filter(Year <= 2017)
test <- df_modeling %>% filter(Year > 2017)

cat("Training set:", nrow(train), "rows\n")
cat("Test set:", nrow(test), "rows\n\n")

# ============================================================================
# MODEL 1: Linear Regression
# ============================================================================
cat("===== MODEL 1: LINEAR REGRESSION =====\n")
lm_fit <- lm(`Household Income` ~ `Tertiary Education Pct` + `Employment Rate` + year_trend, data = train)

test_pred_lm <- test %>%
  mutate(pred_lm = predict(lm_fit, newdata = test))

rmse_lm <- sqrt(mean((test_pred_lm$`Household Income` - test_pred_lm$pred_lm)^2))
r2_lm <- cor(test_pred_lm$`Household Income`, test_pred_lm$pred_lm)^2
mae_lm <- mean(abs(test_pred_lm$`Household Income` - test_pred_lm$pred_lm))

cat(sprintf("RMSE: $%.2f\nR²: %.4f\nMAE: $%.2f\n\n", rmse_lm, r2_lm, mae_lm))

# ============================================================================
# MODEL 2: Random Forest
# ============================================================================
cat("===== MODEL 2: RANDOM FOREST =====\n")

rf_fit <- ranger(
  Household_Income ~ Tertiary_Education_Pct + Employment_Rate + 
    lag_income + lag_employment + lag_education + year_trend,
  data = train %>% rename(
    Household_Income = `Household Income`,
    Tertiary_Education_Pct = `Tertiary Education Pct`,
    Employment_Rate = `Employment Rate`
  ),
  num.trees = 500,
  importance = "impurity"
)

test <- test %>%
  rename(
    Household_Income = `Household Income`,
    Tertiary_Education_Pct = `Tertiary Education Pct`,
    Employment_Rate = `Employment Rate`,
    SA2_Code = `SA2 Code`,
    Suburb_Name = `Suburb Name`
  )

test_pred_rf <- test %>%
  mutate(pred_rf = predict(rf_fit, data = test)$predictions)

rmse_rf <- sqrt(mean((test_pred_rf$Household_Income - test_pred_rf$pred_rf)^2))
r2_rf <- cor(test_pred_rf$Household_Income, test_pred_rf$pred_rf)^2
mae_rf <- mean(abs(test_pred_rf$Household_Income - test_pred_rf$pred_rf))

cat(sprintf("RMSE: $%.2f\nR²: %.4f\nMAE: $%.2f\n\n", rmse_rf, r2_rf, mae_rf))

# Feature importance
cat("\nFeature Importance:\n")
importance_df <- data.frame(
  Feature = names(rf_fit$variable.importance),
  Importance = rf_fit$variable.importance
) %>% arrange(desc(Importance))
print(importance_df)

library(ggplot2)

# 1. RF: Actual vs Predicted
p1 <- test_pred_rf %>%
  ggplot(aes(x = Household_Income, y = pred_rf)) +
  geom_point(alpha = 0.6, color = "#2E86AB", size = 2.5) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "red", linewidth = 1) +
  labs(
    title = "Random Forest: Actual vs Predicted Income",
    x = "Actual Household Income ($)",
    y = "Predicted Household Income ($)",
    subtitle = sprintf("R² = %.4f | RMSE = $%.0f", r2_rf, rmse_rf)
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 13))

ggsave("01_rf_predictions.png", p1, width = 10, height = 6, dpi = 300)

# 2. Residuals
p2 <- test_pred_rf %>%
  mutate(residual = Household_Income - pred_rf) %>%
  ggplot(aes(x = pred_rf, y = residual)) +
  geom_point(alpha = 0.6, color = "#A23B72", size = 2.5) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red", linewidth = 1) +
  labs(
    title = "Residual Plot: Prediction Errors",
    x = "Predicted Income ($)",
    y = "Residual ($)"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 13))

ggsave("02_residuals.png", p2, width = 10, height = 6, dpi = 300)

# 3. Feature importance
p3 <- importance_df %>%
  ggplot(aes(x = reorder(Feature, Importance), y = Importance)) +
  geom_col(fill = "#F18F01", alpha = 0.8) +
  coord_flip() +
  labs(
    title = "Random Forest Feature Importance",
    x = "Feature",
    y = "Importance Score"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 13))

ggsave("03_feature_importance.png", p3, width = 10, height = 6, dpi = 300)

# 4. Model comparison
model_comparison <- data.frame(
  Model = c("Linear Regression", "Random Forest"),
  RMSE = c(rmse_lm, rmse_rf),
  R2 = c(r2_lm, r2_rf)
)

p4 <- model_comparison %>%
  pivot_longer(cols = -Model) %>%
  ggplot(aes(x = Model, y = value, fill = name)) +
  geom_col(position = "dodge", alpha = 0.8) +
  facet_wrap(~name, scales = "free_y") +
  labs(title = "Model Performance Comparison") +
  theme_minimal() +
  scale_fill_manual(values = c("#2E86AB", "#F18F01")) +
  theme(plot.title = element_text(face = "bold", size = 13), legend.position = "none")

ggsave("04_model_comparison.png", p4, width = 10, height = 5, dpi = 300)

cat("✓ All plots saved!\n")
