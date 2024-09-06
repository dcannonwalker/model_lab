library(cmdstanr)
library(posterior)
file <- file.path("stan/hpl2.stan")
mod <- cmdstan_model(file)

hpl2_data <- list(
    G = 100,
    N_g = 8,
    K = 4,
    N_comps = 2,
    comps = rbind(1, c(1, 1, 1, 0)),
    prob = c(0.5, 0.5),
    N_mix = 1,
    comps_per_mix = 1,
    mix_idx = matrix(1),
    y = rpois(800, lambda = 10),
    X_g = cbind(1, rep(c(0, 1), each = 4),
                rep(c(0, 1, 0, 1), each = 2), c(rep(0, 6), rep(1, 2))),
    run_estimation = 0
)

sim_out <- mod$sample(data = hpl2_data, iter_warmup = 100,
                      iter_sampling = 1000, parallel_chains = 4)
?as_rvar
# y_sim <- sim_out$draws(variables = "y_g_sim")
y_sim <- extract_variable_array(sim_out$draws(), "y_g_sim")
which_comp <- extract_variable_array(sim_out$draws(), "which_comp")
str(which_comp)
str(y_sim)
which_comp_single <- which_comp[1, 1, ]
y_sim_single <- y_sim[1, 1, , ]
y_sim_single
which_comp_single
