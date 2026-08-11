# =============================================================
# COMPLETE RANDOM FOREST PIPELINE - CAR PRICE PREDICTION
# =============================================================

library(tidyverse)
library(caret)
library(randomForest)
library(ggplot2)
library(corrplot)

set.seed(42)

# =============================================================
# 1. DATA PREPARATION
# =============================================================

# Load data
df <- read.csv('data/car_data.csv')

# Feature engineering
df <- df %>%
  mutate(
    car_age = 2020 - Year,
    is_diesel = ifelse(Fuel_Type == "Diesel", 1, 0),
    is_petrol = ifelse(Fuel_Type == "Petrol", 1, 0),
    is_dealer = ifelse(Seller_Type == "Dealer", 1, 0),
    is_manual = ifelse(Transmission == "Manual", 1, 0)
  ) %>%
  select(-c(Car_Name, Year, Fuel_Type, Seller_Type, Transmission))

# =============================================================
# 2. TRAIN/TEST SPLIT
# =============================================================

train_indices <- createDataPartition(df$Selling_Price, p = 0.7, list = FALSE)
train_data <- df[train_indices, ]
test_data <- df[-train_indices, ]

# =============================================================
# 3. RANDOM FOREST WITH HYPERPARAMETER TUNING
# =============================================================

# Define parameter grid
ntree_options <- c(300, 500, 700, 900, 1000)
mtry_options <- c(3, 5, 7, 9)
nodesize_options <- c(1, 2, 5, 10)

# Random search function
tune_rf <- function(train_data, n_iter = 10) {
  best_rmse <- Inf
  best_params <- list()
  
  for (i in 1:n_iter) {
    params <- list(
      ntree = sample(ntree_options, 1),
      mtry = sample(mtry_options, 1),
      nodesize = sample(nodesize_options, 1)
    )
    
    # 5-fold CV
    cv_rmse <- numeric(5)
    folds <- createFolds(train_data$Selling_Price, k = 5)
    
    for (fold in 1:5) {
      fold_train <- train_data[-folds[[fold]], ]
      fold_val <- train_data[folds[[fold]], ]
      
      model <- randomForest(
        Selling_Price ~ .,
        data = fold_train,
        ntree = params$ntree,
        mtry = params$mtry,
        nodesize = params$nodesize
      )
      
      pred <- predict(model, fold_val)
      cv_rmse[fold] <- sqrt(mean((fold_val$Selling_Price - pred)^2))
    }
    
    mean_rmse <- mean(cv_rmse)
    
    if (mean_rmse < best_rmse) {
      best_rmse <- mean_rmse
      best_params <- params
    }
    
    cat("Iteration", i, "RMSE:", round(mean_rmse, 3), "\n")
  }
  
  return(list(best_params = best_params, best_rmse = best_rmse))
}

# Run tuning
cat("🔄 Hyperparameter Tuning...\n")
tuning <- tune_rf(train_data, n_iter = 10)

cat("\n✅ Best Parameters:\n")
cat("  ntree:", tuning$best_params$ntree, "\n")
cat("  mtry:", tuning$best_params$mtry, "\n")
cat("  nodesize:", tuning$best_params$nodesize, "\n")
cat("  CV RMSE:", round(tuning$best_rmse, 3), "\n")

# =============================================================
# 4. TRAIN FINAL MODEL
# =============================================================

cat("\n🌲 Training Final Random Forest...\n")

rf_model <- randomForest(
  Selling_Price ~ .,
  data = train_data,
  ntree = tuning$best_params$ntree,
  mtry = tuning$best_params$mtry,
  nodesize = tuning$best_params$nodesize,
  importance = TRUE
)

# =============================================================
# 5. MODEL EVALUATION
# =============================================================

# Predictions
predictions <- predict(rf_model, test_data)

# Metrics
mae <- mean(abs(test_data$Selling_Price - predictions))
rmse <- sqrt(mean((test_data$Selling_Price - predictions)^2))
r2 <- cor(test_data$Selling_Price, predictions)^2

cat("\n📊 Model Performance:\n")
cat("  MAE:  ", round(mae, 3), "Lakhs\n")
cat("  RMSE: ", round(rmse, 3), "Lakhs\n")
cat("  R²:   ", round(r2, 3), "\n")

# =============================================================
# 6. FEATURE IMPORTANCE
# =============================================================

importance_df <- data.frame(
  Feature = rownames(importance(rf_model)),
  Importance = importance(rf_model)[, "%IncMSE"]
) %>% arrange(desc(Importance))

cat("\n📈 Feature Importance:\n")
print(head(importance_df, 5))

# =============================================================
# 7. VISUALIZATIONS
# =============================================================

# Predicted vs Actual
plot1 <- ggplot(data.frame(Actual = test_data$Selling_Price, 
                           Predicted = predictions),
                aes(x = Actual, y = Predicted)) +
  geom_point(alpha = 0.6, color = "#3498DB") +
  geom_abline(intercept = 0, slope = 1, color = "red", linetype = "dashed") +
  labs(title = "Predicted vs Actual Prices") +
  theme_minimal()

# Feature Importance
plot2 <- ggplot(importance_df, aes(x = reorder(Feature, Importance), y = Importance)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Feature Importance (%IncMSE)", x = "Features", y = "Importance") +
  theme_minimal()

# Residuals
plot3 <- ggplot(data.frame(Predicted = predictions, 
                           Residuals = test_data$Selling_Price - predictions),
                aes(x = Predicted, y = Residuals)) +
  geom_point(alpha = 0.6, color = "#3498DB") +
  geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
  labs(title = "Residual Plot") +
  theme_minimal()

# Display plots
print(plot1)
print(plot2)
print(plot3)

# =============================================================
# 8. SAVE MODEL
# =============================================================

saveRDS(rf_model, "random_forest_model.rds")
cat("\n✅ Model saved to 'random_forest_model.rds'\n")

# =============================================================
# 9. MAKE PREDICTIONS ON NEW DATA
# =============================================================

# Example prediction
new_car <- data.frame(
  Present_Price = 8.5,
  Kms_Driven = 15000,
  Owner = 0,
  car_age = 3,
  is_diesel = 1,
  is_petrol = 0,
  is_dealer = 1,
  is_manual = 0
)

predicted_price <- predict(rf_model, new_car)
cat("\n🚗 Example Prediction:\n")
cat("  New Car Price:", round(predicted_price, 2), "Lakhs\n")
