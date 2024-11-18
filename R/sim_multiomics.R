# simulating_omics <- function(n, p, p_imp, j, rho, dt, identifier, add_dt=TRUE) {
#   # This would be the output_list init
#   output_list <- list()
#   # Cor / Cov mat
#   Sigma <- matrix(rho,nrow=j,ncol=j)
#   diag(Sigma) <- 1
#
#   # Each col is view's pc
#   pcs <- mvrnorm(n = 2*n, mu = rep(0, 3), Sigma=Sigma)
#
#   # Shift the first 50 n in their pcs and get the y from there
#   if (add_dt) {
#     pcs[1:n, ] <- pcs[1:n, ] + dt
#     y <- c(rep(1, n), rep(0, n))
#     output_list[["y"]] <- y
#   }
#   #
#   # Create weights W being a j x p matrix, where
#   W <- matrix(runif(p * j, min = -3, max=3), nrow = j, ncol=p)  |>
#     apply(MARGIN=1, FUN=function(x) x / norm(as.matrix(x))) |>
#     t()
#
#
#   # Then now each row's norm is 1
#   #norm(W[1, ] |> as.matrix())
#   # Make sure norm of each column is 1 now ====================== ^
#
#   # Apply "individual" mat multiply for each column x row
#   omic_names <- c("omic1", "omic2", "omic3")
#
#   X_list <- lapply(seq_along(omic_names), function (index) {
#     omic <- pcs[, index, drop=FALSE] %*% W[index, , drop=FALSE]
#     omic_name <- omic_names[index]
#     # Then let the first 20 columns of each omic to be "useful" pred
#     omic[, 1:p_imp] <- omic[, 1:p_imp] + 2
#     colnames(omic) <- paste(identifier, omic_name, "var", 1:ncol(omic),  sep="_")
#     #colnames(omic)[1:p_imp] <- paste(omic_name, "imp_var", 1:p_imp, sep="_")
#     return(omic)
#   })
#   names(X_list) <- omic_names
#   # Add x to output
#   output_list[["X"]] <- X_list
#
#   return(output_list)
# }





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
sim_multiomics <- function(n, p, j, dt, identifier=NULL, rho=1, pc_mu=2, add_dt=TRUE) {
  if (is.null(identifier)) {
    identifier <- paste("sim_data", "n", n, "p", p, "j", j, "dt", dt, "rho", rho, sep="-")
  }
  # This would be the output_list init
  #output_list <- vector(mode = "list", length=2L)
  output_list <- list()
  # Cor / Cov mat for all the omics, diag is itself hence 1
  sigma_mat <- create_sigma(rho, j)
  # Each col is view's pc
  pcs <- mvrnorm(n = 2*n, mu = rep(pc_mu, j), Sigma=sigma_mat)
  # Shift the first n rows in their pcs and get the y from there
  if (add_dt) {
    # First n rows would have a different mean, this is for creating
    # the binary response
    pcs[1:n, ] <- pcs[1:n, ] + dt
    # Hence first n rows being in positive group, rest n rows being negative
    y <- c(rep(1, n), rep(0, n))
    output_list[["y"]] <- y
  }


  # Create weights W being a j x p matrix, sampled from unif(-j, j)
  W <- create_weight(j, p, min_val=-j, max_val=j)

  # Apply "individual" mat multiply for each column x row
  omic_names <- paste0("omic", seq_len(j))
  X_list <- lapply(seq_along(omic_names), function(index) {
    omic <- pcs[, index, drop=FALSE] %*% W[index, , drop=FALSE]
    omic_name <- omic_names[index]
    # And add some random noise to each matrix
    omic <- omic + get_normal_noise_mat(omic)
    if (add_dt) {
      var_name <- "true_var"
    } else {
      var_name <- "noise_var"
    }
    colnames(omic) <- paste(omic_name, var_name, 1:ncol(omic),  sep="_")
    return(omic)
  })
  names(X_list) <- omic_names
  # Add x to output
  output_list[["X"]] <- X_list
  return(output_list)
}

get_normal_noise_mat <- function(omic, mean=0, sd=1) {
  d <- rnorm(nrow(omic) * ncol(omic), mean = mean, sd = sd)
  matrix(d, nrow = nrow(omic), ncol = ncol(omic))
}

create_weight <- function(j, p, min_val=-3, max_val=3) {
  # Sample from uniform distribution
  unif_data <- runif(j * p, min = min_val, max = max_val)
  # Creates j x p matrix
  W <- matrix(unif_data, nrow = j, ncol=p)
  # Then divide each row by its row norm
  W <- apply(W, MARGIN = 1, FUN = function(x) x/norm(as.matrix(x), type="E"))
  # Lastly transpose it back to be j x p
  t(W)
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
