library(tidyverse)

simulate_classification_data <- function(n, p, signal_to_noise) {
  # Validate inputs
  if (signal_to_noise < 0 || signal_to_noise > 1) {
    stop("Signal-to-noise ratio must be between 0 and 1.")
  }

  # Number of signal and noise predictors
  num_signal <- round(p * signal_to_noise)
  num_noise <- p - num_signal

  # Generate signal predictors (e.g., standard normal distribution)
  if (num_signal > 0) {
    signal_predictors <- matrix(rnorm(n * num_signal, mean=1), nrow = n, ncol = num_signal)
    colnames(signal_predictors) <- paste0("true_var_", 1:num_signal)
  } else {
    signal_predictors <- NULL
  }

  # Generate noise predictors (e.g., standard normal distribution)
  if (num_noise > 0) {
    noise_predictors <- matrix(rnorm(n * num_noise, sd=5), nrow = n, ncol = num_noise)
    colnames(noise_predictors) <- paste0("noise_var_", 1:num_noise)
  } else {
    noise_predictors <- NULL
  }

  # Combine signal and noise predictors
  predictors <- cbind(signal_predictors, noise_predictors)

  # Assign coefficients to signal predictors (e.g., all coefficients = 1)
  beta <- c(rep(1, num_signal), rep(0, num_noise))
  # Compute linear predictor (eta) and probability P(Y = 1)
  eta <- predictors %*% beta
  prob_y1 <- 1 / (1 + exp(-eta)) # Logistic transformation

  # Sample binary response variable Y from Bernoulli distribution
  y <- rbinom(n, size = 1, prob = prob_y1)

  # Create a data frame with predictors and response
  data <- as.data.frame(cbind(predictors, y = y))

  return(data)
}

# Define parameter ranges
n_values <- seq(100, 1000, by = 100)      # Varying n
p_values <- c(5, 10, 20)               # Different numbers of predictors
signal_to_noise_values <- c(0, 0.5, 1) # Different signal-to-noise ratios

# Generate all combinations of parameters
param_grid <- expand.grid(n = n_values,
                          p = p_values,
                          signal_to_noise = signal_to_noise_values)


sim.apply_way <- function(param_grid) {
  # Use lapply to iterate over parameter combinations
  results <- do.call(rbind, lapply(1:nrow(param_grid), function(i) {
    # Extract parameters for this iteration
    params <- param_grid[i, ]
    # Simulate data and train model
    data <- simulate_classification_data(params$n, params$p, params$signal_to_noise)
    model <- glm(y ~ ., data = data, family = binomial)
    predictions <- ifelse(predict(model, type = "response") > 0.5, 1, 0)

    # Return results for this combination
    data.frame(n = params$n,
               p = params$p,
               signal_to_noise = params$signal_to_noise,
               accuracy = mean(predictions == data$y))
  }))
  return(results)
}

results <- sim.apply_way(param_grid) %>%
  mutate(p_signal = paste("p =", p, ", S/N =", signal_to_noise)) %>%
  mutate(
    p_signal = factor(
      p_signal,
      levels = unique(p_signal[order(p, signal_to_noise)])
    )
  )


custom_colors <- RColorBrewer::brewer.pal(
  results$p_signal %>% levels() %>% length(), "Paired"
)  # 9 distinct colors from the "Set1" palette


p_labels <- paste0("P = ", results$p |> unique())
names(p_labels) <- results$p |> unique()
sn_labels <- paste0("SN ratio = ", results$signal_to_noise |> unique())
names(sn_labels) <- results$signal_to_noise |> unique()


results %>%
  ggplot(aes(x = n, y = accuracy,
             color = p_signal)) +
  geom_line() +
  geom_point() +
  labs(title = "Effect of Sample Size (n) on Accuracy") +
  scale_color_manual(values = custom_colors) +
  facet_grid(
    p ~ signal_to_noise,
    labeller = labeller(p = p_labels, signal_to_noise = sn_labels),
    scales = "free")  # Custom labels for facets
