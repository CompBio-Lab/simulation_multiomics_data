# Get err rate and fs result data

library(devtools)
library(mixOmics)
# Load all helpers
load_all()

set.seed(1)


sim_data_list <- readRDS("simulation_data_messi_sim.rds")
#sim_data_list <- intersim_datasets

# Dat contains both X and Y
train_diablo <- function(dat) {
  keepX <- createKeepX(dat$X)
  mod <- block.splsda(X=dat$X, Y=dat$Y, keepX=keepX)
  return(mod)
}
#
get_error_rate <- function(mod) {
  cv_obj <- perf(diab_mod)
  err_rate <- cv_obj$AveragedPredict.error.rate
  return(err_rate)
}
dnames <- names(sim_data_list)
# Initialize list to store results of classifying y and feature
# selection classification
err_rate_list <- vector(mode="list", length=length(dnames)) |>
  setNames(dnames)
fs_metric_list <- vector(mode="list", length=length(dnames)) |>
  setNames(dnames)


for (d in dnames) {
  dat <- sim_data_list[[d]]
  diab_mod <- train_diablo(dat)
  #err_rate_list[[d]] <- get_error_rate(diab_mod)
  # Also get the feat selection results
  fs_metric_list[[d]] <- get_fs_summary(diab_mod, dname=d)
}


# ======================================
# More helper


retrieve_sim_params <- function(df, strategy="messi_sim") {
  if (strategy == "messi_sim") {
    into <- c("type", "strategy", "n", "p", "j", "dt", "rho", "rep")
  } else {
    into <- c("type", "strategy", "n", "dt", "rho", "rep")
  }

  df %>%
    tidyr::separate(
      dataset,
      into = into,
      sep = "_") %>%
    dplyr::mutate(
      dplyr::across(n:rep, ~ stringr::str_extract(., "[0-9.]+") %>% as.numeric())
    ) %>%
    #mutate(rep = stringr::str_sort(rep, numeric=TRUE)) %>%
    # Then also sort rep by alpha numeric
    dplyr::select(-type)

}


# ======================================
# # For err rate
# plot_err_rate_data <- err_rate_list %>%
#   purrr::imap_dfr(
#     ~ .x %>%
#       as.data.frame() %>%
#       tibble::rownames_to_column("metric") %>%
#       mutate(dataset = .y)
#   ) %>%
#   as_tibble() %>%
#   #filter(metric == "Overall.BER") %>%
#   dplyr::select(-comp1) %>%
#   retrieve_sim_params()




plot_fs_metric_data <- fs_metric_list %>%
  purrr::imap_dfr(
    ~ .x %>%
      as.data.frame() %>%
      mutate(dataset = .y) %>%
      as_tibble()
  ) %>%
  group_by(dataset) %>%
  #summarize(accuracy = (TP + TN) / N) %>%
  summarize(sensitivity = TP / (TP + FN),

            # Specificity
            specificity = TN / (TN + FP),

            # Precision
            precision = TP / (TP + FP),

            # Accuracy
            accuracy = (TP + TN) / N) %>%
  retrieve_sim_params()

# Then write out to file
#write.csv(plot_err_rate_data, file = "data/err_rate_data.csv", row.names = F)
write.csv(plot_fs_metric_data, file = "data/fs_metric_data.csv", row.names = F)
