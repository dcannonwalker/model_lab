# setup ----
library(cmdstanr)
library(posterior)
library(bayesplot)
file <- file.path("stan/hpl2.stan")
mod <- cmdstan_model(file)
hpl2_data <- list(
    G = 100,
    N_g = 8,
    K = 3,
    N_comps = 2,
    comps = rbind(1, c(1, 1, 0)),
    prob = c(0.5, 0.5),
    N_mix = 1,
    comps_per_mix = 1,
    mix_idx = matrix(1),
    y = rpois(800, lambda = 10),
    X_g = cbind(rep(c(0, 1), each = 4),
                rep(c(0, 1, 0, 1), each = 2), c(rep(0, 6), rep(1, 2))),
    run_estimation = 0,
    a_sig2 = rep(10, 3),
    b_sig2 = rep(10, 3),
    a_mu_offset = 5,
    b_mu_offset = 1,
    a_sig2_offset = 10,
    b_sig2_offset = 10
)

# simulate dependent var ----
sim_out <- mod$sample(data = hpl2_data, iter_warmup = 1000,
                      iter_sampling = 1000, parallel_chains = 4)

# extract one draw of simulated y ----
beta_sim <- extract_variable_array(sim_out$draws(), "beta")
beta_sim[1, 1, , ]
mu_sim <- extract_variable_array(sim_out$draws(), "mu")
mu_sim[1, 1, ]
y_sim <- extract_variable_array(sim_out$draws(), "y_g_sim")
which_comp <- extract_variable_array(sim_out$draws(), "which_comp")
which_comp_single <- which_comp[1, 1, ]
y_sim_single <- y_sim[1, 1, , ]
y_sim_single

# fit model to simulated y ----
hpl2_data$y <- c(t(y_sim_single))
hpl2_data$run_estimation <- 1
fit <- mod$sample(data = hpl2_data, iter_warmup = 3000, iter_sampling = 1000, chains = 2, parallel_chains = 2)

# examine model fit ----
fit$metadata()$model_params
fit$output()
fit$cmdstan_summary()
draws <- posterior::as_draws_rvars(fit$draws())
draws$p_dg
draws$beta
draws$lp

data.frame(which_comp_single, draws$lp, draws$p_dg) |>
    dplyr::arrange(which_comp_single)
y_sim_single
Lp <- exp(draws$lp)

beta1 <- draws$beta[1, ]
os1 <- draws$log_offset[1]
y1 <- y_sim_single[1, ]
which_comp_single[1]

exp(os1 + beta1[1] + beta1[2])
draws$mu_offset
draws$mu
