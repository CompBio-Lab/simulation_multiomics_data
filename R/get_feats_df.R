get_feats_df <- function(mod, dname, true_var_label="true",
                         noise_var_label="noise") {
  var_list <- selectVar(diab_mod)
  feats_df <- extract_diablo_feats(var_list = var_list) |>
    dplyr::as_tibble() |>
    dplyr::rename("coef" = "value.var") |>
    #arrange(desc( coef )) |>
    dplyr::mutate(
      method = paste("diablo", "def", sep="-"),
      dataset_name = dname
    ) |>
    dplyr::mutate(feature_type = case_when(
      stringr::str_detect(feature, true_var_label) ~ true_var_label,
      TRUE ~ noise_var_label
    )
    ) |>
    dplyr::select(feature, view, coef, method, dataset_name, feature_type)
  return(feats_df)
}
