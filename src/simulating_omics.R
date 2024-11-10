# Use this script to create 1 omics data

# PARAMETERS
N = 100 # Number of patients
base_p = 100 # Base number of predictors
fake_p = 50 # Number of fake predictors
omic_name = "methyl" # Name of the omics to input
seed = 329 # Seed to reproduce

# Actual codes

# Create a matrix of omics
# Multiomics would follow a list of omics
set.seed(1)

createKeepX <- function(x_list, n_percent = 100, ncomp=2) {
  # For each omics, only get 10% of total features
  # Assume the input list is already after transforming to rows being common
  # samples
  cap <- 100
  if (n_percent > cap) {
    warning("Limited to top 100%, cannot exceed more than original feature count")
    n_percent <- cap
  }
  # Then create the keep x
  keep_list <- lapply(x_list, function(x) {
    # since row now represents samples, col correspond to features
    feat_num <- round(n_percent * ncol(x) / 100 , digits=0)
    # repat the number of features for ncomp times as a vector
    feat_vec <- rep(feat_num, ncomp)
    return(feat_vec)
  })
  # assign to have the matching omics names
  names(keep_list) <- names(x_list)
  return(keep_list)
}
extract_feats_df <- function(var_list) {
  # Last column is ncomp, so discard that part, hence -1
  # where rest are "selected features" of each view
  n <- length(var_list)
  feat_list <- var_list[1:n - 1]
  # Store the names of views for saving it later
  view_names <- names(feat_list)
  selected_feat_df_list <- lapply(view_names, function(view) {
    # For each omic (which is a list(name, value)), get the value part
    view_feats <- feat_list[[view]]
    view_feats_df <- view_feats$value |>
      tibble::rownames_to_column(var="feature") |>
      dplyr::mutate(view = view)
    return(view_feats_df)
  })

  selected_feat_df <- dplyr::bind_rows(selected_feat_df_list)
  return(selected_feat_df)
}
create_omic <- function(omic_name, N, base_p, fake_p) {

  total_p <- base_p + fake_p
  sample_names <- paste("sample", seq(1, N), sep = "_")
  omic_truth_colnames <- paste(omic_name, "truth", seq(1, base_p), sep = "_")
  omic_noise_colnames <- paste(omic_name, "noise", seq(base_p + 1, total_p), sep = "_")
  omic_colnames <- c(omic_truth_colnames, omic_noise_colnames)

  # Generate random data
  rand_data <- rnorm(N * total_p)
  omics <- matrix(rand_data, nrow = N, ncol = total_p)

  # Generate additional noise for the fake variables
  noise <- matrix(rnorm(N * fake_p, mean = 0, sd = 10), nrow = N, ncol = fake_p)

  # Add the noise to the fake columns
  omics[, (base_p + 1):total_p] <- omics[, (base_p + 1):total_p] + noise

  # Assign row and column names
  rownames(omics) <- sample_names
  colnames(omics) <- omic_colnames

  return(omics)
}



all_names <- c("mrna", "methyl", "protein")
X_list <- list()
for (name in all_names) {
  X_list[[name]] <- create_omic(name, N, base_p, fake_p=fake_p)
}
aggr <- rowMeans(X_list$mrna) +
  rowMeans(X_list$methyl) +
  rowMeans(X_list$protein)

Y <- abs(aggr > mean(aggr)) |> as.numeric()









# Then fit a model and see?
library(mixOmics)
library(tidyverse)
keepX <- createKeepX(X_list, n_percent=100)
design <- "null"
method <- "diablo"
dataset_name <- "sim1"
# Then fit the model
model <- block.splsda(X_list, Y, keepX=keepX, design=design)
# Then run the select var part and extract its names
var_list <- selectVar(model)
# Extract the features out from var_list and wrangle to df for downstream usage
feats_df <- extract_feats_df(var_list = var_list) |>
  as_tibble() |>
  # Need a better naming rather than coef?
  rename("coef" = "value.var") |>
  #arrange(desc( coef )) |>
  mutate(
    method = paste(method, design, sep="-"),
    dataset_name = dataset_name
  ) |>
  dplyr::select(feature, view, coef, method, dataset_name)

feats_df



