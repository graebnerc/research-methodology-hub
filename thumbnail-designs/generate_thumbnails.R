# thumbnail-designs/generate_thumbnails.R
#
# Generates 2 candidate thumbnail images per resource category.
# 12 PNGs total, named [category]-a.png and [category]-b.png.
#
# Run from the project root:
#   source("thumbnail-designs/generate_thumbnails.R")
#
# Required packages:
#   install.packages(c("ggplot2", "dplyr", "igraph", "ggraph", "patchwork"))

library(ggplot2)
library(dplyr)
library(igraph)
library(ggraph)
library(patchwork)

# ── Shared constants ──────────────────────────────────────────────────────────

euf <- list(
  blue      = "#00395B",
  grey      = "#6F6F6F",
  red       = "#e65032",
  green     = "#5fb46e",
  lightblue = "#69aacd"
)

BG  <- "#FAFAFA"   # consistent off-white background
W   <- 8           # 8 in × 150 dpi = 1200 px
H   <- 5           # 5 in × 150 dpi =  750 px
DPI <- 150

void_base <- function() {
  theme_void() +
  theme(
    plot.background  = element_rect(fill = BG, colour = NA),
    panel.background = element_rect(fill = BG, colour = NA),
    legend.position  = "none",
    plot.margin      = margin(28, 28, 28, 28)
  )
}

save_png <- function(p, slug) {
  path <- file.path("thumbnail-designs", paste0(slug, ".png"))
  ggsave(path, plot = p, width = W, height = H, dpi = DPI, bg = BG)
  message("saved: ", basename(path))
  invisible(p)
}

set.seed(2026)


# ── 1. STATISTICS ─────────────────────────────────────────────────────────────
#
#  A — Overlapping sampling distributions (bell-curve wave)
#      Concept: sampling variability, inference, distributions
#
#  B — Scatter plot with regression line
#      Concept: relationships in data, regression, estimation

x_seq <- seq(-4.8, 4.8, length.out = 500)

wave_df <- bind_rows(
  data.frame(x = x_seq, y = dnorm(x_seq,  0.00, 1.00), g = "1"),
  data.frame(x = x_seq, y = dnorm(x_seq,  0.50, 0.72), g = "2"),
  data.frame(x = x_seq, y = dnorm(x_seq, -0.40, 1.30), g = "3"),
  data.frame(x = x_seq, y = dnorm(x_seq,  0.10, 0.50), g = "4"),
  data.frame(x = x_seq, y = dnorm(x_seq, -0.10, 1.65), g = "5")
)
wave_pal <- colorRampPalette(c(euf$lightblue, euf$blue))(5)

p_stat_a <- ggplot(wave_df, aes(x, y, group = g, colour = g, fill = g)) +
  geom_area(alpha = 0.20, position = "identity") +
  geom_line(linewidth = 1.8) +
  scale_colour_manual(values = wave_pal) +
  scale_fill_manual(values = wave_pal) +
  void_base()

save_png(p_stat_a, "statistics-a")

# ----

df_scat <- data.frame(x = runif(140, -3.2, 3.2)) |>
  mutate(y = 0.65 * x + rnorm(n(), 0, 0.9))

p_stat_b <- ggplot(df_scat, aes(x, y)) +
  geom_point(colour = euf$lightblue, alpha = 0.70, size = 2.5, shape = 16) +
  geom_smooth(method = "lm", formula = y ~ x, se = TRUE,
              colour = euf$red, fill = euf$red, alpha = 0.12,
              linewidth = 2.2) +
  void_base()

save_png(p_stat_b, "statistics-b")


# ── 2. CAUSAL INFERENCE ───────────────────────────────────────────────────────
#
#  A — Directed acyclic graph (DAG)
#      Concept: causal structure, confounding, mediation
#
#  B — Potential outcomes: two trajectories diverging at treatment
#      Concept: counterfactuals, treatment effect, parallel worlds

ci_nodes <- data.frame(
  name = c("Z",  "X",  "M",  "Y",  "U"),
  x    = c(0.50, 0.00, 0.50, 1.00, 1.00),
  y    = c(0.82, 0.50, 0.50, 0.50, 0.18)
)
ci_edges <- data.frame(
  from = c("Z", "Z", "X", "M", "U"),
  to   = c("X", "Y", "M", "Y", "Y")
)

g_ci <- graph_from_data_frame(ci_edges, directed = TRUE, vertices = ci_nodes)

