#### PLOT POSTERIOR OF DELTA ####

# Per the lab's /plot-posterior convention: effect posterior (differs-from-
# zero question) -> zero line, symmetric x-axis, median line + [median, pd%]
# annotation, gray80 slab, nested 80/90% CI via stat_pointinterval.
delta_df <- data.frame(delta = delta_draws)

med_val <- median(delta_draws)
pd_val  <- max(mean(delta_draws > 0), mean(delta_draws < 0)) * 100
max_abs <- max(abs(range(delta_draws)))

p_delta <- ggplot(delta_df, aes(x = delta, y = 0)) +
  stat_slab(fill = "gray80") +
  stat_pointinterval(
    .width     = c(0.80, 0.90),
    point_size = 3,
    linewidth  = c(2, 1)
  ) +
  geom_vline(xintercept = 0, linetype = "dashed",
             colour = "grey40", linewidth = 0.7) +
  geom_vline(xintercept = med_val, linetype = "dashed",
             colour = "grey65", linewidth = 0.4) +
  annotate(
    "text", x = med_val, y = Inf,
    label  = sprintf("[median = %.2f, pd = %.2f%%]", med_val, pd_val),
    hjust  = -0.05, vjust = 1.4, size = 3.2, colour = "grey40"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    panel.grid   = element_blank(),
    axis.title.y = element_blank(),
    axis.text.y  = element_blank(),
    axis.ticks.y = element_blank(),
    axis.line.y  = element_blank(),
    axis.line.x  = element_line(colour = "grey30"),
    plot.margin  = margin(t = 20, r = 45, b = 5, l = 5)
  ) +
  labs(x = "Standardized effect size, delta (ADHD - TD)") +
  coord_cartesian(xlim = c(-max_abs, max_abs), ylim = c(0, 1.3), clip = "off")

ggsave(file.path(output_dir, "posterior_delta.pdf"), plot = p_delta,
       width = 10, height = 8, bg = "white")
ggsave(file.path(output_dir, "posterior_delta.png"), plot = p_delta,
       width = 10, height = 8, dpi = 300, bg = "white")
