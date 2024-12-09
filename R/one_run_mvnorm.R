# # Params
# set.seed(10)
# n <- 50
# p <- 100
# p_imp <- 30
# j <- 3 # Number of block
# rho <- 0
# # No --> 5
# # Low --> 10
# # Medium --> 20
# # High --> 30
# dt <-  2 # Sh/ould be low medium high
#
#
# simulating_omics <- function(n, p, p_imp, j, rho, dt, identifier, add_dt=TRUE) {
#   # This would be the output_list init
#   output_list <- list()
#   # Cor / Cov mat
#   Sigma <- matrix(rho,nrow=j,ncol=j)
#   diag(Sigma) <- 1
#
#   # Each col is view's pc
#   pcs <- mvrnorm(n = 2*n, mu = rep(0, 3), Sigma=Sigma)
#
#   # Shift the first 50 n in their pcs and get the y from there
#   if (add_dt) {
#     pcs[1:n, ] <- pcs[1:n, ] + dt
#     y <- c(rep(1, n), rep(0, n))
#     output_list[["y"]] <- y
#   }
#   #
#   # Create weights W being a j x p matrix, where
#   W <- matrix(runif(p * j, min = -3, max=3), nrow = j, ncol=p)  |>
#     apply(MARGIN=1, FUN=function(x) x / norm(as.matrix(x))) |>
#     t()
#
#
#   # Then now each row's norm is 1
#   #norm(W[1, ] |> as.matrix())
#   # Make sure norm of each column is 1 now ====================== ^
#
#   # Apply "individual" mat multiply for each column x row
#   omic_names <- c("omic1", "omic2", "omic3")
#
#   X_list <- lapply(seq_along(omic_names), function (index) {
#     omic <- pcs[, index, drop=FALSE] %*% W[index, , drop=FALSE]
#     omic_name <- omic_names[index]
#     # Then let the first 20 columns of each omic to be "useful" pred
#     omic[, 1:p_imp] <- omic[, 1:p_imp] + 2
#     colnames(omic) <- paste(identifier, omic_name, "var", 1:ncol(omic),  sep="_")
#     #colnames(omic)[1:p_imp] <- paste(omic_name, "imp_var", 1:p_imp, sep="_")
#     return(omic)
#   })
#   names(X_list) <- omic_names
#   # Add x to output
#   output_list[["X"]] <- X_list
#
#   return(output_list)
# }
#
#
#
#
# # TODO: RENAME X Y later????
#
#
# ns <- c(50, 100, 150, 200, 250, 300, 400, 500, 800)
# ps <- c(100)
# rhos <- c(0,0.5,1)
# j <- 3
# p_imp <- 30
# dts <- c(10)
#
# param_grid <- expand.grid(n = ns, p = ps, rho = rhos, dt = dts) |>
#   dplyr::mutate(comb = paste0("n", n, "_p", p, "_rho", rho, "_dt", dt))
#
#
#
# num_comb <- nrow(param_grid)
# output_list <- setNames(vector("list", num_comb), param_grid$comb)
#
#
# for (i in seq(num_comb)) {
#   print(i)
#   n <- param_grid[i, "n"]
#   p <- param_grid[i, "p"]
#   rho <- param_grid[i, "rho"]
#   dt <- param_grid[i, "dt"]
#
#   a_list = simulating_omics(n=n,  p=p, p_imp=p_imp,
#                             j=j, rho=rho, dt=dt, identifier="truth_data", add_dt=T)
#   b_list = simulating_omics(n=n,  p=p, p_imp=p_imp,
#                             j=j, rho=rho, dt=dt, identifier="noise_data", add_dt=F)
#
#
#   merged_list <- mapply(function(x, y) {
#     omic <- cbind(x, y)
#
#     # And add some random noise to each matrix
#     noise_mat <- matrix(
#       rnorm(nrow(omic) * ncol(omic), mean=0, sd=1),
#       nrow = nrow(omic),
#       ncol = ncol(omic)
#     )
#     omic <- omic + noise_mat
#
#     return(omic)
#   }, x=a_list$X, y=b_list$X, SIMPLIFY = F)
#
#   merged_list$Y <- a_list$y
#
#
#   # Look into erro rate and not auc for diablo
#   # Fit model
#   X <- merged_list[1:j]
#   Y <- merged_list$Y
#   diab_mod <- block.splsda(X=X, Y=Y)
#   cv_obj <- perf(diab_mod)
#   error_rate <- cv_obj$AveragedPredict.error.rate
#
#   # Then add to list
#   label <- param_grid$comb[i]
#   output_list[[label]] <- error_rate |> as.data.frame() |>
#     tibble::rownames_to_column(var="metric")
#
# }
#
# #
# # X <- merged_list[1:3]
# # Y <- merged_list$Y
# #
# # Y |> length()
# #
# # X$omic1[1:50, ] |> hist()
# #
# # X$omic1[51:100, ] |> hist()
# #
# # library(dplyr)
# #
# # # Example: Assuming your list is called `output_list`
# # merged_df <- bind_rows(
# #   lapply(names(output_list), function(name) {
# #     output_list[[name]] %>%
# #       mutate(combination = name)
# #   })
# # )
# #
# # plot_df <- merged_df |>
# #   as_tibble() |>
# #   tidyr::separate(
# #     col = combination,
# #     into = c("n", "p", "rho", "dt"),
# #     sep = "_",
# #     remove = FALSE
# #   )  |>
# #   mutate(
# #     n = sub("^n", "", n) |> as.numeric(),
# #     p = sub("^p", "", p) |> as.numeric(),
# #     rho = sub("^rho", "", rho) |> as.numeric(),
# #     dt = sub("^dt", "", dt) |> as.numeric()
# #   ) %>%
# #   mutate(n_p_rho_dt = paste("N =", n, ", p = ", p, ", rho =", rho, ", dt =", dt)) %>%
# #     mutate(
# #       n_p_rho_dt = factor(
# #         n_p_rho_dt,
# #         levels = unique(n_p_rho_dt[order(n, p, rho, dt)])
# #       )
# #     )
# #
# #
# #
# # plot_df %>%
# #   filter(metric == "Overall.BER") %>%
# #   ggplot(aes(x=factor(n), y = comp2, color=factor(rho))) +
# #   geom_point(size=3) +
# #   geom_line(aes(group = rho)) +
# #   labs(color = "covariance") +
# #   theme_bw()
# #
# #
#
# # for (param in param_grid) {
# #   a_list = simulating_omics(n=n,  p=p, p_imp=p_imp,
# #                             j=j, rho=rho, dt=dt, identifier="truth_data", add_dt=T)
# #   b_list = simulating_omics(n=n,  p=p, p_imp=p_imp,
# #                             j=j, rho=rho, dt=dt, identifier="noise_data", add_dt=F)
# #
# #   merged_list$Y <- a_list$y
# #
# #
# #   # Look into erro rate and not auc for diablo
# #   # Fit model
# #   X <- merged_list[1:j]
# #   Y <- merged_list$Y
# #   diab_mod <- block.splsda(X=X, Y=Y)
# #   cv_obj <- perf(diab_mod)
# #   error_rate <- cv_obj$AveragedPredict.error.rate
# #
# # }
# #
# # a_list = simulating_omics(n=n,  p=p, p_imp=p_imp,
# #                           j=j, rho=rho, dt=dt, identifier="truth_data", add_dt=T)
# # b_list = simulating_omics(n=n,  p=p, p_imp=p_imp,
# #                           j=j, rho=rho, dt=dt, identifier="noise_data", add_dt=F)
# #
# #
# #
# # error_rate |> as.data.frame() |>
# #   tibble::rownames_to_column(var="metric")
# # For the fs extraction part
# # keepX <- createKeepX(X)
# # model <- block.splsda(X, Y, keepX = keepX)
# # var_list <- selectVar(model)
# # # Extract the features out from var_list and wrangle to df for downstream usage
# # feats_df <- extract_feats_df(var_list = var_list) |>
# #   as_tibble() |>
# #   # Need a better naming rather than coef?
# #   rename("coef" = "value.var") |>
# #   #arrange(desc( coef )) |>
# #   mutate(
# #     method = paste("diablo", "def", sep="-"),
# #     dataset_name = "set1"
# #   ) |>
# #   dplyr::select(feature, view, coef, method, dataset_name)
# #
# #
# # all_counts <- feats_df |>
# #   mutate(feature_type = case_when(
# #     stringr::str_detect(feature, "truth") ~ "true",
# #     TRUE ~ "noise"
# #   )
# #   ) |>
# #   group_by(feature_type) %>%
# #   summarize(n=n())
# #
# # all_counts
# #
# # top_df <- feats_df |>
# #   mutate(feature_type = case_when(
# #     stringr::str_detect(feature, "truth") ~ "true",
# #     TRUE ~ "noise"
# #   )
# #   ) %>%
# #   arrange(desc(abs(coef))) %>%
# #   slice_head(n=all_counts %>% filter(feature_type == "true") %>% pull(n)) %>%
# #   group_by(feature_type) %>%
# #   summarize(n=n()) %>%
# #   mutate(category = "top_counts")
# #
# #
# # bottom_df <- feats_df |>
# #   mutate(feature_type = case_when(
# #     stringr::str_detect(feature, "truth") ~ "true",
# #     TRUE ~ "noise"
# #   )
# #   ) %>%
# #   arrange(desc(abs(coef))) %>%
# #   slice_tail(n=all_counts %>% filter(feature_type == "noise") %>% pull(n)) %>%
# #   group_by(feature_type) %>%
# #   summarize(n=n()) %>%
# #   mutate(category = "bottom_counts")
# #
# # all_counts
# # bind_rows(top_df, bottom_df)
#
#
#
#
#
# #
# # #plotIndiv(pca_obj, group=y)
# #
# # # ======================================
# # # Then fit model
# # library(mixOmics)
#
# # cv_obj$AveragedPredict.error.rate
# #
# #
# # # pred_obj <- predict(diab_mod, newdata=X_list)
# # # y_pred <- ifelse(pred_obj$AveragedPredict[, , "dim2"][, 2] > 0.5, 1, 0)
# # # accuracy <- mean(y_pred == y)
# #
# # #print(accuracy)
