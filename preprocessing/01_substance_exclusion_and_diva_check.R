library(writexl)

#### Load data ----
load("data/raw_data/df_agg_without_gender_and_undeclared_group.Rdata")

#### Count and remove participants above AUDIT / CUDIT cutoff ----
tbl_substance <- df_agg |>
  group_by(group_declared) |>
  summarise(
    above_audit  = sum(alcohol_use_cutoff  == "above_audit_cutoff",  na.rm = TRUE),
    above_cudit  = sum(cannabis_use_cutoff == "above_cudit_cutoff",  na.rm = TRUE),
    above_both   = sum(
      alcohol_use_cutoff  == "above_audit_cutoff" &
        cannabis_use_cutoff == "above_cudit_cutoff",
      na.rm = TRUE
    ),
    .groups = "drop"
  )

message("\nParticipants above AUDIT, CUDIT, or both cutoffs, by group_declared:")
print(tbl_substance)

df_agg <- df_agg |>
  filter(
    is.na(alcohol_use_cutoff)  | alcohol_use_cutoff  != "above_audit_cutoff",
    is.na(cannabis_use_cutoff) | cannabis_use_cutoff != "above_cudit_cutoff"
  )

message("After substance-use exclusion: N = ", nrow(df_agg))

#### Report DIVA vs. declared-group discordance (no removal) ----
tbl_diva_mismatch <- df_agg |>
  filter(!is.na(diva_group)) |>
  group_by(group_declared) |>
  summarise(
    n_with_diva  = n(),
    n_mismatch   = sum(as.character(diva_group) != group_declared, na.rm = TRUE),
    pct_mismatch = round(100 * n_mismatch / n_with_diva, 1),
    .groups = "drop"
  )

message("\nDIVA vs. declared-group discordance (participants with DIVA data only):")
print(tbl_diva_mismatch)

#### Save filtered aggregate ----
dir.create("data/processed_data", showWarnings = FALSE, recursive = TRUE)
save(df_agg, file = "data/processed_data/df_agg.Rdata")
write_xlsx(df_agg, "data/processed_data/df_agg.xlsx")

message("\nSaved filtered aggregate to data/processed_data/df_agg (.Rdata + .xlsx). N = ", nrow(df_agg))
