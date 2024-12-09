# This file should contain the helper files used in the
# simBulkMultiomics package

#' @export
dummy_fun <- function(dat) {
  # This fun shows the type of dat
  get_class(dat)
}


get_normal_noise_mat <- function(omic, mean=0, sd=1) {
  d <- rnorm(nrow(omic) * ncol(omic), mean = mean, sd = sd)
  matrix(d, nrow = nrow(omic), ncol = ncol(omic))
}

# If the fun is not exported, then it is only available
# for internal use

# This way would add a import in description
get_class <- function(x) base::class(dat)
