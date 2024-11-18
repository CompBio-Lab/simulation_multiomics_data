# library(tidyverse)
#
# library(mixOmics)
# source("helpers.R")
# simulate_multiomics_data_list <- function(n, p_per_layer, signal_to_noise, num_layers) {
#   # Validate inputs
#   if (signal_to_noise < 0 || signal_to_noise > 1) {
#     stop("Signal-to-noise ratio must be between 0 and 1.")
#   }
#
#   # List to store data for each layer and the response variable
#   data_list <- list()
#
#   for (layer in 1:num_layers) {
#     # Number of signal and noise predictors for the current layer
#     num_signal <- round(p_per_layer * signal_to_noise)
#     num_noise <- p_per_layer - num_signal
#
#     # Generate signal predictors for the current layer
#     if (num_signal > 0) {
#       signal_predictors <- matrix(rnorm(n * num_signal), nrow = n, ncol = num_signal)
#       colnames(signal_predictors) <- paste0("layer_", layer, "_true_var_", 1:num_signal)
#     } else {
#       signal_predictors <- NULL
#     }
#
#     # Generate noise predictors for the current layer
#     if (num_noise > 0) {
#       noise_predictors <- matrix(rnorm(n * num_noise), nrow = n, ncol = num_noise)
#       colnames(noise_predictors) <- paste0("layer_", layer, "_noise_var_", 1:num_noise)
#     } else {
#       noise_predictors <- NULL
#     }
#
#     # Combine signal and noise predictors for the current layer
#     predictors <- cbind(signal_predictors, noise_predictors)
#
#     # Store the current layer's data in the list
#     data_list[[paste0("layer_", layer)]] <- predictors
#   }
#
#   # Number of total predictors across all layers
#   combined_predictors <- do.call(cbind, data_list)
#
#   # Assign coefficients to signal predictors (signal variables have coefficient 1, noise variables have coefficient 0)
#   total_predictors <- ncol(combined_predictors)
#   beta <- rep(0, total_predictors)
#   colnames_combined <- colnames(combined_predictors)
#
#   # Assign coefficient 1 to all signal variables (those containing "true_var" in their name)
#   signal_cols <- grep("true_var", colnames_combined)
#   beta[signal_cols] <- 1
#
#   # Compute the linear predictor (eta) for all predictors
#   eta <- combined_predictors %*% beta
#   prob_y1 <- 1 / (1 + exp(-eta)) # Logistic transformation
#
#   # Sample binary response variable Y from Bernoulli distribution
#   y <- rbinom(n, size = 1, prob = prob_y1)
#
#   # Store the response variable in the list
#   data_list$y <- y
#
#   return(data_list)
# }
#
#
# p_per_layer = seq(100, 200, 500)
# signal_to_noise <- c(0, 0.25, 0.5, 0.75, 1)
# num_layers <- 3
# n_values <- seq(20, 200, by = 10)
#
# # Generate all combinations of paramseters
# params_grid <- expand.grid(n = n_values,
#                           p_per_layer = p_per_layer,
#                           signal_to_noise = signal_to_noise,
#                           num_layers = num_layers)
#
#
# sim.apply_way <- function(params_grid) {
#   results <- do.call(rbind, lapply(1:nrow(params_grid), function(i) {
#     # Extract paramseters for this iteration
#     params <- params_grid[i, ]
#     data <- simulate_multiomics_data_list(
#       n=params$n,
#       p_per_layer = params$p_per_layer,
#       signal_to_noise = params$signal_to_noise,
#       num_layers = params$num_layers
#      )
#     diab_mod <- block.splsda(X=data[1:params$num_layers], Y=data$y)
#     pred_obj <- predict(diab_mod, newdata=data[1:params$num_layers])
#     y_pred <- ifelse(pred_obj$AveragedPredict[, , "dim2"][, 2] > 0.5, 1, 0)
#     accuracy <- mean(y_pred == data$y)
#     # Combine results and summary statistics
#     data.frame(
#       n = params$n,
#       p = params$p_per_layer,
#       signal_to_noise = params$signal_to_noise,
#       accuracy = accuracy
#     )
#   }))
#   return(results)
# }
#
# results <- sim.apply_way(params_grid)
#
#
# library(MASS)
# ?mvrnorm
#
# #results |> write.csv("dummy_result_simulated_multiomics.csv", row.names = F)
#
# # # Plot the results
# # p_labels <- paste0("P = ", results$p |> unique())
# # names(p_labels) <- results$p |> unique()
# # sn_labels <- paste0("SN ratio = ", results$signal_to_noise |> unique())
# # names(sn_labels) <- results$signal_to_noise |> unique()
# #
# # # Accuracy plot?
# # results %>%
# #   mutate(p_signal = paste("p =", p, ", S/N =", signal_to_noise)) %>%
# #   mutate(
# #     p_signal = factor(
# #       p_signal,
# #       levels = unique(p_signal[order(p, signal_to_noise)])
# #     )
# #   ) %>%
# #   ggplot(aes(x = n, y = accuracy,
# #              color = p_signal)) +
# #   geom_line() +
# #   geom_point() +
# #   labs(title = "Effect of Sample Size (n) on Accuracy") +
# #   #scale_color_manual(values = custom_colors) +
# #   facet_grid(
# #     p ~ signal_to_noise,
# #     labeller = labeller(p = p_labels, signal_to_noise = sn_labels),
# #     scales = "free")  # Custom labels for facets
