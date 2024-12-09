sim_data <- function(n, p, j, dt, rho, pc_mu) {
  # Both list should return identical number of observations
  # And each generating half number of variables
  if (!(p %% 2 == 0)) stop("P should be even number")
  true_num_vars <- floor(p * 0.1) # Make sure p is even
  noise_num_vars <- p - true_num_vars
  true_omics_list  <- sim_multiomics(n=n, p=true_num_vars, j=j, dt=dt,
                                     rho=rho, pc_mu = pc_mu, add_dt=TRUE)
  noise_omics_list <- sim_multiomics(n=n, p=noise_num_vars, j=j, dt=dt,
                                     rho=rho, pc_mu = pc_mu, add_dt=FALSE)

  # Then merge the X together from both list
  X <- mapply(function(x_list, y_list) {
    omic <- cbind(x_list, y_list)
    # And add some random noise to each matrix
    omic <- omic + get_normal_noise_mat(omic)
  }, x_list=true_omics_list$X, y_list=noise_omics_list$X, SIMPLIFY = FALSE)


  output_list <- list(X=X, Y=true_omics_list$Y)
  return(output_list)
}

