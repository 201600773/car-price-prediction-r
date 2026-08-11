# =============================================================
# 02_exploratory_analysis.R
# Car Price Prediction - Exploratory Data Analysis with Visualizations
# =============================================================

library(tidyverse)
library(ggplot2)
install.packages('corrplot') # Install corrplot package
library(corrplot)
library(GGally)
library(gridExtra)

set.seed(42)

# Load data
df <- read.csv('/content/processed_car_data.csv')

# Create output directory
dir.create("outputs/plots", recursive = TRUE, showWarnings = FALSE)

cat("=== Exploratory Data Analysis ===\n")
cat("\nSummary Statistics:\n")
print(summary(df))

# =============================================================
# 1. CORRELATION MATRIX
# =============================================================
cat("\n📊 Creating Correlation Matrix...\n")

# Calculate correlation matrix
cor_matrix <- cor(df[, sapply(df, is.numeric)])

# Save correlation heatmap
png("outputs/plots/correlation_heatmap.png", width = 800, height = 800)
corrplot(cor_matrix, method = "color", type = "upper", 
         tl.col = "black", tl.srt = 45,
         title = "Correlation Matrix of Car Features",
         mar = c(0,0,2,0))
dev.off()
cat("✅ Correlation heatmap saved\n")

# =============================================================
# 2. PAIR PLOT
# =============================================================
cat("\n📊 Creating Pair Plot...\n")

vars_for_pairplot <- c("Selling_Price", "Present_Price", "Kms_Driven", "car_age")

p <- ggpairs(df[, vars_for_pairplot]) +
  ggtitle("Pair Plot of Key Variables")

ggsave("outputs/plots/pair_plot.png", p, width = 10, height = 10)
cat("✅ Pair plot saved\n")

# =============================================================
# 3. CREATE CATEGORICAL VARIABLES FOR PLOTTING
# =============================================================
df <- df %>%
  mutate(
    Fuel_Type = case_when(
      Fuel_Type_Diesel == 1 ~ "Diesel",
      Fuel_Type_Petrol == 1 ~ "Petrol",
      TRUE ~ "CNG"
    ),
    Transmission_Type = ifelse(Transmission_Manual == 1, "Manual", "Automatic"),
    Seller_Type = ifelse(Seller_Type_Individual == 1, "Individual", "Dealer")
  )

# =============================================================
# 4. PRICE DISTRIBUTION
# =============================================================
cat("\n📊 Creating Price Distribution Plot...\n")

p1 <- ggplot(df, aes(x = Selling_Price)) +
  geom_histogram(bins = 30, fill = "#3498DB", color = "white", alpha = 0.8) +
  geom_density(color = "#E74C3C", size = 1) +
  labs(title = "Distribution of Selling Price",
       subtitle = paste("Mean:", round(mean(df$Selling_Price), 2), 
                       "Lakhs | Median:", round(median(df$Selling_Price), 2), "Lakhs"),
       x = "Selling Price (Lakhs)",
       y = "Frequency") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5))

ggsave("outputs/plots/price_distribution.png", p1, width = 8, height = 6)
cat("✅ Price distribution saved\n")

# =============================================================
# 5. PRICE BY FUEL TYPE
# =============================================================
cat("\n📊 Creating Price by Fuel Type Plot...\n")

p2 <- ggplot(df, aes(x = Fuel_Type, y = Selling_Price, fill = Fuel_Type)) +
  geom_boxplot(alpha = 0.7, outlier.size = 2) +
  geom_jitter(width = 0.2, alpha = 0.3, size = 1) +
  scale_fill_manual(values = c("Diesel" = "#E74C3C", "Petrol" = "#3498DB", "CNG" = "#2ECC71")) +
  labs(title = "Selling Price by Fuel Type",
       x = "Fuel Type",
       y = "Selling Price (Lakhs)") +
  theme_minimal() +
  theme(legend.position = "none",
        plot.title = element_text(hjust = 0.5, face = "bold"))

ggsave("outputs/plots/price_by_fuel.png", p2, width = 8, height = 6)
cat("✅ Price by fuel saved\n")

# =============================================================
# 6. PRICE BY TRANSMISSION
# =============================================================
cat("\n📊 Creating Price by Transmission Plot...\n")

p3 <- ggplot(df, aes(x = Transmission_Type, y = Selling_Price, fill = Transmission_Type)) +
  geom_boxplot(alpha = 0.7, outlier.size = 2) +
  geom_jitter(width = 0.2, alpha = 0.3, size = 1) +
  scale_fill_manual(values = c("Manual" = "#3498DB", "Automatic" = "#E67E22")) +
  labs(title = "Selling Price by Transmission Type",
       x = "Transmission",
       y = "Selling Price (Lakhs)") +
  theme_minimal() +
  theme(legend.position = "none",
        plot.title = element_text(hjust = 0.5, face = "bold"))

ggsave("outputs/plots/price_by_transmission.png", p3, width = 8, height = 6)
cat("✅ Price by transmission saved\n")

# =============================================================
# 7. PRICE BY SELLER TYPE
# =============================================================
cat("\n📊 Creating Price by Seller Type Plot...\n")

p4 <- ggplot(df, aes(x = Seller_Type, y = Selling_Price, fill = Seller_Type)) +
  geom_boxplot(alpha = 0.7, outlier.size = 2) +
  geom_jitter(width = 0.2, alpha = 0.3, size = 1) +
  scale_fill_manual(values = c("Dealer" = "#2ECC71", "Individual" = "#E67E22")) +
  labs(title = "Selling Price by Seller Type",
       x = "Seller Type",
       y = "Selling Price (Lakhs)") +
  theme_minimal() +
  theme(legend.position = "none",
        plot.title = element_text(hjust = 0.5, face = "bold"))

