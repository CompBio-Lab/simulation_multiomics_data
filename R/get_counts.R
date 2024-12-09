get_counts <- function(df, by) {
  df %>%
    group_by( {{ by }} ) %>%
    summarize(n = n())
}




