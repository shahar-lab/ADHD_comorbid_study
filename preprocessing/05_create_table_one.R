library(dplyr)

print("@@@@@@Creating Table 1: Summary of group size, age, cluster")

#### Load processed data ----
load("data/processed_data/df_remove_diagnosis_contradiction.Rdata")

if (!exists("df_remove_diagnosis_contradiction")) {
  stop("The object df_remove_diagnosis_contradiction was not found in the loaded data file.")
}

#### Prepare data for summaries ----
df <- df_remove_diagnosis_contradiction %>%
  mutate(
    group_declared = as.character(group_declared),
    age = as.numeric(age),
    cluster = as.numeric(cluster),
    gender_clean = tolower(trimws(as.character(gender)))
  ) %>%
  mutate(
    gender_clean = case_when(
      gender_clean %in% c("female", "f") ~ "female",
      gender_clean %in% c("male", "m") ~ "male",
      gender_clean %in% c("other", "non-binary", "nonbinary", "nb", "unspecified", "unknown") ~ "other",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(group_declared %in% c("ADHD", "TD"))

#### Summary by group ----
summary_by_group <- df %>%
  group_by(group_declared) %>%
  summarise(
    n_people = n(),
    mean_age = mean(age, na.rm = TRUE),
    mean_cluster = mean(cluster, na.rm = TRUE),
    .groups = "drop"
  )

cat("Group size and age summary\n")
print(summary_by_group %>% select(group_declared, n_people, mean_age, mean_cluster))

#### Gender breakdown by group ----
gender_levels <- c("female", "male", "other")

gender_counts <- df %>%
  filter(!is.na(gender_clean)) %>%
  group_by(group_declared, gender_clean) %>%
  summarise(n = n(), .groups = "drop")

all_combinations <- expand.grid(
  group_declared = c("ADHD", "TD"),
  gender_clean = gender_levels,
  stringsAsFactors = FALSE
)

gender_summary <- all_combinations %>%
  left_join(gender_counts, by = c("group_declared", "gender_clean")) %>%
  mutate(n = ifelse(is.na(n), 0L, n)) %>%
  left_join(summary_by_group %>% select(group_declared, n_people), by = "group_declared") %>%
  mutate(percentage = ifelse(n_people > 0, round(100 * n / n_people, 1), NA_real_)) %>%
  select(group_declared, gender_clean, n, percentage)

cat("\nGender breakdown by group\n")
print(gender_summary)

#### Symptom means by group ----
symptom_summary <- df %>%
  group_by(group_declared) %>%
  summarise(
    mean_diva_IA_symptoms = mean(diva_IA_symptoms, na.rm = TRUE),
    mean_diva_HI_symptoms = mean(diva_HI_symptoms, na.rm = TRUE),
    .groups = "drop"
  )

cat("\nMean symptom scores by group\n")
print(symptom_summary)

#### Bayesian Cohen's d effect sizes with 90% HDI ----
# Check and install bayestestR if needed
if (!require("bayestestR", quietly = TRUE)) {
  install.packages("bayestestR")
  library(bayestestR)
}

# Function to calculate Cohen's d and Bayesian HDI
calculate_cohens_d_with_hdi <- function(var_name, data) {
  adhd_data <- data %>% filter(group_declared == "ADHD") %>% pull(!!sym(var_name))
  td_data <- data %>% filter(group_declared == "TD") %>% pull(!!sym(var_name))
  
  # Remove NA values
  adhd_data <- adhd_data[!is.na(adhd_data)]
  td_data <- td_data[!is.na(td_data)]
  
  # Calculate Cohen's d manually
  n1 <- length(adhd_data)
  n2 <- length(td_data)
  m1 <- mean(adhd_data)
  m2 <- mean(td_data)
  sd1 <- sd(adhd_data)
  sd2 <- sd(td_data)
  
  # Pooled standard deviation
  pooled_sd <- sqrt(((n1 - 1) * sd1^2 + (n2 - 1) * sd2^2) / (n1 + n2 - 2))
  cohens_d <- (m1 - m2) / pooled_sd
  
  # Standard error of Cohen's d
  se_cohens_d <- sqrt((n1 + n2) / (n1 * n2) + (cohens_d^2 / (2 * (n1 + n2 - 2))))
  
  # Create posterior distribution of Cohen's d (using normal approximation)
  posterior_samples <- rnorm(10000, mean = cohens_d, sd = se_cohens_d)
  
  # Calculate HDI using bayestestR
  hdi_result <- bayestestR::hdi(posterior_samples, ci = 0.9)
  
  return(list(
    variable = var_name,
    cohens_d = cohens_d,
    hdi_lower = hdi_result$CI_low,
    hdi_upper = hdi_result$CI_high
  ))
}

cat("\n\n===== Bayesian Cohen's d Effect Sizes (ADHD vs TD) with 90% HDI =====\n\n")

# Calculate for continuous variables
for (var in c("age", "cluster", "diva_IA_symptoms", "diva_HI_symptoms")) {
  result <- calculate_cohens_d_with_hdi(var, df)
  cat(sprintf("%s:\n", result$variable))
  cat(sprintf("  Posterior Cohen's d: %.4f\n", result$cohens_d))
  cat(sprintf("  90%% HDI: [%.4f, %.4f]\n\n", result$hdi_lower, result$hdi_upper))
}

# Calculate for gender categories (convert to binary: 1 if gender matches, 0 otherwise)
for (gender_cat in c("female", "male", "other")) {
  df_gender <- df %>%
    mutate(gender_binary = ifelse(gender_clean == gender_cat, 1, 0))
  
  result <- calculate_cohens_d_with_hdi("gender_binary", df_gender)
  cat(sprintf("Gender = %s:\n", gender_cat))
  cat(sprintf("  Posterior Cohen's d: %.4f\n", result$cohens_d))
  cat(sprintf("  90%% HDI: [%.4f, %.4f]\n\n", result$hdi_lower, result$hdi_upper))
}

