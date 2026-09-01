#### LOAD RATIO POSTERIOR DRAWS FROM SIBLING ANALYSES ####
# reads: analysis/*_regression_analysis/artifacts/posterior_draws.rds (9 sibling folders)
# writes: artifacts/ratio_draws_combined.rds

# Sibling analysis folders and their readable plot labels. PATAS was originally
# planned as a 10th measure, but its analysis folder has since been deleted
# from disk (confirmed deliberate by the user), so it is excluded here.
sibling_measures <- tibble(
  folder  = c("aq_regression_analysis", "ocir_regression_analysis", "bdi_regression_analysis",
              "asrs_regression_analysis", "wurs_regression_analysis", "stai_state_regression_analysis",
              "stai_trait_regression_analysis", "pqb_regression_analysis", "icar_regression_analysis"),
  measure = c("AQ", "OCI-R", "BDI", "ASRS", "WURS", "STAI-State", "STAI-Trait", "PQ-B", "ICAR")
)

ratio_draws_list <- vector("list", nrow(sibling_measures))

for (i in seq_len(nrow(sibling_measures))) {
  draws_path <- file.path(project_root, "analysis", sibling_measures$folder[i],
                           "artifacts", "posterior_draws.rds")
  posterior_draws     <- readRDS(draws_path)
  ratio_draws_list[[i]] <- tibble(measure = sibling_measures$measure[i], ratio = posterior_draws$ratio)
}

ratio_draws_combined <- list_rbind(ratio_draws_list)

saveRDS(ratio_draws_combined, file.path(artifacts_dir, "ratio_draws_combined.rds"))
