# 🚗 Car Price Prediction Using Random Forest in R

[![R Version](https://img.shields.io/badge/R-4.0%2B-blue.svg)](https://www.r-project.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## 📌 Project Overview

This project develops a **Car Price Prediction** model using **Random Forest regression in R**.

The model predicts the selling price of used cars based on key vehicle characteristics, including:

* Present Price
* Car Age
* Kilometers Driven
* Fuel Type
* Seller Type
* Transmission Type
* Number of Previous Owners

The project follows a modular machine-learning pipeline consisting of **data preparation, feature engineering, hyperparameter tuning, model training, and evaluation**.

---

## 🎯 Project Objectives

The main objectives of this project are to:

1. Clean and prepare the vehicle dataset for machine learning.
2. Engineer relevant features such as **Car Age**.
3. Encode categorical variables for model development.
4. Train a **Random Forest regression** model.
5. Optimize model hyperparameters using **random search and 5-fold cross-validation**.
6. Evaluate model performance using MAE, MSE, and RMSE.
7. Identify the most influential features affecting used-car prices.

---

## 📁 Project Structure

```text
.
├── 01_data_preparation.R
├── 03_model_training.R
│
├── data/
│   ├── car_data.csv
│   └── processed_car_data.csv
│
└── outputs/
    └── models/
        └── random_forest_model.rds
```

### File Description

| File / Folder                            | Description                                                                               |
| ---------------------------------------- | ----------------------------------------------------------------------------------------- |
| `01_data_preparation.R`                  | Cleans the raw dataset, engineers features, and encodes categorical variables             |
| `03_model_training.R`                    | Performs hyperparameter tuning, trains the Random Forest model, and evaluates performance |
| `data/car_data.csv`                      | Raw vehicle dataset                                                                       |
| `data/processed_car_data.csv`            | Processed dataset generated during data preparation                                       |
| `outputs/models/random_forest_model.rds` | Trained Random Forest model                                                               |

> **Note:** `01_data_preparation.R` replaces the previous preprocessing scripts `car_price_data_cleaning.R` and `02_exploratory_analysis.R`. These legacy scripts are no longer required.

---

## 📊 Dataset

The dataset contains **301 vehicle records** and **9 original features**.

| Variable        | Type        | Description                                 |
| --------------- | ----------- | ------------------------------------------- |
| `Car_Name`      | Categorical | Name/model of the vehicle                   |
| `Year`          | Numerical   | Year of manufacture                         |
| `Selling_Price` | Numerical   | **Target variable** — resale price in Lakhs |
| `Present_Price` | Numerical   | Current ex-showroom price in Lakhs          |
| `Kms_Driven`    | Numerical   | Total kilometers driven                     |
| `Fuel_Type`     | Categorical | Petrol, Diesel, or CNG                      |
| `Seller_Type`   | Categorical | Dealer or Individual                        |
| `Transmission`  | Categorical | Manual or Automatic                         |
| `Owner`         | Numerical   | Number of previous owners                   |

The raw dataset should be placed at:

```text
data/car_data.csv
```

---

## ⚙️ Requirements

### R

* **R 4.0 or later**

### Required Packages

* `tidyverse`
* `caret`
* `randomForest`

Install the required packages with:

```r
install.packages(c("tidyverse", "caret", "randomForest"))
```

---

## ▶️ How to Run

Clone or download the repository and navigate to the project root directory.

Run the data-preparation script first:

```r
source("01_data_preparation.R")
```

Then train and evaluate the model:

```r
source("03_model_training.R")
```

The training script will:

* Perform hyperparameter search
* Train the Random Forest regression model
* Evaluate the model on the test set
* Display performance metrics
* Display feature importance
* Save the trained model as:

```text
outputs/models/random_forest_model.rds
```

---

## 🌲 Model Architecture

The project uses a **Random Forest Regressor** implemented with the `randomForest` package.

Hyperparameter optimization is performed using:

* **Random Search**
* **5-Fold Cross-Validation**
* **RMSE** as the optimization metric

This approach evaluates randomly selected combinations of hyperparameters rather than performing an exhaustive grid search.

### Hyperparameter Search Space

| Parameter  | Description                                 | Search Range |
| ---------- | ------------------------------------------- | -----------: |
| `ntree`    | Number of decision trees                    |     100–1200 |
| `mtry`     | Number of features considered at each split |          2–8 |
| `maxnodes` | Maximum terminal nodes per tree             |        10–50 |
| `nodesize` | Minimum observations in terminal nodes      |  1, 2, 5, 10 |

Each candidate configuration is evaluated using **5-fold cross-validation**. The configuration with the lowest average RMSE is selected for the final model.

---

## 📈 Model Performance

The reported model run used the following optimal hyperparameters:

| Parameter  | Value |
| ---------- | ----: |
| `ntree`    |   900 |
| `mtry`     |     7 |
| `maxnodes` |    45 |
| `nodesize` |     1 |
| CV RMSE    | 1.634 |

### Evaluation Metrics

| Metric   |            Score |
| -------- | ---------------: |
| **MAE**  |  **0.824 Lakhs** |
| **MSE**  | **2.704 Lakhs²** |
| **RMSE** |  **1.644 Lakhs** |

> **Important:** Results may vary slightly between runs because the train/test split and random hyperparameter search are stochastic. This effect can be noticeable with a relatively small dataset of 301 observations.

---

## 🔍 Feature Importance

Feature importance is measured using **%IncMSE**, which represents the increase in model error when the values of a feature are randomly permuted.

| Rank | Feature                     | Importance (%IncMSE) |
| ---: | --------------------------- | -------------------: |
|    1 | **Present Price**           |            **58.9%** |
|    2 | **Seller Type: Individual** |            **15.5%** |
|    3 | **Car Age**                 |            **14.5%** |
|    4 | **Seller Type: Dealer**     |            **11.1%** |
|    5 | **Transmission: Manual**    |            **10.8%** |

### Key Finding

**Present Price** is the dominant predictive feature in the model, with an importance score of **58.9% IncMSE**.

This indicates that the original/current showroom price provides a strong signal for estimating the resale value of a used vehicle.

> `%IncMSE` is a relative feature-importance measure and should **not** be interpreted as percentages that must sum to 100%.

---

## 🧠 Machine Learning Workflow

```text
Raw Vehicle Data
       │
       ▼
Data Preparation
       │
       ├── Data Cleaning
       ├── Feature Engineering
       └── Categorical Encoding
       │
       ▼
Processed Dataset
       │
       ▼
Train / Test Split
       │
       ▼
Random Search
       │
       ▼
5-Fold Cross-Validation
       │
       ▼
Best Hyperparameters
       │
       ▼
Random Forest Regression
       │
       ▼
Model Evaluation
       │
       ├── MAE
       ├── MSE
       └── RMSE
       │
       ▼
Feature Importance
       │
       ▼
Trained Model (.rds)
```

---

## 📦 Model Output

After successful execution, the trained model is saved as:

```text
outputs/models/random_forest_model.rds
```

The `.rds` file can later be loaded in R using:

```r
model <- readRDS("outputs/models/random_forest_model.rds")
```

## 🔮 Future Improvements

Potential extensions to this project include:

* Comparing Random Forest with **XGBoost**, **Gradient Boosting**, and **Linear Regression**.
* Increasing the dataset size.
* Adding additional vehicle attributes.
* Implementing automated model comparison.
* Developing an interactive **Shiny** or **Streamlit-style web application**.
* Deploying the model as a prediction API.
* Adding visual exploratory data analysis.
* Implementing automated model retraining.


 📄 License

This project is licensed under the [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)


 👤 Author

James C. Shakalima

Data Science | Statistics | Machine Learning | Aviation Analytics
