#### FIT ONE ROC CURVE PER QUESTIONNAIRE ####
# reads: artifacts/df_full.rds · writes: artifacts/roc_objects.rds, artifacts/roc_stats.rds

df_full <- readRDS(file.path(artifacts_dir, "df_full.rds"))

# ADHD is always the positive/case class, TD the negative/control class
# (levels = c("TD", "ADHD") below). The 9 symptom/psychopathology questionnaires
# use direction = "<" (TD scores lower than ADHD), matching their known scoring
# convention. ICAR is a cognitive-ability measure with no a priori symptom
# direction toward ADHD, so it uses direction = "auto"; the direction pROC
# actually found is recorded in direction_used/direction_label below.
questionnaires <- tibble(
  questionnaire     = c("aq", "asrs", "wurs", "bdi", "ocir", "pqb",
                         "stai_state", "stai_trait", "patas_sum", "icar"),
  label             = c("AQ", "ASRS", "WURS", "BDI", "OCI-R", "PQ-B",
                         "STAI-State", "STAI-Trait", "PATAS", "ICAR"),
  direction         = c("<", "<", "<", "<", "<", "<", "<", "<", "<", "auto"),
  literature_cutoff = c(NA, 40, 36, 14, 21, 7, 40, 44, NA, NA)
)

roc_objects <- list()
roc_stats_rows <- list()

for (i in seq_len(nrow(questionnaires))) {
  q_name <- questionnaires$questionnaire[i]
  q_dir  <- questionnaires$direction[i]

  df_q <- df_full |> filter(!is.na(.data[[q_name]]))
  n_total <- nrow(df_q)
  n_adhd  <- sum(df_q$group_declared == "ADHD")
  n_td    <- sum(df_q$group_declared == "TD")

  roc_obj <- roc(response = df_q$group_declared, predictor = df_q[[q_name]],
                 levels = c("TD", "ADHD"), direction = q_dir, quiet = TRUE)
  roc_objects[[q_name]] <- roc_obj

  auc_val <- as.numeric(auc(roc_obj))
  ci_val  <- as.numeric(ci.auc(roc_obj))          # 2.5%, AUC, 97.5%
  se      <- sqrt(var(roc_obj))
  z_stat  <- (auc_val - 0.5) / se
  p_val   <- 2 * pnorm(-abs(z_stat))

  best <- coords(roc_obj, x = "best", best.method = "youden",
                 ret = c("threshold", "sensitivity", "specificity", "ppv", "npv"))
  if (is.data.frame(best) && nrow(best) > 1) best <- best[1, ]  # tie: keep pROC's first

  # direction actually used for ADHD-vs-TD: "<" means TD < ADHD (higher score/value
  # for ADHD), ">" means TD > ADHD (lower score/value for ADHD)
  direction_used  <- roc_obj$direction
  direction_label <- if (direction_used == "<") "higher associated with ADHD" else "lower associated with ADHD"

  roc_stats_rows[[q_name]] <- tibble(
    questionnaire     = q_name,
    label             = questionnaires$label[i],
    n                 = n_total,
    n_adhd            = n_adhd,
    n_td              = n_td,
    auc               = auc_val,
    ci_low            = ci_val[1],
    ci_high           = ci_val[3],
    p_value           = p_val,
    youden_threshold  = as.numeric(best$threshold),
    sensitivity       = as.numeric(best$sensitivity),
    specificity       = as.numeric(best$specificity),
    ppv               = as.numeric(best$ppv),
    npv               = as.numeric(best$npv),
    literature_cutoff = questionnaires$literature_cutoff[i],
    direction_used    = direction_used,
    direction_label   = direction_label
  )
}

roc_stats <- bind_rows(roc_stats_rows)

saveRDS(roc_objects, file.path(artifacts_dir, "roc_objects.rds"))
saveRDS(roc_stats, file.path(artifacts_dir, "roc_stats.rds"))

cat("ICAR direction found by pROC (auto):", roc_stats$direction_label[roc_stats$questionnaire == "icar"], "\n")
