



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


# USE LINE PLOT HERE TO SHOW TREND OF DT
# plot_err_rate_data %>%
#   filter(metric=="Overall.BER") %>%
#   ggplot(aes(x=dt, y=comp2, color=factor(dt), group=factor(dt))) +
#   geom_point() +
#   geom_line() +
#   theme_bw()
#


# plot_err_rate_data %>%
#     filter(metric == "Overall.BER") %>%
#     #filter(dt == 30, rho == 1) %>%
#     ggplot(aes(x=n, y=comp2, color=interaction(rho, dt))) +
#     geom_boxplot() +
#     facet_grid(rho ~ dt, labeller = label_both) +
#     labs(y="Balanced Error Rate", title="Error Rate") +
#     theme_bw()


# =======================================
# For feature selection results
# plot_fs_metric_data <- fs_metric_list %>%
#   purrr::imap_dfr(
#     ~ .x %>%
#       as.data.frame() %>%
#       mutate(dataset = .y) %>%
#       as_tibble()
#   ) %>%
#   group_by(dataset) %>%
#   #summarize(accuracy = (TP + TN) / N) %>%
#   summarize(sensitivity = TP / (TP + FN),
#
#             # Specificity
#             specificity = TN / (TN + FP),
#
#             # Precision
#             precision = TP / (TP + FP),
#
#             # Accuracy
#             accuracy = (TP + TN) / N) %>%
#   retrieve_sim_params()


# new_plot_fs_metric_data <- plot_fs_metric_data %>%
#   mutate(dataset_group = stringr::str_remove(dataset, "_rep-\\d+$")) %>%
#   mutate(sensitivity = TP / (TP + FN),
#
#             # Specificity
#             specificity = TN / (TN + FP),
#
#             # Precision
#             precision = TP / (TP + FP),
#
#             # Accuracy
#             accuracy = (TP + TN) / N
#             ) %>%
#   dplyr::select(dataset_group:accuracy) %>%
#   group_by(dataset_group) %>%
#   summarize(sensitivity = mean(sensitivity)) %>%
#   tidyr::separate(
#     dataset_group,
#     into = c("type", "strategy", "n", "p", "j", "dt", "rho"),
#     sep = "_") %>%
#   dplyr::mutate(
#     dplyr::across(n:rho, ~ stringr::str_extract(., "[0-9.]+") %>% as.numeric())
#   ) %>%
#   #mutate(rep = stringr::str_sort(rep, numeric=TRUE)) %>%
#   # Then also sort rep by alpha numeric
#   dplyr::select(-type)
#
#
# plot_fs_metric_data %>%
#   ggplot(aes)
# plot_fs_metric_data %>%
#   tidyr::separate(
#     dataset,
#     into = c("type", "strategy", "n", "p", "j", "dt", "rho"),
#     sep = "_") %>%
#   dplyr::mutate(
#     dplyr::across(n:dt, ~ stringr::str_extract(., "[0-9.]+") %>% as.numeric())
#   ) %>%
#%>% retrieve_sim_params()
#
# fs_metric_plot <- plot_fs_metric_data %>%
#   ggplot(aes(x=factor(n), y=sensitivity, color=interaction(rho, dt))) +
#   geom_point() +
#   geom_line(aes(group=1)) +
#   facet_grid(rho ~ dt, labeller = label_both, scales = "free") +
#   theme_bw() +
#   labs(title="Feature Selection")

#fs_metric_plot

# plot_fs_metric_data
#
# plot_fs_metric_data %>%
#   mutate(dt = as.factor(dt)) %>%
#   ggplot(aes(x=dt, y=sensitivity)) +
#   geom_boxplot(fill = "lightblue", alpha = 0.7) +
#   #geom_jitter(width = 0.1, alpha = 0.7) +
#   theme_bw() +
#   #scale_x_continuous(breaks = seq(0, 200, by = 10)) +
#   scale_y_continuous(breaks = seq(0, 1, by = 0.1)) +
#   geom_hline(yintercept = 0.5, color="red") +
#   geom_hline(yintercept = 0.75, color ="orange") +
#   labs(title="Feature Selection sensitivity for messi_sim, with p = 3000")
#

# plot_fs_metric_data %>%
#   ggplot(aes(y=sensitivity, x = factor(dt))) +
#   geom_boxplot() +
#   theme_bw()
