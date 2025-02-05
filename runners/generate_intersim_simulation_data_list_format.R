# =========================================================================
# Use this script to generate data for running MESSI
#
# This uses the intersim functionality to create sim data
#
# Author: Tony Liang
# =========================================================================

# Load libraries
library(devtools)
library(dplyr)
source("runners/refactor_intersim.R")

# COMMENT THIS OUT
#d_inter <- intersim_sim("d1", 10, H=900)


# Set seed to reproduce these data
set.seed(1)

# Create grid of parameters to generate unique combination for testing
# various data parameter setting
num_obs <- c(100)
#omics_cov <- c(0, 0.5, 1)
# This parameter controls quite a lot on the data, difference of mean between
# underlying groups 1 and 0
# Low = 0, Medium = 20,High = 200
#dts <- c(0,  20, 200)


omics_cov <- c(0.5)
# This parameter controls quite a lot on the data, difference of mean between
# underlying groups 1 and 0

# Low = 0, Medium = 20,High = 200
# dts <- c(0,  20, 200)
dts <- seq(from = 0, to = 100, by = 5)



num_reps <- 10

#num_reps <- 5
# The grid here
params_grid <- expand.grid(n = num_obs, dt = dts, rho = omics_cov,
                           rep = seq_len(num_reps)) # Adds replicates to the grid

# Then for all of these combinations create the data

generate_dataset <- function(n, dt, rho, rep = NULL) {
  if (is.null(rep)) stop("rep should not be null")
  label <- paste0(
    "sim-data",
    "_strategy-intersim",
    "_n-", n,
    "_dt-", dt,
    "_rho-", rho,
    "_rep-", rep
  )


  # Then set a seed here
  unique_seed <- sum(base::utf8ToInt(label))
  set.seed(unique_seed)
  # Calls intersim fun here
  # H needs to be fixed at 900 so it matches number of signal vars
  # and total vars
  d <- intersim_sim(label, n=n, effect = dt, corr = rho, H=900)
  # UNCOMMENT BELOW
  list(label = label, X = d$X, Y = d$Y)
  #list(label = label, X = d$X, Y = d$Y$response)
}



intersim_datasets <- purrr::pmap(
  params_grid,
  function(n, dt, rho, rep) {
    generate_dataset(n = n, dt = dt, rho = rho, rep = rep)
  }
)

# Name the datasets in the list with their labels
names(intersim_datasets) <- purrr::map_chr(intersim_datasets, "label")

# # Now save this to RDS for later processing as MultiAssayExperiment and MuData
saveRDS(intersim_datasets, "simulation_data_intersim.rds")


