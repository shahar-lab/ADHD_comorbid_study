# Load the processed data containing df_remove_diagnosis_contradiction
script_dir <- {
  frame_file <- tryCatch(normalizePath(sys.frame(1)$ofile), error = function(e) NULL)
  if (!is.null(frame_file)) {
    dirname(frame_file)
  } else {
    args <- commandArgs(trailingOnly = FALSE)
    file_arg <- grep("^--file=", args, value = TRUE)
    if (length(file_arg) > 0) {
      dirname(sub("^--file=", "", file_arg[1]))
    } else {
      getwd()
    }
  }
}

data_file <- normalizePath(file.path(script_dir, "..", "data", "processed_data", "df_remove_diagnosis_contradiction.Rdata"), mustWork = FALSE)
if (!file.exists(data_file)) {
  stop(paste0("Cannot find data file: ", data_file, "\n",
              "Run this script from the project root or use a full path to the data file."))
}
load(file = data_file)

# Use the loaded dataframe that contains the declared group labels and scores
if (!exists("df_remove_diagnosis_contradiction")) {
  stop("Expected object 'df_remove_diagnosis_contradiction' not found after loading the RData file.")
}

df <- df_remove_diagnosis_contradiction

# Ensure the declared group variable is available
if (!"group_declared" %in% names(df)) {
  stop("Expected column 'group_declared' not found in the data frame.")
}

# Select the variables for average comparison
score_vars <- c("bdi", "stai", "stai_trait", "stai_state",
                "aq", "icar", "ocir", "patas_sum", "pqb")
missing_vars <- setdiff(score_vars, names(df))
if (length(missing_vars) > 0) {
  stop(paste("Missing expected score columns:", paste(missing_vars, collapse = ", ")))
}

if (!"diva_diagnosis_type" %in% names(df)) {
  stop("Expected column 'diva_diagnosis_type' not found in the data frame.")
}

# Filter only ADHD and TD participants for the declared group comparison
df_compare <- subset(df, group_declared %in% c("ADHD", "TD"))

# Compute group means using NA removal
group_means <- aggregate(df_compare[score_vars],
                         by = list(declared_group = df_compare$group_declared),
                         FUN = function(x) mean(x, na.rm = TRUE))

# Convert the results so each variable has ADHD and TD in the same row
group_means_long <- reshape(group_means,
                            idvar = "declared_group",
                            varying = score_vars,
                            v.names = "mean",
                            times = score_vars,
                            timevar = "score",
                            direction = "long")

wide_means <- reshape(group_means_long,
                      idvar = "score",
                      timevar = "declared_group",
                      direction = "wide")

# Print the results with one category per line
cat("Average scores by declared group (ADHD vs TD):\n")
for (i in seq_len(nrow(wide_means))) {
  row <- wide_means[i, ]
  cat(sprintf("%s: ADHD = %.3f, TD = %.3f\n",
              as.character(row$score),
              row$mean.ADHD,
              row$mean.TD))
}

# Filter to ADHD cases only and compute averages by diva_diagnosis_type
adhd_only <- subset(df, group_declared == "ADHD")
subgroups <- c("combined", "primary_inattentive", "primary_hyperactive/impulsive")
adhd_subgroup <- subset(adhd_only, diva_diagnosis_type %in% subgroups)

subgroup_means <- aggregate(adhd_subgroup[score_vars],
                            by = list(diva_diagnosis_type = adhd_subgroup$diva_diagnosis_type),
                            FUN = function(x) mean(x, na.rm = TRUE))

# Ensure consistent ordering for the expected diva diagnosis types
subgroup_means$diva_diagnosis_type <- factor(subgroup_means$diva_diagnosis_type,
                                              levels = subgroups)
subgroup_means <- subgroup_means[order(subgroup_means$diva_diagnosis_type), ]

# Print the ADHD-only averages by diva_diagnosis_type, one score per line
cat("\nAverage scores for ADHD participants by diva_diagnosis_type:\n")
for (score in score_vars) {
  values <- subgroup_means[[score]]
  cat(sprintf("%s: combined = %.3f, primary_inattentive = %.3f, primary_hyperactive/impulsive = %.3f\n",
              score,
              values[1],
              values[2],
              values[3]))
}
