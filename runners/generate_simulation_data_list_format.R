# =========================================================================
# Use this script to generate data for running MESSI
#
# Using functions from this package to generate binary classification
# data for bulk multiomics
#
# Author: Tony Liang
# =========================================================================

# Load libraries
library(devtools)
library(dplyr)
# Load the functions in this package
load_all()
#ds <- sim_data(n = 100, p=1000, j=3, rho=1, pc_mu = 2, dt=2)

# Set seed to reproduce these data
set.seed(1)

# Create grid of parameters to generate unique combination for testing
# various data parameter setting
num_obs <- c(100, 500, 1000)
#num_obs <- c(1000)
#num_obs <- c(100)
#num_vars <- c(3000) # THIS IS THE USUAL ONE

num_vars <- c(100, 500, 3000)
#num_vars <- c(3000)
# For now set number of omics to be 3
num_omic <- c(3)
# omics_cov <- c(0, 0.5, 1) # THIS IS THE USUAL ONE
omics_cov <- c(0, 0.5, 1)
# This parameter controls quite a lot on the data, difference of mean between
# underlying groups 1 and 0

# Low = 0, Medium = 20,High = 200
# dts <- c(0,  20, 200)
#dts <- seq(from = 0, to = 10, by = 1)
#dts <- #seq(from=1, to=10, by=1)
dts <- c(3.6, 3.7, 3.8, 3.9, 4)


num_reps <- 3
# The grid here
params_grid <- expand.grid(n = num_obs, p = num_vars,
                           j = num_omic, dt = dts, rho = omics_cov,
                           rep = seq_len(num_reps)) # Adds replicates to the grid

# Then for all of these combinations create the data

generate_dataset <- function(n, p, j, dt, rho, rep = NULL, pc_mu = 2, is_binary = TRUE) {
  if (is.null(rep)) stop("rep should not be null")
  label <- paste0(
    "sim-data",
    "_strategy-pced",
    "_n-", n,
    "_p-", p,
    "_j-", j,
    "_dt-", dt,
    "_rho-", rho,
    "_rep-", rep
  )


  # Then set a seed here
  unique_seed <- sum(base::utf8ToInt(label))
  set.seed(unique_seed)

  d <- sim_data(n = n, p = p, j = j, dt = dt, rho = rho, pc_mu = pc_mu)

  if (!is_binary) {
    Y <- data.frame(
      response = ifelse(d$Y == 1, "yes", "no"),
      sample_name = rownames(d$X[[1]])
    )
  } else {
    Y <- d$Y
  }

  list(label = label, X = d$X, Y = Y)
}

is_binary <- FALSE
if (!is_binary) {
  message("Making Y to yes and no")
} else {
  message("Making Y to 1, 0")
}



datasets <- purrr::pmap(
  params_grid,
  function(n, p, j, dt, rho, rep) {
    generate_dataset(n = n, p = p, j = j, dt = dt, rho = rho, rep = rep,
                     pc_mu = 0, is_binary = is_binary)
  },
  .progress = TRUE
)



# Name the datasets in the list with their labels
names(datasets) <- purrr::map_chr(datasets, "label")

# # Now save this to RDS for later processing as MultiAssayExperiment and MuData
saveRDS(datasets, "simulation_data_messi_sim.rds")
