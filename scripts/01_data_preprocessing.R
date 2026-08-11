# =============================================================
# 01_data_preparation.R
# Car Price Prediction - Data Preparation
# =============================================================

# Load libraries
library(tidyverse)
library(ggplot2)

# Settings
input_file <- "/content/car data.csv"
output_file <- "/content/processed_car_data.csv"
current_year <- 2020

# Create directories
dir.create("data", showWarnings = FALSE)
dir.create("outputs/plots", recursive = TRUE, showWarnings = FALSE)

# Load raw data
cat("=== Data Preparation ===\n")
raw_data <- read.csv(input_file)

cat("Rows:", nrow(raw_data), "Columns:", ncol(raw_data), "\n")
cat("Column names:", paste(names(raw_data), collapse = ", "), "\n\n")

# Check missing values
cat("Missing values:\n")
print(colSums(is.na(raw_data)))

# Select columns
selected_columns <- c("Year", "Selling_Price", "Present_Price", "Kms_Driven",
                      "Fuel_Type", "Seller_Type", "Transmission", "Owner")
car_data <- raw_data[, selected_columns]

# Feature engineering - create car_age
car_data$car_age <- current_year - car_data$Year
car_data$Year <- NULL

# One-hot encoding
fuel_dummies <- model.matrix(~ Fuel_Type - 1, data = car_data)
seller_dummies <- model.matrix(~ Seller_Type - 1, data = car_data)
transmission_dummies <- model.matrix(~ Transmission - 1, data = car_data)

# Combine
numeric_cols <- c("Selling_Price", "Present_Price", "Kms_Driven", "Owner", "car_age")
processed_data <- cbind(
  car_data[, numeric_cols],
  fuel_dummies,
  seller_dummies,
  transmission_dummies
)

# Clean column names
colnames(processed_data) <- c(
  "Selling_Price", "Present_Price", "Kms_Driven", "Owner", "car_age",
  "Fuel_Type_CNG", "Fuel_Type_Diesel", "Fuel_Type_Petrol",
  "Seller_Type_Dealer", "Seller_Type_Individual",
  "Transmission_Automatic", "Transmission_Manual"
)

# Save processed data
write.csv(processed_data, output_file, row.names = FALSE)

cat("\n✅ Processed data saved to:", output_file, "\n")
cat("First few rows:\n")
print(head(processed_data))
cat("\n=== Data Preparation Complete ===\n")
