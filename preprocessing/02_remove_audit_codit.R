library(dplyr)
library(writexl)

#### Load data ----
load("data/processed_data/df_aff_with_rank_and_cluster.Rdata")

#### Remove rows above AUDIT/CUDIT cutoffs ----
df_remove_audit_cudit <- df_aff_with_rank_and_cluster %>%
  filter(
    !(alcohol_use_cutoff == "above_audit_cutoff"),
    !(cannabis_use_cutoff == "above_cudit_cutoff")
  )

#### Save filtered data ----
dir.create("data/processed_data", showWarnings = FALSE, recursive = TRUE)
save(df_remove_audit_cudit, file = "data/processed_data/df_remove_audit_cudit.Rdata")
write_xlsx(df_remove_audit_cudit, "data/processed_data/df_remove_audit_cudit.xlsx")

message("Removed rows with AUDIT/CUDIT cutoff violations. Saved to data/processed_data/df_remove_audit_cudit (.Rdata + .xlsx).")
