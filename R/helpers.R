# # These are helpers
#
# get_top_bottom_counts_df <- function(feats_df, total_feat_counts_df) {
#   counts_df <- feats_df %>%
#     group_by(method, dataset) %>%
#     arrange(desc(abs(coef)), .by_group = TRUE) %>%
#     group_map(~ {
#       matched <- total_feat_counts_df %>%
#         filter(method == .y$method, dataset == .y$dataset)
#
#       top_num <- matched %>% filter(feature_type == "truth") %>% pull(n_total)
#       bottom_num <- matched %>% filter(feature_type == "noise") %>% pull(n_total)
#
#       # If there are no "truth" or "noise" features, set top_num or bottom_num to 0
#       if (length(top_num) == 0) top_num <- 0
#       if (length(bottom_num) == 0) bottom_num <- 0
#
#       # Slicing the top features (only if there are "truth" features)
#       if (top_num > 0) {
#         top_sliced <- slice_head(.x, n = top_num) %>%
#           count(feature_type, name = "n_selected") %>%
#           mutate(category = "top_truth", top_num = top_num)
#       } else {
#         top_sliced <- data.frame(feature_type = character(0), n_selected = integer(0), category = character(0), top_num = integer(0))
#       }
#
#       # Slicing the bottom features (only if there are "noise" features)
#       if (bottom_num > 0) {
#         bottom_sliced <- slice_tail(.x, n = bottom_num) %>%
#           count(feature_type, name = "n_selected") %>%
#           mutate(category = "bottom_noise", bottom_num = bottom_num)
#       } else {
#         bottom_sliced <- data.frame(feature_type = character(0), n_selected = integer(0), category = character(0), bottom_num = integer(0))
#       }
#
#       binded <- bind_rows(top_sliced, bottom_sliced)
#       output <- bind_cols(.y, binded)
#       return(output)
#     }) %>%
#     bind_rows() %>%
#     ungroup()
#
#   return(counts_df)
# }
#
# get_total_feat_counts_df <- function(data, i) {
#   data.frame(
#     method = rep("glm", ncol(data)),
#     dataset = rep(paste0("dataset_", i), ncol(data)),
#     feature = colnames(data),
#     stringsAsFactors = FALSE
#   ) %>%
#     # Remove y
#     filter(feature != "y") %>%
#     mutate(feature_type = ifelse(str_detect(feature, "noise"), "noise", "truth")) %>%
#     group_by(method, dataset, feature_type) %>%
#     summarize(n_total = n(), .groups = "drop") %>%
#     ungroup()
# }
#
# get_extracted_feats_df <- function(coefs, i) {
#   data.frame(
#     method = rep("glm", length(coefs)),
#     dataset = rep(paste0("dataset_", i), length(coefs)),
#     feature = names(coefs),
#     coef = coefs,
#     stringsAsFactors = FALSE
#   ) %>%
#     mutate(feature_type = ifelse(str_detect(feature, "noise"), "noise", "truth"))
# }
#
#
# get_fs_stats <- function(top_bottom_counts) {
#   top_bottom_counts %>%
#     summarise(
#       TP = sum(n_selected[category == "top_truth" & feature_type == "truth"], na.rm = TRUE),
#       FP = sum(n_selected[category == "top_truth" & feature_type == "noise"], na.rm = TRUE),
#       FN = sum(n_selected[category == "bottom_noise" & feature_type == "truth"], na.rm = TRUE),
#       TN = sum(n_selected[category == "bottom_noise" & feature_type == "noise"], na.rm = TRUE),
#       N = sum(TP, TN, FP, FN),
#       .groups = "drop"
#     ) %>%
#     summarise(
#       accuracy = (TP + TN) / N,
#       recall = TP / (TP + FN),
#       specificity = TN / (TN + FP),
#       precision = TP / (TP + FP),
#       f1_score = 2 * precision * recall / (precision + recall)
#     )
# }
#
#
#
#
# # sim.apply_way <- function(param_grid) {
# #   results <- vector("list", nrow(param_grid))  # Pre-allocate a list
# #
# #   for (i in 1:nrow(param_grid)) {
# #     # Extract parameters for this iteration
# #     params <- param_grid[i, ]
# #     # Simulate data and train model
# #     data <- simulate_classification_data(params$n, params$p, params$signal_to_noise)
# #     model <- glm(y ~ ., data = data, family = binomial)
# #     predictions <- ifelse(predict(model, type = "response") > 0.5, 1, 0)
# #
# #     # Store results for this combination
# #     results[[i]] <- data.frame(n = params$n,
# #                                p = params$p,
# #                                signal_to_noise = params$signal_to_noise,
# #                                accuracy = mean(predictions == data$y))
# #   }
# #
# #   # Combine results into a single data frame and return it
# #   do.call(rbind, results)
# # }
