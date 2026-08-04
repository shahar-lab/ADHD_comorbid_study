library(dplyr)
library(writexl)

normalize_place_name <- function(x) {
  x <- as.character(x)
  x[is.na(x)] <- ""
  x <- iconv(x, from = "UTF-8", to = "UTF-8", sub = "")
  x <- trimws(x)
  x <- gsub("[[:punct:]]", " ", x)
  x <- gsub("\\s+", " ", x)
  tolower(x)
}

#### Load data ----
load("data/raw_data/df_agg_without_gender_and_undeclared_group.Rdata")

#### Load SES lookup table ----
ses <- read.csv("preprocessing/ses_cbs_2006.xls", stringsAsFactors = FALSE)

ses_lookup <- ses %>%
  transmute(
    lookup_name = normalize_place_name(city_eng),
    rank = as.integer(RANK),
    cluster = as.integer(cluster)
  ) %>%
  bind_rows(
    ses %>%
      transmute(
        lookup_name = normalize_place_name(city_heb),
        rank = as.integer(RANK),
        cluster = as.integer(cluster)
      )
  ) %>%
  distinct(lookup_name, .keep_all = TRUE)

#### Add rank and cluster to the study data ----
df_aff_with_rank_and_cluster <- first_database %>%
  mutate(
    lookup_name = normalize_place_name(place_of_residence_until12yo)
  ) %>%
  left_join(
    ses_lookup,
    by = "lookup_name"
  ) %>%
  select(-lookup_name)

#### Save output ----
dir.create("data/processed_data", showWarnings = FALSE, recursive = TRUE)
save(df_aff_with_rank_and_cluster, file = "data/processed_data/df_aff_with_rank_and_cluster.Rdata")
write_xlsx(df_aff_with_rank_and_cluster, "data/processed_data/df_aff_with_rank_and_cluster.xlsx")

message("Added rank and cluster columns based on SES lookup. Saved to data/processed_data/df_aff_with_rank_and_cluster (.Rdata + .xlsx).")
