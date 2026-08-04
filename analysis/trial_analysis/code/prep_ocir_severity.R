#### PREP OCI-R SEVERITY DATA ####

# Single clinical cutoff (standard OCI-R threshold for clinically significant
# OCD symptoms). right = FALSE makes intervals [-Inf, cutoff) and
# [cutoff, Inf), so the cutoff value itself falls in the "at or above" category.
severity_cutoff <- 21
severity_labels <- c("Below clinical cutoff", "At or above clinical cutoff")

# Named df_ocir_severity (not df_ocir) to avoid colliding with the local
# df_ocir object built inside plot_selfreport_dothistograms.R.
# Theoretical range is 0-72 (min = 0), so the zero-min shortcut used by BDI
# (x / max * 100) is mathematically valid here too.
df_ocir_severity <- df |>
  filter(!is.na(ocir)) |>
  mutate(
    ocir_transformed = (ocir / 72) * 100,
    ocir_severity = cut(ocir, breaks = c(-Inf, severity_cutoff, Inf),
                         right = FALSE, labels = severity_labels)
  )

cat("Rows with non-missing OCI-R (ADHD/TD only):", nrow(df_ocir_severity), "\n")
