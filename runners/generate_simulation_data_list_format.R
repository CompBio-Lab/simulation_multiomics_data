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

# Set seed to reproduce these data
set.seed(1)

# Create grid of parameters to generate unique combination for testing
# various data parameter setting
num_obs <- c(100)
num_vars <- c(1000)
# For now set number of omics to be 3
num_omic <- c(3)
omics_cov <- c(0, 0.5, 1)
# This parameter controls quite a lot on the data, difference of mean between
# underlying groups 1 and 0

# Low = 0, Medium = 20,High = 200
dts <- c(0,  20, 200)

#num_reps <- 3
# The grid here
params_grid <- expand.grid(n = num_obs, p = num_vars,
                           j = num_omic, dt = dts, rho = omics_cov)
                           #rep = seq_len(num_reps)) # Adds replicates to the grid

# Then for all of these combinations create the data

is_binary <- FALSE

if (is_binary) {
  message("Making Y to yes and no")
  datasets <- purrr::pmap(params_grid, function(n, p, j, dt, rho) {
    label <- paste0(
      "sim-data",
      "_strategy-pced",
      "_n-", n,
      "_p-", p,
      "_j-", j,
      "_dt-", dt,
      "_rho-", rho
    )
    d <- sim_data(n = n, p = p, j = j, dt = dt, rho = rho, pc_mu = 0)
    # Convert y and add sample name into it
    Y = data.frame(response = ifelse(d$Y == 1, yes = "yes", no = "no"),
                   sample_name = rownames(d$X[[1]]))
    list(label = label, X = d$X, Y = Y)
  })
} else {
  message("Making Y to 1, 0")
  datasets <- purrr::pmap(params_grid, function(n, p, j, dt, rho) {
    label <- paste0(
      "sim-data",
      "_strategy-pced",
      "_n-", n,
      "_p-", p,
      "_j-", j,
      "_dt-", dt,
      "_rho-", rho
    )
    d <- sim_data(n = n, p = p, j = j, dt = dt, rho = rho, pc_mu = j)

    list(label = label, X = d$X, Y = d$Y)
  })

}



# Name the datasets in the list with their labels
names(datasets) <- purrr::map_chr(datasets, "label")




# Now save this to RDS for later processing as MultiAssayExperiment and MuData
saveRDS(datasets, "simulation_data_list_format.rds")








