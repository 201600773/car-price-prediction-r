#!/usr/bin/env Rscript

# =============================================================
# PREDICT_PRICE.R
# Car Price Prediction - Load Model and Make Predictions
# =============================================================

# Load required libraries
library(randomForest)
library(jsonlite)

# =============================================================
# FUNCTION: Load the trained model
# =============================================================

load_model <- function(model_path = "outputs/models/random_forest_model.rds") {
  if (!file.exists(model_path)) {
    stop("❌ Model file not found: ", model_path)
  }
  
  cat("✅ Loading model from:", model_path, "\n")
  model <- readRDS(model_path)
  cat("✅ Model loaded successfully!\n")
  cat("   - Type:", class(model)[1], "\n")
  cat("   - Trees:", model$ntree, "\n")
  return(model)
}

# =============================================================
# FUNCTION: Prepare data for prediction
# =============================================================

prepare_features <- function(input_data) {
  # Input data should have these fields:
  # present_price, year, kms_driven, owner, fuel_type, seller_type, transmission
  
  # Calculate car age
  car_age <- 2020 - as.numeric(input_data$year)
  
  # Create data frame with all features
  new_data <- data.frame(
    Present_Price = as.numeric(input_data$present_price),
    Kms_Driven = as.numeric(input_data$kms_driven),
    Owner = as.numeric(input_data$owner),
    car_age = car_age,
    Fuel_Type_CNG = ifelse(input_data$fuel_type == "CNG", 1, 0),
    Fuel_Type_Diesel = ifelse(input_data$fuel_type == "Diesel", 1, 0),
    Fuel_Type_Petrol = ifelse(input_data$fuel_type == "Petrol", 1, 0),
    Seller_Type_Dealer = ifelse(input_data$seller_type == "Dealer", 1, 0),
    Seller_Type_Individual = ifelse(input_data$seller_type == "Individual", 1, 0),
    Transmission_Automatic = ifelse(input_data$transmission == "Automatic", 1, 0),
    Transmission_Manual = ifelse(input_data$transmission == "Manual", 1, 0)
  )
  
  return(new_data)
}

# =============================================================
# FUNCTION: Make prediction
# =============================================================

predict_price <- function(model, features) {
  tryCatch({
    prediction <- predict(model, newdata = features)
    return(round(as.numeric(prediction), 2))
  }, error = function(e) {
    stop("❌ Prediction error: ", e$message)
  })
}

# =============================================================
# MAIN EXECUTION
# =============================================================

main <- function() {
  # 1. Load the model
  model <- load_model()
  
  # 2. Get input data
  # Check if input is from command line arguments or JSON
  args <- commandArgs(trailingOnly = TRUE)
  
  if (length(args) == 0) {
    # Interactive mode - ask for input
    cat("\n📝 Enter car details:\n")
    cat("Present Price (Lakhs): ")
    present_price <- readline()
    cat("Year of Manufacture: ")
    year <- readline()
    cat("Kilometers Driven: ")
    kms_driven <- readline()
    cat("Number of Owners (0,1,2,3+): ")
    owner <- readline()
    cat("Fuel Type (Petrol/Diesel/CNG): ")
    fuel_type <- readline()
    cat("Seller Type (Dealer/Individual): ")
    seller_type <- readline()
    cat("Transmission (Manual/Automatic): ")
    transmission <- readline()
    
    input_data <- list(
      present_price = present_price,
      year = year,
      kms_driven = kms_driven,
      owner = owner,
      fuel_type = fuel_type,
      seller_type = seller_type,
      transmission = transmission
    )
  } else if (length(args) == 1 && args[1] == "--test") {
    # Test mode - use sample data
    cat("\n🧪 Running test prediction...\n")
    input_data <- list(
      present_price = "5.59",
      year = "2014",
      kms_driven = "27000",
      owner = "0",
      fuel_type = "Petrol",
      seller_type = "Dealer",
      transmission = "Manual"
    )
  } else {
    # Command line arguments: present_price year kms_driven owner fuel_type seller_type transmission
    if (length(args) < 7) {
      cat("❌ Need 7 arguments: present_price year kms_driven owner fuel_type seller_type transmission\n")
      cat("Example: Rscript predict_price.R 5.59 2014 27000 0 Petrol Dealer Manual\n")
      return(NULL)
    }
    
    input_data <- list(
      present_price = args[1],
      year = args[2],
      kms_driven = args[3],
      owner = args[4],
      fuel_type = args[5],
      seller_type = args[6],
      transmission = args[7]
    )
  }
  
  # 3. Prepare features
  cat("\n📊 Preparing features...\n")
  features <- prepare_features(input_data)
  
  cat("   Features prepared:\n")
  print(features)
  
  # 4. Make prediction
  cat("\n🤖 Making prediction...\n")
  predicted_price <- predict_price(model, features)
  
  # 5. Output result
  cat("\n" = "=", rep("=", 40), "\n")
  cat("  🚗 PREDICTION RESULT\n")
  cat("=", rep("=", 40), "\n")
  cat("  💰 Predicted Selling Price: ₹", predicted_price, " Lakhs\n", sep = "")
  cat("=", rep("=", 40), "\n")
  
  # Return JSON for API integration
  output <- list(
    success = TRUE,
    price = predicted_price,
    input = input_data
  )
  
  cat("\n📤 JSON Output:\n")
  cat(toJSON(output, auto_unbox = TRUE), "\n")
  
  # Return just the price for command line use
  return(predicted_price)
}

# =============================================================
# RUN THE SCRIPT
# =============================================================

# Execute main function
if (!interactive()) {
  result <- main()
} else {
  # Interactive mode (R console)
  cat("\n🔧 Running in interactive mode\n")
  main()
}
