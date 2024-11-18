# This file should contain the helper files used in the
# simBulkMultiomics package

#' @export
dummy_fun <- function(dat) {
  # This fun shows the type of dat
  get_class(dat)
}

# If the fun is not exported, then it is only available
# for internal use

# This way would add a import in description
get_class <- function(x) base::class(dat)
