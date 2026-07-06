library(dplyr)
library(writexl)

#### Load data ----
load("data/processed_data/df_remove_audit_cudit.Rdata")

#### Remove contradictions between declared group and DIVA diagnosis ----
df_remove_diagnosis_contradiction <- df_remove_audit_cudit %>%
  filter(
    !(group_declared == "TD" & diva_diagnosis == "meet_diva_criteria"),
    !(group_declared == "ADHD" & diva_diagnosis == "below_diva_criteria")
  )

#### Save filtered data ----
dir.create("data/processed_data", showWarnings = FALSE, recursive = TRUE)
save(df_remove_diagnosis_contradiction, file = "data/processed_data/df_remove_diagnosis_contradiction.Rdata")
write_xlsx(df_remove_diagnosis_contradiction, "data/processed_data/df_remove_diagnosis_contradiction.xlsx")

message("Removed rows with contradictory declared-group and DIVA diagnosis values. Saved to data/processed_data/df_remove_diagnosis_contradiction (.Rdata + .xlsx).")
