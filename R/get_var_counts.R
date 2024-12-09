library(dplyr)
get_var_counts <- function(feats_df, all_counts_df,
                           group_col,
                           type=c("top", "bottom"),
                           true_var_label = "true",
                           noise_var_label = "noise"
) {
  arranged_df <- feats_df %>%
    arrange(desc(abs( coef )))


  if (type == "top") {
    num_var <- all_counts_df %>%
      filter({{ group_col }} == true_var_label) %>% pull(n)
    df <- arranged_df %>%
      slice_head(n=num_var)
  }



  if (type == "bottom") {
    num_var <- all_counts_df %>%
      filter({{ group_col }} == noise_var_label) %>% pull(n)
    df <- arranged_df %>%
      slice_tail(n=num_var)

  }
  df %>%
    get_counts(by = {{ group_col }} ) %>%
    mutate(category = paste0(type, "_", "counts"))
}
