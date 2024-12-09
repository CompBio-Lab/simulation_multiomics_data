sim_data_list <- readRDS("simulation_data_list_format.rds")

# Dat contains both X and Y
train_diablo <- function(dat) {
  keepX <- createKeepX(dat$X)
  mod <- block.splsda(X=dat$X, Y=dat$Y, keepX=keepX)
  return(mod)
}


get_error_rate <- function(mod) {
  cv_obj <- perf(diab_mod)
  err_rate <- cv_obj$AveragedPredict.error.rate
  return(err_rate)
}


dnames <- names(sim_data_list)
# Initialize list to store results of classifying y and feature
# selection classification
#err_rate_list <- vector(mode="list", length=length(dnames)) |>
#  setNames(dnames)
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


retrieve_sim_params <- function(df) {
  df %>%
    tidyr::separate(
      dataset,
      into = c("type", "strategy", "n", "p", "j", "dt", "rho"),
      sep = "_") %>%
    dplyr::mutate(
      dplyr::across(n:rho, ~ stringr::str_extract(., "[0-9.]+") %>% as.numeric())
    ) %>%
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
#   select(-comp1) %>%
#   retrieve_sim_params()
# # This plot err rate
# err_rate_plot <- plot_err_rate_data %>%
#   filter(metric == "Overall.ER") %>%
#   #filter(dt == 30, rho == 1) %>%
#   ggplot(aes(x=n, y=comp2, color=interaction(rho, dt))) +
#   geom_point() +
#   geom_line() +
#   facet_grid(rho ~ dt, labeller = label_both) +
#   labs(y="Balanced Error Rate", title="Error Rate") +
#   theme_bw()




# =======================================
# For feature selection results
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


# plot_fs_metric_data %>%
#   tidyr::separate(
#     dataset,
#     into = c("type", "strategy", "n", "p", "j", "dt", "rho"),
#     sep = "_") %>%
#   dplyr::mutate(
#     dplyr::across(n:dt, ~ stringr::str_extract(., "[0-9.]+") %>% as.numeric())
#   ) %>%
#%>% retrieve_sim_params()

fs_metric_plot <- plot_fs_metric_data %>%
  ggplot(aes(x=factor(n), y=sensitivity, color=interaction(rho, dt))) +
  geom_point() +
  geom_line(aes(group=1)) +
  facet_grid(rho ~ dt, labeller = label_both, scales = "free") +
  theme_bw() +
  labs(title="Feature Selection")


plot_fs_metric_data %>%
  ggplot(aes(y=sensitivity, x = factor(dt))) +
  geom_boxplot() +
  theme_bw()
