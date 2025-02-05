library(tidyverse)

fs_data_path <- "data/fs_metric_data.csv"
plot_fs_metric_data <- read.csv(fs_data_path) %>%
  as_tibble()



fs_plot <- plot_fs_metric_data %>%
  mutate(dt = as.factor(dt)) %>%
  ggplot(aes(x=dt, y=sensitivity)) +
  geom_boxplot(fill = "lightblue", alpha = 0.7) +
  #geom_jitter(width = 0.1, alpha = 0.7) +
  theme_bw() +
  #scale_x_continuous(breaks = seq(0, 200, by = 10)) +
  scale_y_continuous(breaks = seq(0, 1, by = 0.1)) +
  geom_hline(yintercept = 0.5, color="red") +
  geom_hline(yintercept = 0.75, color ="orange") +
  facet_grid(p~n, label = label_both) +
  labs(title="Feature Selection sensitivity for messi_sim varied n and p, with bimodal weights",
       x = "Signal")

fs_plot