p_ci_a <- ggraph(g_ci, layout = "manual", x = ci_nodes$x, y = ci_nodes$y) +
  geom_edge_link(
    arrow     = arrow(length = unit(9, "pt"), type = "closed"),
    end_cap   = circle(17, "pt"),
    colour    = euf$grey,
    linewidth = 1.1,
    alpha     = 0.85
  ) +
  geom_node_point(size = 17, colour = euf$blue) +
  geom_node_text(aes(label = name), colour = "white",
                 fontface = "bold", size = 5.0) +
  scale_x_continuous(expand = expansion(mult = 0.18)) +
  scale_y_continuous(expand = expansion(mult = 0.18)) +
  theme_graph(background = BG) +
  theme(plot.background = element_rect(fill = BG, colour = NA),
        plot.margin     = margin(20, 20, 20, 20))

save_png(p_ci_a, "causal-inference-a")

# ----

t_seq  <- seq(0, 1, length.out = 200)
tr_cut <- 0.45

treated_y <- ifelse(t_seq < tr_cut,
                    0.15 * t_seq,
                    0.15 * tr_cut + 1.10 * (t_seq - tr_cut))
control_y <- ifelse(t_seq < tr_cut,
                    0.15 * t_seq,
                    0.15 * tr_cut + 0.18 * (t_seq - tr_cut))

po_df <- data.frame(
  t   = rep(t_seq, 2),
  y   = c(treated_y, control_y),
  grp = rep(c("Treated", "Control"), each = 200)
)

p_ci_b <- ggplot(po_df, aes(t, y, colour = grp, group = grp)) +
  annotate("rect",
           xmin = tr_cut - 0.015, xmax = tr_cut + 0.015,
           ymin = -Inf, ymax = Inf,
           fill = euf$grey, alpha = 0.25) +
  geom_line(linewidth = 2.4) +
  scale_colour_manual(
    values = c(Treated = euf$red, Control = euf$lightblue)
  ) +
  void_base()

save_png(p_ci_b, "causal-inference-b")


# ── 3. R PROGRAMMING ──────────────────────────────────────────────────────────
#
#  A — 2×3 gallery of mini-plots (bar, area+line, scatter,
#                                  density, boxplot, heat map)
#      Concept: the variety of outputs R produces
#
#  B — Bold horizontal bars in EUF palette
#      Concept: clean data visualisation, ggplot aesthetic

mini_theme <- function() {
  theme_minimal(base_size = 8) +
  theme(
    plot.background  = element_rect(fill = BG, colour = euf$grey, linewidth = 0.4),
    panel.background = element_rect(fill = BG, colour = NA),
    axis.text        = element_blank(),
    axis.title       = element_blank(),
    axis.ticks       = element_blank(),
    panel.grid       = element_blank(),
    legend.position  = "none",
    plot.margin      = margin(8, 8, 8, 8)
  )
}

# bar chart
df_bar <- data.frame(cat = letters[1:6],
                     v   = c(3.1, 4.8, 2.2, 5.5, 3.9, 4.2))
p_m1 <- ggplot(df_bar, aes(cat, v, fill = cat)) +
  geom_col() +
  scale_fill_manual(values = c(euf$blue, euf$lightblue, euf$red,
                               euf$green, euf$grey, euf$blue)) +
  mini_theme()

# area + line
df_line <- data.frame(t = 1:40, v = cumsum(rnorm(40, 0.1, 0.6)))
p_m2 <- ggplot(df_line, aes(t, v)) +
  geom_area(fill = euf$lightblue, alpha = 0.35) +
  geom_line(colour = euf$blue, linewidth = 1.0) +
  mini_theme()

# scatter
df_sc <- data.frame(x = rnorm(80), y = rnorm(80))
p_m3 <- ggplot(df_sc, aes(x, y)) +
  geom_point(colour = euf$red, alpha = 0.60, size = 1.4) +
  mini_theme()

# density
df_dn <- data.frame(v = c(rnorm(80, 0, 1), rnorm(50, 2.5, 0.8)))
p_m4 <- ggplot(df_dn, aes(v)) +
  geom_density(fill = euf$lightblue, colour = euf$blue,
               alpha = 0.55, linewidth = 0.9) +
  mini_theme()

# boxplot
df_bx <- data.frame(
  g = rep(c("A", "B", "C"), each = 40),
  v = c(rnorm(40, 0, 1), rnorm(40, 1, 0.8), rnorm(40, -0.5, 1.2))
)
p_m5 <- ggplot(df_bx, aes(g, v, fill = g)) +
  geom_boxplot(outlier.size = 0.6, colour = euf$grey, linewidth = 0.5) +
  scale_fill_manual(values = c(euf$blue, euf$lightblue, euf$green)) +
  mini_theme()

