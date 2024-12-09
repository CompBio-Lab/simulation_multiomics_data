
# This is aggregate function composed of various more small functions
get_fs_summary <- function(mod, dname) {
  feats_df <- get_feats_df(mod, dname)
  all_counts <- get_counts(feats_df, by=feature_type)
  top_df <- get_var_counts(feats_df, all_counts_df = all_counts, group_col = feature_type,
                           type = "top")
  bottom_df <- get_var_counts(feats_df, all_counts_df = all_counts, group_col = feature_type,
                              type = "bottom")
  merged_df <- bind_rows(top_df, bottom_df)

  get_fs_stats(merged_df, top_identifier = "top_counts", bottom_identifier = "bottom_counts")
}
