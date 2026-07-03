print("hello world")

# Convert Excel file to a new Rdata named "first_database"
candidates <- file.path("data", "raw_data", c(
  "df_agg_without_gender_and_undeclared_group.xls",
  "df_agg_without_gender_and_undeclared_group.xlsx"
))
src <- NULL
for (p in candidates) if (file.exists(p)) { src <- p; break }
if (is.null(src)) stop(paste("Source Excel file not found. Checked:", paste(candidates, collapse = ", ")))

dest <- file.path("data", "raw_data", "first_database.Rdata")

if (!requireNamespace("readxl", quietly = TRUE)) {
  install.packages("readxl", repos = "https://cloud.r-project.org")
}

df <- readxl::read_excel(src)
first_database <- df
save(first_database, file = dest)
message("Saved first_database to ", dest)

