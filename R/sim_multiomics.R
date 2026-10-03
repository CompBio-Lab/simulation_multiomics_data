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

  # 1. Draw n independent samples of j correlated latent variables.
  # These are generated factors, not PCs calculated by fitting PCA to data.
  latent <- sample_latent(n=n, j=j, rho=rho, pc_mu=pc_mu)

  # 2. The first group gets a mean shift; the background branch gets no label.
  # Keep the original sample order and random-number draw order.
  output <- list()
  if (add_dt) {
    y <- make_labels(n)
    latent <- apply_class_signal(latent, y, dt)
    output[["Y"]] <- y
  }

  # 3. One latent variable per modality is projected onto p features.
  # Preserve the legacy weight sampler for same-seed reproducibility.
  weights <- create_weight(j, p)
  output[["X"]] <- project_to_features(latent, weights, is_signal=add_dt)
  return(output)
}


create_sigma <- function(rho, j) {
  # J has to be greater than 1
  if (!is.numeric(j) || !is.numeric(rho)) stop("J and rho has to be numeric")
  if (!(j > 1)) stop("J has to be more than 1")
  # rho should be in range of [0, 1]
  if (rho < 0 || rho > 1) stop("Rho can only stay in range of [0, 1]")
  # Diagonal = variance of each latent variable = 1.
  # Off-diagonal = covariance = rho; because variances are 1, also correlation.
  # Example j=3: rows are (1,rho,rho), (rho,1,rho), (rho,rho,1).
  # Eigenvalues: 1-rho (j-1 times), 1+(j-1)*rho.
  # Thus positive definite for rho<1; rho=1 is a singular boundary case
  # with identical latent columns, supported by MASS::mvrnorm's eigen approach.
  sigma_mat <- matrix(rho, nrow=j, ncol=j)
  diag(sigma_mat) <- 1
  return(sigma_mat)
}

# ====================
# Fun to sample latent space
sample_latent <- function(n, j, rho, pc_mu=0) {
  sigma_mat <- create_sigma(rho=rho, j=j)
  # Output: n rows (samples), j columns (one latent factor per modality).
  # mu specifies population means, Sigma specifies population covariance.
  # Default empirical=FALSE is intentional: finite-sample statistics fluctuate.
  out <- MASS::mvrnorm(n=n, mu=rep(pc_mu, j), Sigma=sigma_mat)
  return(out)
}

# Fun to make labels
make_labels <- function(n) {
  n_positive <- n %/% 2
  # For odd n, the negative class has one extra sample (old code lost a label).
  out <- c(rep(1, n_positive), rep(0, n - n_positive))
  return(out)
}

# Fun to apply class signal
apply_class_signal <- function(latent, y, dt) {
  # Current linear mechanism: z_im = u_im + dt*y_i.
  # Class means differ by dt; within-class covariance remains Sigma.
  # Pooled covariance also includes variation due to the shared class label.
  # Future nonlinear mechanisms belong here, not in feature naming/weights.
  positive <- which(y == 1)
  latent[positive, ] <- latent[positive, , drop=FALSE] + dt
  return(latent)
}

# Fun to create the weight of modalities
create_weight <- function(j, p, type="O") {
  # ========================
  # Newer implement
  # magnitude <- runif(j*p, min=0.2, max=0.3)
  # direction <- sample(c(-1, 1), size = j*p, replace=TRUE)
  #
  # W <- matrix(magnitude * direction, nrow=j, ncol=p)
  # return(W)
  d1 <- runif(p^2, min=-0.3, max=-0.2)
  d2 <- runif(p^2, min=0.2, max=0.3)
  unif_data <- c(d1, d2) |> sample(j*p)
  matrix(unif_data, nrow=j, ncol=p)
}

# Fun to project to features
project_to_features <- function(latent, weights, is_signal) {
  omic_names <- paste0("omic", seq_len(ncol(latent)))
  var_name <- if (is_signal) "true_var" else "noise_var"
  X <- lapply(seq_along(omic_names), function(m) {
    # (n x 1) %*% (1 x p) = n x p. Features share a single latent factor.
    # No measurement noise here: sim_data() adds it AFTER combining blocks.
    omic <- latent[, m, drop=FALSE] %*% weights[m, , drop=FALSE]
    colnames(omic) <- paste(omic_names[m], var_name, seq_len(ncol(omic)), sep="_")
    rownames(omic) <- paste("patient", seq_len(nrow(omic)), sep="_")
    omic
  })
  names(X) <- omic_names
  return(X)
}

