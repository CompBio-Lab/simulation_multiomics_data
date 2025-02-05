library(tidyverse)

err_data_path <- "data/err_rate_data.csv"
plot_err_rate_data <- read.csv(err_data_path) %>%
  as_tibble() %>%
  filter(metric == "Overall.BER") %>%
  mutate(dt = as.factor(dt))



err_rate_plot <- plot_err_rate_data %>%
  mutate(comp2 = 1 - comp2) %>%
  #filter(dt == 30, rho == 1) %>%
  ggplot(aes(x=dt, y=comp2)) +
  #stat_boxplot(geom ='errorbar') +
  geom_boxplot(fill = "lightblue", alpha = 0.7) +
  facet_grid(p~n, labeller = label_both) +
  labs(y="Balanced Accuracy", title="Balanced Accuracy") +
  theme_bw()

err_rate_plot



