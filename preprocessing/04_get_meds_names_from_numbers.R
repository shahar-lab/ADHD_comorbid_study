library(dplyr)
library(writexl)

#### Load processed data ----
load("data/processed_data/df_remove_diagnosis_contradiction.Rdata")

#### Create medication mapping (numbers to English names) ----
# Based on the provided list: 1 = Ritalin SR (first), 18 = Other (last)
meds_mapping <- c(
  "1" = "Ritalin SR",
  "2" = "Ritalin LA",
  "3" = "Concerta",
  "4" = "Atom (Attend, known in the US as Adderall)",
  "5" = "Vyvanse",
  "6" = "Amphetamine Mix",
  "7" = "Atomic - Strattera",
  "8" = "Strattera",
  "9" = "Daytrana",
  "10" = "Desmethylphenidate XR",
  "11" = "Robifen",
  "12" = "Phenidine",
  "13" = "Rephenidate",
  "14" = "Riaventin LA",
  "15" = "Clonirrit",
  "16" = "Clonidine",
  "17" = "Adronax",
  "18" = "Other"
)

#### Replace medication numbers with names (only numbers, keep text as is) ----
df_x_meds_renamed <- df_remove_diagnosis_contradiction %>%
  mutate(
    community_diagnosis_meds_type = as.character(community_diagnosis_meds_type),
    community_diagnosis_meds_type = ifelse(
      community_diagnosis_meds_type %in% names(meds_mapping),
      meds_mapping[community_diagnosis_meds_type],
      community_diagnosis_meds_type
    )
  )

#### Save new dataframe ----
dir.create("data/processed_data", showWarnings = FALSE, recursive = TRUE)
save(df_x_meds_renamed, file = "data/processed_data/df_x_meds_renamed.Rdata")
write_xlsx(df_x_meds_renamed, "data/processed_data/df_x_meds_renamed.xlsx")

message("Replaced medication codes with English names in community_diagnosis_meds_type column (numbers only, text preserved). Saved to data/processed_data/df_x_meds_renamed (.Rdata + .xlsx).")

#### Read the renamed medications file ----
load("data/processed_data/df_x_meds_renamed.Rdata")

#### Classify medications as stimulant or non-stimulant ----
stimulant_meds <- c(
  "Ritalin SR",
  "Ritalin LA",
  "Ritalin",
  "Concerta",
  "Atom (Attend, known in the US as Adderall)",
  "Vyvanse",
  "Amphetamine Mix",
  "Desmethylphenidate XR",
  "Robifen",
  "Phenidine",
  "Rephenidate",
  "Riaventin LA",
  "Attent",
  "Attent XR", 
  "Focalin"
)

non_stimulant_meds <- c(
  "Atomic - Strattera",
  "Strattera",
  "Clonidine",
  "Clonirrit",
  "Adronax"
)

#### Add medication classification column ----
df_x_meds_classified <- df_x_meds_renamed %>%
  mutate(
    med_class = case_when(
      community_diagnosis_meds_type %in% stimulant_meds ~ "Stimulant",
      community_diagnosis_meds_type %in% non_stimulant_meds ~ "Non-stimulant",
      TRUE ~ "Other/Unknown"
    )
  )

#### Calculate and print medication class counts and percentages ----
med_class_summary <- df_x_meds_classified %>%
  filter(
    !is.na(community_diagnosis_meds_type),
    community_diagnosis_meds_type != "",
    tolower(community_diagnosis_meds_type) != "no",
    med_class != "Other/Unknown"
  ) %>%
  group_by(med_class) %>%
  summarise(
    count = n(),
    .groups = "drop"
  ) %>%
  mutate(
    total = sum(count),
    percentage = round(100 * count / total, 1)
  ) %>%
  select(med_class, count, percentage)

cat("\n===== Medication Classification Summary =====\n\n")
cat(sprintf("Total medications (non-empty): %d\n\n", sum(med_class_summary$count)))
print(med_class_summary)
cat("\n")


