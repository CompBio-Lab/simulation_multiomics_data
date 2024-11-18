# simulate_multiomics <- function(n, p, n_imp, j=3, rho=0.5) {
#   # Cor / Cov mat
#
#   Sigma <- matrix(rho,nrow=j,ncol=j)
#   diag(Sigma) <- 1
#   # Each col is view's pc
#   pcs <- mvrnorm(n = n, mu = rep(0, 3), Sigma=Sigma)
#
#   # Shift the first n_imp in their pcs and get the y from there
#   pcs[1:n_imp, ] <- pcs[1:n_imp, ] + matrix(rnorm(n=n_imp*j, mean=3),
#                                             nrow=n_imp, ncol=j)
#   # Create the y variable here, very dummy
#   y <- c(rep(1, n_imp), rep(0, n - n_imp))
#   # Create weights W being a j x p matrix, where
#   W <- matrix(runif(p * j, min = -3, max=3), nrow = j, ncol=p)  |>
#     apply(MARGIN=1, FUN=function(x) x / norm(as.matrix(x))) |>
#     t()
#   # Make sure norm of each column is 1 now ====================== ^
#   # Apply "individual" mat multiply for each column x row
#   omic_names <- c("omic1", "omic2", "omic3")
#
#   X_list <- lapply(seq_along(omic_names), function (index) {
#     omic <- pcs[, index, drop=FALSE] %*% W[index, , drop=FALSE]
#     # And add some random noise to each matrix
#     omic <- omic + matrix(rnorm(nrow(omic) * ncol(omic), mean=0, sd=1),
#                           nrow = nrow(omic),
#                           ncol = ncol(omic))
#     omic_name <- omic_names[index]
#     colnames(omic) <- paste(omic_name, "var", 1:ncol(omic),  sep="_")
#     return(omic)
#   })
#   names(X_list) <- omic_names
#   return(list(X=X_list, Y=y))
# }
#
#
#
# # Make sure norm of each column is 1 now ====================== ^
#
# # Fit model ant get metric
# fit_predict <- function(data) {
#   diab_mod <- block.splsda(X=data$X, Y=data$Y)
#   pred_obj <- predict(diab_mod, newdata=data$X)
#   y_pred <- ifelse(pred_obj$AveragedPredict[, , "dim2"][, 2] > 0.5, 1, 0)
#   return(y_pred)
# }
#
#
# sim.apply_way <- function(params_grid) {
#   results <- do.call(rbind, lapply(1:nrow(params_grid), function(i) {
#     # Extract paramseters for this iteration
#     params <- params_grid[i, ]
#     print(i)
#     data_list <- simulate_multiomics(
#       n=params$n,
#       p=params$p,
#       n_imp=params$n_imp,
#       rho=params$rho
#     )
#     y_pred <- fit_predict(data_list)
#     accuracy <- mean(y_pred == data_list$Y)
#     # Combine results and summary statistics
#     data.frame(
#       n = params$n,
#       p = params$p,
#       n_imp=params$n_imp,
#       rho=params$rho,
#       accuracy = accuracy
#     )
#   }))
#   return(results)
# }
#
#
# n_vals <- seq(20, 100, by = 10)
# n_imp_vals <- seq(5, 50, 10)
# p_vals <- c(100)
# rho_vals <- c(0, 0.2, 0.5, 0.7, 0.9)
#
# # Generate all combinations of paramseters
# params_grid <- expand.grid(n = n_vals,
#                            n_imp = n_imp_vals,
#                            p = p_vals,
#                            rho = rho_vals) |>
#   filter(n_imp < n)
#
#
#
# results <- sim.apply_way(params_grid)
#
# results %>%
#   mutate(N_imp_Rho = paste("N_imp =", n_imp, ", Rho =", rho)) %>%
#   mutate(
#     N_imp_Rho = factor(
#       N_imp_Rho,
#       levels = unique(N_imp_Rho[order(n_imp, rho)])
#     )
#   ) %>%
#   ggplot(aes(x=n, y=accuracy, color=N_imp_Rho)) +
#   geom_point() +
#   geom_line() +
#   theme_bw() +
#   facet_grid(
#     n_imp ~ rho,
#     scales="free")
#
#