ggsave("outputs/plots/price_by_seller.png", p4, width = 8, height = 6)
cat("✅ Price by seller saved\n")

# =============================================================
# 8. PRICE BY OWNER COUNT
# =============================================================
cat("\n📊 Creating Price by Owner Count Plot...\n")

p5 <- ggplot(df, aes(x = factor(Owner), y = Selling_Price, fill = factor(Owner))) +
  geom_boxplot(alpha = 0.7, outlier.size = 2) +
  scale_fill_brewer(palette = "Blues") +
  labs(title = "Selling Price by Number of Owners",
       x = "Number of Owners",
       y = "Selling Price (Lakhs)") +
  theme_minimal() +
  theme(legend.position = "none",
        plot.title = element_text(hjust = 0.5, face = "bold"))

ggsave("outputs/plots/price_by_owner.png", p5, width = 8, height = 6)
cat("✅ Price by owner saved\n")

# =============================================================
# 9. PRICE VS CAR AGE (Scatter with Regression)
# =============================================================
cat("\n📊 Creating Price vs Car Age Plot...\n")

p6 <- ggplot(df, aes(x = car_age, y = Selling_Price)) +
  geom_point(alpha = 0.6, color = "#3498DB", size = 2) +
  geom_smooth(method = "lm", color = "#E74C3C", se = TRUE, fill = "#E74C3C", alpha = 0.2) +
  labs(title = "Selling Price vs Car Age",
       subtitle = paste("Correlation:", round(cor(df$car_age, df$Selling_Price), 3)),
       x = "Car Age (Years)",
       y = "Selling Price (Lakhs)") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5))

ggsave("outputs/plots/price_vs_age.png", p6, width = 8, height = 6)
cat("✅ Price vs age saved\n")

# =============================================================
# 10. PRICE VS PRESENT PRICE
# =============================================================
cat("\n📊 Creating Price vs Present Price Plot...\n")

p7 <- ggplot(df, aes(x = Present_Price, y = Selling_Price)) +
  geom_point(alpha = 0.6, color = "#3498DB", size = 2) +
  geom_smooth(method = "lm", color = "#E74C3C", se = TRUE, fill = "#E74C3C", alpha = 0.2) +
  labs(title = "Selling Price vs Present Price",
       subtitle = paste("Correlation:", round(cor(df$Present_Price, df$Selling_Price), 3)),
       x = "Present Price (Lakhs)",
       y = "Selling Price (Lakhs)") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5))

ggsave("outputs/plots/price_vs_present.png", p7, width = 8, height = 6)
cat("✅ Price vs present price saved\n")

# =============================================================
# 11. VIOLIN PLOT - PRICE BY FUEL TYPE
# =============================================================
cat("\n📊 Creating Violin Plot...\n")

p8 <- ggplot(df, aes(x = Fuel_Type, y = Selling_Price, fill = Fuel_Type)) +
  geom_violin(alpha = 0.5) +
  geom_boxplot(width = 0.2, alpha = 0.8, outlier.size = 1) +
  scale_fill_manual(values = c("Diesel" = "#E74C3C", "Petrol" = "#3498DB", "CNG" = "#2ECC71")) +
  labs(title = "Price Distribution by Fuel Type",
       x = "Fuel Type",
       y = "Selling Price (Lakhs)") +
  theme_minimal() +
  theme(legend.position = "none",
        plot.title = element_text(hjust = 0.5, face = "bold"))

ggsave("outputs/plots/price_by_fuel_violin.png", p8, width = 8, height = 6)
cat("✅ Violin plot saved\n")

# =============================================================
# 12. SUMMARY STATISTICS TABLE
# =============================================================
cat("\n📊 Generating Summary Statistics...\n")

summary_stats <- df %>%
  select(Selling_Price, Present_Price, Kms_Driven, car_age, Owner) %>%
  summary()

print(summary_stats)

# =============================================================
# KEY INSIGHTS
# =============================================================
cat("\n" = "=", rep("=", 50), "\n")
cat("  KEY INSIGHTS\n")
cat("=", rep("=", 50), "\n\n")

cat("1. Price Distribution:\n")
cat("   - Mean selling price:", round(mean(df$Selling_Price), 2), "Lakhs\n")
cat("   - Median selling price:", round(median(df$Selling_Price), 2), "Lakhs\n")
cat("   - Range:", min(df$Selling_Price), "-", max(df$Selling_Price), "Lakhs\n\n")

cat("2. Correlation with Selling Price:\n")
cat("   - Present Price:", round(cor(df$Present_Price, df$Selling_Price), 3), "\n")
cat("   - Car Age:", round(cor(df$car_age, df$Selling_Price), 3), "\n")
cat("   - Kms Driven:", round(cor(df$Kms_Driven, df$Selling_Price), 3), "\n\n")

cat("3. Categorical Impact:\n")
cat("   - Diesel cars have highest median price\n")
cat("   - Automatic transmissions command premium\n")
cat("   - Dealers sell at higher prices than individuals\n")

# List all plots
cat("\n📁 All plots saved to 'outputs/plots/':\n")
plot_files <- list.files("outputs/plots", pattern = "\\.png$")
for (f in sort(plot_files)) {
  cat("   -", f, "\n")
}
cat("\nTotal plots:", length(plot_files), "\n")

cat("\n=== Exploratory Analysis Complete ===\n")