# heat map
hm_df <- expand.grid(x = 1:10, y = 1:6)
hm_df$z <- rnorm(60)
p_m6 <- ggplot(hm_df, aes(factor(x), factor(y), fill = z)) +
  geom_tile(colour = BG, linewidth = 0.5) +
  scale_fill_gradient2(low = euf$blue, mid = "white", high = euf$red,
                       midpoint = 0) +
  mini_theme()

p_r_a <- (p_m1 | p_m2 | p_m3) / (p_m4 | p_m5 | p_m6) +
  plot_annotation(theme = theme(
    plot.background = element_rect(fill = BG, colour = NA),
    plot.margin     = margin(18, 18, 18, 18)
  ))

save_png(p_r_a, "r-programming-a")

# ----

bar_df <- data.frame(
  id    = factor(7:1),
  value = c(0.88, 0.55, 0.73, 0.47, 0.68, 0.61, 0.82),
  fill  = c(euf$blue, euf$red, euf$lightblue, euf$green,
            euf$blue, euf$red, euf$lightblue)
)

p_r_b <- ggplot(bar_df, aes(y = id, x = value, fill = id)) +
  geom_col(width = 0.70) +
  scale_fill_manual(values = setNames(bar_df$fill, as.character(bar_df$id))) +
  void_base()

save_png(p_r_b, "r-programming-b")


# ── 4. EPISTEMOLOGY ───────────────────────────────────────────────────────────
#
#  A — Concentric open arcs (like an unrolled onion)
#      Concept: layers of inquiry — ontology → epistemology → methodology
#
#  B — Three overlapping translucent circles (Venn-like)
#      Concept: intersection of theory, reality, and knowledge

make_arc <- function(r, from_deg = -200, to_deg = 20, n = 400) {
  theta <- seq(from_deg * pi / 180, to_deg * pi / 180, length.out = n)
  data.frame(x = r * cos(theta), y = r * sin(theta))
}

radii   <- c(0.28, 0.52, 0.76, 1.00, 1.24)
arc_pal <- colorRampPalette(c(euf$lightblue, euf$blue))(5)

arc_df <- bind_rows(lapply(seq_along(radii), function(i) {
  d     <- make_arc(radii[i])
  d$grp <- i
  d
}))

p_ep_a <- ggplot(arc_df, aes(x, y, group = grp, colour = factor(grp))) +
  geom_path(linewidth = 2.5) +
  scale_colour_manual(values = arc_pal) +
  coord_equal() +
  void_base()

save_png(p_ep_a, "epistemology-a")

# ----

circle_path <- function(cx, cy, r, id, n = 360) {
  theta <- seq(0, 2 * pi, length.out = n)
  data.frame(x = cx + r * cos(theta), y = cy + r * sin(theta), id = id)
}

ven_df <- bind_rows(
  circle_path(-0.38,  0.22, 0.68, "A"),
  circle_path( 0.38,  0.22, 0.68, "B"),
  circle_path( 0.00, -0.30, 0.68, "C")
)

p_ep_b <- ggplot(ven_df, aes(x, y, group = id)) +
  geom_polygon(aes(fill = id), alpha = 0.28) +
  geom_path(aes(colour = id), linewidth = 1.8) +
  scale_fill_manual(values   = c(A = euf$blue, B = euf$red, C = euf$lightblue)) +
  scale_colour_manual(values = c(A = euf$blue, B = euf$red, C = euf$lightblue)) +
  coord_equal() +
  void_base()

save_png(p_ep_b, "epistemology-b")


# ── 5. LITERATURE REVIEW ──────────────────────────────────────────────────────
#
#  A — Citation network (nodes sized by in-degree)
#      Concept: papers citing papers, clusters of literature
#
#  B — Systematic review funnel (bars narrowing toward inclusion)
#      Concept: screening, assessment, selection

n_papers  <- 24
paper_ids <- paste0("p", seq_len(n_papers))

from_nodes <- c(sample(1:6,  14, replace = TRUE),
                sample(1:16, 10, replace = TRUE))
to_nodes   <- c(sample(7:24, 14, replace = TRUE),
                sample(7:24, 10, replace = TRUE))

edge_lr <- data.frame(
  from = paper_ids[from_nodes],
  to   = paper_ids[to_nodes]
) |> distinct() |> filter(from != to)

g_lr <- graph_from_data_frame(
  edge_lr, directed = TRUE,
  vertices = data.frame(name = paper_ids)
)
V(g_lr)$deg <- degree(g_lr, mode = "in") + 1

