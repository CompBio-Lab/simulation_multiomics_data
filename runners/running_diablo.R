library(devtools)
library(mixOmics)
library(dplyr)
load_all()


# Run it
set.seed(10)
n <- 100
p <- 100
j <- 3 # Number of block
rho <- 0.1
# No --> 5
# Low --> 10
# Medium --> 20
# High --> 30
dt <-  30 # Sh/ould be low medium high


d <- sim_data(n=n, p=p, j=j, dt=dt, rho=rho, pc_mu = j)
X <- d$X
Y <- d$Y

# Try diablo
keepX <- createKeepX(X)
diab_mod <- block.splsda(X=X, Y=Y, keepX=keepX)
var_list <- selectVar(diab_mod)

cv_obj <- perf(diab_mod)
error_rate <- cv_obj$AveragedPredict.error.rate

# Extract the features out from var_list and wrangle to df for downstream usage
feats_df <- extract_diablo_feats(var_list = var_list) |>
  as_tibble() |>
  dplyr::rename("coef" = "value.var") |>
  #arrange(desc( coef )) |>
  mutate(
    method = paste("diablo", "def", sep="-"),
    dataset_name = "set1"
  ) |>
  mutate(feature_type = case_when(
    stringr::str_detect(feature, "true") ~ "true",
    TRUE ~ "noise"
    )
  ) |>
  dplyr::select(feature, view, coef, method, dataset_name, feature_type)



all_counts <- feats_df |>
  group_by(feature_type) %>%
  summarize(n=n())


# top_df <- feats_df |>
#   arrange(desc(abs(coef))) %>%
#   slice_head(n=all_counts %>% filter(feature_type == "true") %>% pull(n)) %>%
#   group_by(feature_type) %>%
#   summarize(n=n()) %>%
#   mutate(category = "top_counts")
#
#
#
# bottom_df <- feats_df |>
#   arrange(desc(abs(coef))) %>%
#   slice_tail(n=all_counts %>% filter(feature_type == "noise") %>% pull(n)) %>%
#   group_by(feature_type) %>%
#   summarize(n=n()) %>%
#   mutate(category = "bottom_counts")










kl <- bind_rows(top_df, bottom_df) %>%
  mutate(
    metric_type = case_when(
      feature_type == "true" & category == "top_counts" ~ "TP",
      feature_type == "noise" & category == "top_counts" ~ "FP",
      feature_type == "true" & category == "bottom_counts" ~ "FN",
      feature_type == "noise" & category == "bottom_counts" ~ "TN",
      TRUE ~ NA_character_ # Fallback for unexpected combinations
    )
  ) %>%
  select(metric_type, n)

kl %>%
  tidyr::pivot_wider(names_from = metric_type, values_from = n) %>% # Spread data into columns
  mutate(
    N = TP + TN + FN + FP,
    accuracy = (TP + TN) / N
  )

