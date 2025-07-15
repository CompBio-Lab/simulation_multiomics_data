#' Simulate a bulk multiomics data
#'
#' @param n           Number of observations to generate
#' @param p           Number of predictors to generate in one omics
#' @param j           Number of omics to create, dimension would be n x p
#' @param rho         Correlation between omics, ranges from [0, 1]
#' @param dt          Delta difference between 2 groups in the pcs
#' @param identifier  Name of the dataset, if NULL then appends sim parameter
#' @return
#' @export
#'
#' @examples
#' \dontrun{
#' sim_multiomics(n=10,p=10,j=3,rho=1)
#' }
sim_multiomics <- function(n, p, j, dt, rho=0, pc_mu=0, add_dt=TRUE) {

  # This would be the output_list init
  output_list <- list()

  # Then calls create 2 parts, one is true trend , one is noise trend
  # Cor / Cov mat for all the omics, diag is itself hence 1
  sigma_mat <- create_sigma(rho=rho, j=j)
  # Each col is view's pc
  pcs <- MASS::mvrnorm(n = n, mu = rep(pc_mu, j), Sigma=sigma_mat)
  # Shift the pcs to generate y like that
  if (add_dt) {
    # First half n would have a different mean, this is for creating
    # the binary response
    half_n <- n %/% 2
    pcs[1:half_n, ] <- pcs[1:half_n, ] + dt
    # Hence first half n rows being in positive group,
    # rest half n rows being negative
    y <- c(rep(1, half_n), rep(0, half_n))
    output_list[["Y"]] <- y
  }

  # ~~~Create weights W being a j x p matrix, sampled from unif(-j, j)~~~~ OLD
  # Create weights W being a p x p matrix, sampled from unif(-j, j)
  W <- create_weight(j, p, min_val=-j, max_val=j)

  # Apply "individual" mat multiply for each column x row
  omic_names <- paste0("omic", seq_len(j))
  X_list <- lapply(seq_along(omic_names), function(index) {
    omic <- pcs[, index, drop=FALSE] %*% W[index, , drop=FALSE]
    omic_name <- omic_names[index]
    # And add some random noise to each matrix
    omic <- omic
    if (add_dt) {
      var_name <- "true_var"
    } else {
      var_name <- "noise_var"
    }
    colnames(omic) <- paste(omic_name, var_name, 1:ncol(omic),  sep="_")
    rownames(omic) <- paste("patient", 1:nrow(omic), sep="_")
    return(omic)
  })
  names(X_list) <- omic_names
  # Add x to output
  output_list[["X"]] <- X_list
  return(output_list)
}





# TODO: .....
# create_weight <- function(j, p, min_val=-3, max_val=3, type="O") {
#   # Sample from uniform distribution
#   unif_data <- runif(j * p, min = min_val, max = max_val)
#   # Creates j x p matrix
#   W <- matrix(unif_data, nrow = j, ncol=p)
#   # Then divide each row by its row norm
#   W <- apply(W, MARGIN = 1, FUN = function(x) x/norm(as.matrix(x), type=type))
#   # Lastly transpose it back to be j x p
#   t(W)
# }

create_weight <- function(j, p, min_val=-3, max_val=3, type="O") {
  # Sample from uniform distribution
  #unif_data <- runif(j * p, min = min_val, max = max_val)

  # [ -0.3, -0.2 ] u [0.2, 0.3]
  d1 <- runif(p^2, min = -0.3, max = -0.2)
  d2 <- runif(p^2, min = 0.2, max = 0.3)
  unif_data <- c(d1, d2) |> sample(j*p)
  # Creates j x p matrix
  W <- matrix(unif_data, nrow = j, ncol=p)
  W
  # Then divide each row by its row norm
  #W <- apply(W, MARGIN = 1, FUN = function(x) x/norm(as.matrix(x), type=type))
  # Lastly transpose it back to be j x p
  #t(W)
}

create_sigma <- function(rho, j) {
  # J has to be greater than 1
  if (!is.numeric(j) || !is.numeric(rho)) stop("J and rho has to be numeric")
  if (!(j > 1)) stop("J has to be more than 1")
  # rho should be in range of [0, 1]
  if (rho < 0 || rho > 1) stop("Rho can only stay in range of [0, 1]")
  sigma_mat <- matrix(rho, nrow=j, ncol=j)
  diag(sigma_mat) <- 1
  return(sigma_mat)
}
