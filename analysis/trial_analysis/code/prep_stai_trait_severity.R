#### PREP STAI-TRAIT SEVERITY DATA ####

# Single clinical cutoff (standard STAI-Trait elevated-anxiety threshold).
# right = FALSE makes intervals [-Inf, cutoff) and [cutoff, Inf), so the
# cutoff value itself falls in the "at or above" category.
severity_cutoff <- 40
severity_labels <- c("Below clinical cutoff", "At or above clinical cutoff")

# Named df_stai_trait_severity (not df_stai_trait) to avoid colliding with the
# local df_stai_trait object built inside plot_selfreport_dothistograms_2.R.
# This dataset uses a 0-3-per-item STAI scoring convention (not the standard
# 1-4-per-item convention), giving an empirical range of 0-60, not the
# standard STAI-Trait 20-80 range. Confirmed against observed data (min = 0)
# and matches the already-approved raw stripplot (plot_stai_trait_stripplot_raw.R),
# which uses scale_y_continuous(limits = c(0, 60)). Because the min is
# genuinely 0 here, like BDI/OCI-R/AQ this can just divide by max: x / 60 * 100.
df_stai_trait_severity <- df |>
  filter(!is.na(stai_trait)) |>
  mutate(
    stai_trait_transformed = (stai_trait / 60) * 100,
    stai_trait_severity = cut(stai_trait, breaks = c(-Inf, severity_cutoff, Inf),
                               right = FALSE, labels = severity_labels)
  )

cat("Rows with non-missing STAI-Trait (ADHD/TD only):", nrow(df_stai_trait_severity), "\n")
