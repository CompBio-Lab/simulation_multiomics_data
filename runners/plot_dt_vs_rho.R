set.seed(1)
library(ggplot2)
library(dplyr)
library(tidyr)

# Parameters
n <- 100
half_n <- n %/% 2
j <- 2
pc_mu <- 0
param_grid <- expand.grid(rho = c(0, 0.2, 0.5, 0.7, 0.9),
                          dt = c(0, 2, 4, 6, 8, 10))

# Initialize a data frame to store results
data_list <- vector("list", length = nrow(param_grid))

for (i in seq_len(nrow(param_grid))) {
  g <- param_grid[i, ]
  rho <- g$rho
  dt <- g$dt

  # Covariance matrix
  sigma_mat <- matrix(rho, nrow = j, ncol = j)
  diag(sigma_mat) <- 1

  # Generate data
  pcs <- MASS::mvrnorm(n = n, mu = rep(pc_mu, j), Sigma = sigma_mat)
  pcs[1:half_n, ] <- pcs[1:half_n, ] + dt

  # Store in a list
  data_list[[i]] <- pcs %>%
    as.data.frame() %>%
    mutate(y = factor(c(rep(1, half_n), rep(0, half_n))),
           rho = rho,
           dt = dt)
}

# Combine all data into one data frame
combined_data <- bind_rows(data_list)


# Plot stratified by rho or dt
ggplot(combined_data, aes(x = V1, y = V2, color = y)) +
  geom_point(alpha = 0.4) +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_grid(rho ~ dt, labeller = label_both) +
  labs(title = "Data Stratified by Rho and DT", color = "Group")
