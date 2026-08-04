#### PREP AQ SEVERITY DATA ####

# Single clinical cutoff (standard AQ threshold for clinically significant
# autistic traits). right = FALSE makes intervals [-Inf, cutoff) and
# [cutoff, Inf), so the cutoff value itself falls in the "at or above" category.
severity_cutoff <- 32
severity_labels <- c("Below clinical cutoff", "At or above clinical cutoff")

# Named df_aq_severity (not df_aq) to avoid colliding with the local df_aq
# object built inside plot_selfreport_dothistograms.R.
# Theoretical range is 0-50 (min = 0), so the zero-min shortcut used by BDI
# (x / max * 100) is mathematically valid here too.
df_aq_severity <- df |>
  filter(!is.na(aq)) |>
  mutate(
    aq_transformed = (aq / 50) * 100,
    aq_severity = cut(aq, breaks = c(-Inf, severity_cutoff, Inf),
                       right = FALSE, labels = severity_labels)
  )

cat("Rows with non-missing AQ (ADHD/TD only):", nrow(df_aq_severity), "\n")
