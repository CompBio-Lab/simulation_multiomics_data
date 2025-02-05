get_fs_stats <- function(top_bottom_counts,
                         top_identifier="top_counts",
                         bottom_identifier="bottom_counts") {
  top_bottom_counts %>%
    summarise(
      TP = sum(n[category == top_identifier & feature_type == "true"], na.rm = TRUE),
      FP = sum(n[category == top_identifier & feature_type == "noise"], na.rm = TRUE),
      FN = sum(n[category == bottom_identifier & feature_type == "true"], na.rm = TRUE),
      TN = sum(n[category == bottom_identifier & feature_type == "noise"], na.rm = TRUE),
      N = sum(TP, TN, FP, FN),
      .groups = "drop"
    )
}
  