# extract_feats_df <- function(var_list) {
#   # Last column is ncomp, so discard that part, hence -1
#   # where rest are "selected features" of each view
#   n <- length(var_list)
#   feat_list <- var_list[1:n - 1]
#   # Store the names of views for saving it later
#   view_names <- names(feat_list)
#   selected_feat_df_list <- lapply(view_names, function(view) {
#     # For each omic (which is a list(name, value)), get the value part
#     view_feats <- feat_list[[view]]
#     view_feats_df <- view_feats$value |>
#       tibble::rownames_to_column(var="feature") |>
#       dplyr::mutate(view = view)
#     return(view_feats_df)
#   })
#
#   selected_feat_df <- dplyr::bind_rows(selected_feat_df_list)
#   return(selected_feat_df)
# }
#
#
# createKeepX <- function(x_list, n_percent = 100, ncomp=2) {
#   # For each omics, only get 10% of total features
#   # Assume the input list is already after transforming to rows being common
#   # samples
#   cap <- 100
#   if (n_percent > cap) {
#     warning("Limited to top 100%, cannot exceed more than original feature count")
#     n_percent <- cap
#   }
#   # Then create the keep x
#   keep_list <- lapply(x_list, function(x) {
#     # since row now represents samples, col correspond to features
#     feat_num <- round(n_percent * ncol(x) / 100 , digits=0)
#     # repat the number of features for ncomp times as a vector
#     feat_vec <- rep(feat_num, ncomp)
#     return(feat_vec)
#   })
#   # assign to have the matching omics names
#   names(keep_list) <- names(x_list)
#   return(keep_list)
# }
# keepX <- createKeepX(X_list)
# model <- block.splsda(X_list, y, keepX = keepX)
# var_list <- selectVar(model)
# # Extract the features out from var_list and wrangle to df for downstream usage
# feats_df <- extract_feats_df(var_list = var_list) |>
#   as_tibble() |>
#   # Need a better naming rather than coef?
#   rename("coef" = "value.var") |>
#   #arrange(desc( coef )) |>
#   mutate(
#     method = paste("diablo", "def", sep="-"),
#     dataset_name = "set1"
#   ) |>
#   dplyr::select(feature, view, coef, method, dataset_name)
#
#
# all_counts <- feats_df |>
#   mutate(feature_type = case_when(
#     stringr::str_detect(feature, "imp_var") ~ "true",
#     TRUE ~ "noise"
#       )
#     ) |>
#   group_by(feature_type) %>%
#   summarize(n=n())
#
# all_counts
#
# top_df <- feats_df |>
#   mutate(feature_type = case_when(
#     stringr::str_detect(feature, "imp_var") ~ "true",
#     TRUE ~ "noise"
#     )
#   ) %>%
#   arrange(desc(abs(coef))) %>%
#   slice_head(n=all_counts %>% filter(feature_type == "true") %>% pull(n)) %>%
#   group_by(feature_type) %>%
#   summarize(n=n()) %>%
#   mutate(category = "top_counts")
#
#
# bottom_df <- feats_df |>
#   mutate(feature_type = case_when(
#     stringr::str_detect(feature, "imp_var") ~ "true",
#     TRUE ~ "noise"
#   )
#   ) %>%
#   arrange(desc(abs(coef))) %>%
#   slice_tail(n=all_counts %>% filter(feature_type == "noise") %>% pull(n)) %>%
#   group_by(feature_type) %>%
#   summarize(n=n()) %>%
#   mutate(category = "bottom_counts")
#
# all_counts
# bind_rows(top_df, bottom_df)
#
#