p_lr_a <- ggraph(g_lr, layout = "fr") +
  geom_edge_link(
    colour    = euf$grey,
    alpha     = 0.45,
    linewidth = 0.65,
    arrow     = arrow(length = unit(5, "pt"), type = "open"),
    end_cap   = circle(7, "pt")
  ) +
  geom_node_point(aes(size = deg), colour = euf$blue, alpha = 0.88) +
  scale_size(range = c(3, 14)) +
  theme_graph(background = BG) +
  theme(
    plot.background = element_rect(fill = BG, colour = NA),
    legend.position = "none",
    plot.margin     = margin(16, 16, 16, 16)
  )

save_png(p_lr_a, "literature-review-a")

# ----
# dark at top (many candidates), light at bottom (few included)
funnel_pal <- colorRampPalette(c(euf$blue, euf$lightblue))(4)

funnel_df <- data.frame(
  stage = 1:4,
  width = c(0.10, 0.28, 0.62, 1.00)
)

p_lr_b <- ggplot(funnel_df) +
  geom_rect(
    aes(xmin = -width / 2, xmax = width / 2,
        ymin = stage - 0.40, ymax = stage + 0.40,
        fill = factor(stage)),
    colour = NA
  ) +
  scale_fill_manual(values = setNames(funnel_pal, as.character(1:4))) +
  xlim(-0.6, 0.6) +
  void_base()

save_png(p_lr_b, "literature-review-b")


# ── 6. RESEARCH DESIGN ───────────────────────────────────────────────────────
#
#  A — Linear process flow (boxes connected by arrows)
#      Concept: structured steps from theory to findings
#
#  B — Research cycle (six nodes in a closed loop)
#      Concept: iterative, cyclical nature of research

flow_steps <- data.frame(
  x     = c(0.12, 0.37, 0.63, 0.88),
  label = c("Theory", "Design", "Data", "Findings")
)
flow_arrows <- data.frame(
  x    = flow_steps$x[-4] + 0.11,
  xend = flow_steps$x[-1] - 0.11,
  y = 0.50, yend = 0.50
)

p_rd_a <- ggplot() +
  geom_rect(
    data = flow_steps,
    aes(xmin = x - 0.10, xmax = x + 0.10,
        ymin = 0.35,      ymax = 0.65),
    fill = euf$blue, colour = NA
  ) +
  geom_segment(
    data = flow_arrows,
    aes(x = x, xend = xend, y = y, yend = yend),
    arrow     = arrow(length = unit(10, "pt"), type = "closed"),
    colour    = euf$grey,
    linewidth = 1.5
  ) +
  geom_text(
    data = flow_steps,
    aes(x = x, y = 0.50, label = label),
    colour   = "white",
    fontface = "bold",
    size     = 4.8
  ) +
  xlim(0, 1) + ylim(0.1, 0.9) +
  void_base()

save_png(p_rd_a, "research-design-a")

# ----

n_cyc  <- 6
angles <- seq(pi / 2, pi / 2 - 2 * pi, length.out = n_cyc + 1)[-(n_cyc + 1)]
r_cyc  <- 0.78

cycle_nodes <- data.frame(
  x     = r_cyc * cos(angles),
  y     = r_cyc * sin(angles),
  label = c("Theory", "Hypothesis", "Data\nCollection",
            "Analysis", "Findings", "Revision")
)

curve_df <- do.call(rbind, lapply(seq_len(n_cyc), function(i) {
  j <- (i %% n_cyc) + 1
  data.frame(
    x    = cycle_nodes$x[i], y    = cycle_nodes$y[i],
    xend = cycle_nodes$x[j], yend = cycle_nodes$y[j]
  )
}))

p_rd_b <- ggplot() +
  geom_curve(
    data = curve_df,
    aes(x = x, y = y, xend = xend, yend = yend),
    arrow     = arrow(length = unit(9, "pt"), type = "closed"),
    curvature = 0.28,
    colour    = euf$grey,
    linewidth = 1.1,
    alpha     = 0.90
  ) +
  geom_point(data = cycle_nodes, aes(x, y),
             size = 20, colour = euf$blue) +
  geom_text(data = cycle_nodes, aes(x, y, label = label),
            colour = "white", fontface = "bold",
            size = 2.9, lineheight = 0.82) +
  coord_equal(xlim = c(-1.35, 1.35), ylim = c(-1.35, 1.35)) +
  void_base()

save_png(p_rd_b, "research-design-b")

message("\n── All 12 thumbnails saved to thumbnail-designs/ ────────────────────")
