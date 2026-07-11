library(dplyr)

print("$$$$$$$Creating Table 1: Summary of group size, age, cluster")

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
    min_age = min(age, na.rm = TRUE),
    max_age = max(age, na.rm = TRUE),
    mean_cluster = mean(cluster, na.rm = TRUE),
    sd_age = sd(age, na.rm = TRUE),
    sd_cluster = sd(cluster, na.rm = TRUE),
    .groups = "drop"
  )

cat("Group size and age summary\n")
print(summary_by_group %>% select(group_declared, n_people, mean_age, min_age, max_age, sd_age, mean_cluster, sd_cluster))

cat("\nCluster SD by group (range 1-10)\n")
print(summary_by_group %>% select(group_declared, sd_cluster))

#### Symptom means and SDs by group ----
symptom_summary <- df %>%
  group_by(group_declared) %>%
  summarise(
    mean_diva_IA_symptoms = mean(diva_IA_symptoms, na.rm = TRUE),
    sd_diva_IA_symptoms = sd(diva_IA_symptoms, na.rm = TRUE),
    mean_diva_HI_symptoms = mean(diva_HI_symptoms, na.rm = TRUE),
    sd_diva_HI_symptoms = sd(diva_HI_symptoms, na.rm = TRUE),
    .groups = "drop"
  )

cat("\nMean symptom scores and SDs by group\n")
print(symptom_summary)

cat("\nSD of symptom scores by group\n")
print(symptom_summary %>% select(group_declared, sd_diva_IA_symptoms, sd_diva_HI_symptoms))

#### Gender counts and percentages by group ----
gender_summary_by_group <- df %>%
  filter(!is.na(gender_clean)) %>%
  group_by(group_declared, gender_clean) %>%
  summarise(n = n(), .groups = "drop") %>%
  left_join(
    df %>%
      filter(!is.na(gender_clean)) %>%
      count(group_declared, name = "n_total"),
    by = "group_declared"
  ) %>%
  mutate(percentage = round(100 * n / n_total, 1)) %>%
  select(group_declared, gender_clean, n, percentage)

cat("\nGender counts and percentages by group\n")
print(gender_summary_by_group)

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

#### Classify medication names from df_agg_without_gender_and_undeclared_group ----
load("data/raw_data/df_agg_without_gender_and_undeclared_group.Rdata")

if (!exists("df_agg")) {
  stop("The object df_agg was not found in the loaded data file.")
}

classify_medication_string <- function(x) {
  if (length(x) == 0 || is.na(x) || is.null(x)) {
    return("Other/Unknown")
  }

  value <- trimws(as.character(x))
  if (value == "" || grepl("^(NA|NaN)$", value, ignore.case = TRUE)) {
    return("Other/Unknown")
  }

  low <- tolower(value)

  stimulant_terms <- c(
    "attent", "אטנט",
    "concerta", "קונצרטה",
    "focalin", "פוקלין",
    "ritalin", "ריטלין",
    "vyvanse", "וייואנס",
    "amphetamine",
    "rubifen", "רוביפן",
    "riavenir", "ריאבניר",
    "dexmethylphenidate",
    "phenidin", "rephenidate"
  )

  non_stimulant_terms <- c(
    "strattera", "atomoxetine", "atomik", "אטומיק"
  )

  if (any(sapply(stimulant_terms, function(term) grepl(term, low, fixed = TRUE)))) {
    return("Stimulant")
  }

  if (any(sapply(non_stimulant_terms, function(term) grepl(term, low, fixed = TRUE)))) {
    return("Non-stimulant")
  }

  "Other/Unknown"
}

meds_classified <- df_agg %>%
  mutate(
    medication_text = as.character(community_diagnosis_meds_type),
    medication_class = vapply(medication_text, classify_medication_string, character(1))
  ) %>%
  filter(
    !is.na(medication_text),
    trimws(medication_text) != "",
    !grepl("^(NA|NaN)$", medication_text, ignore.case = TRUE)
  )

medication_summary <- meds_classified %>%
  count(medication_class, name = "n_people") %>%
  mutate(percentage = round(100 * n_people / nrow(meds_classified), 1))

cat("\nMedication classification summary from df_agg\n")
print(medication_summary %>% filter(medication_class %in% c("Stimulant", "Non-stimulant")))

#### ADHD-only summary: not taking medication ----
adhd_med_status <- df_agg %>%
  filter(group_declared == "ADHD") %>%
  mutate(
    medication_text = trimws(as.character(community_diagnosis_meds_type)),
    not_taking_meds = tolower(medication_text) %in% c("", "no", "none", "n/a", "na")
  )

n_adhd_total <- nrow(adhd_med_status)
n_adhd_not_taking <- sum(adhd_med_status$not_taking_meds, na.rm = TRUE)
perc_adhd_not_taking <- round(100 * n_adhd_not_taking / n_adhd_total, 1)

cat("\nADHD: not taking medication (blank or 'no')\n")
cat(sprintf("Count: %d\n", n_adhd_not_taking))
cat(sprintf("Percentage among ADHD: %.1f%%\n", perc_adhd_not_taking))

#### ADHD-only summary: stimulant vs non-stimulant medication ----
adhd_med_class <- meds_classified %>%
  filter(group_declared == "ADHD") %>%
  count(medication_class, name = "n_people") %>%
  mutate(percentage = round(100 * n_people / nrow(filter(meds_classified, group_declared == "ADHD")), 1))

cat("\nADHD: stimulant vs non-stimulant medication\n")
print(adhd_med_class %>% filter(medication_class %in% c("Stimulant", "Non-stimulant")))

