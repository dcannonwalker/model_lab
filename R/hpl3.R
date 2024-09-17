library(cmdstanr)
library(posterior)
file <- file.path("stan/hpl3.stan")
mod <- cmdstanr::cmdstan_model(file)

hpl3_data <- list(
    G = 20,
    N_g = 8,
    K = 3,
    U = 4,
    N_comps = 2,
    comps = rbind(1, c(1, 1, 0)),
    prob = c(0.5, 0.5),
    N_mix = 1,
    comps_per_mix = 1,
    mix_idx = matrix(1),
    y = rpois(160, lambda = 10),
    X_g = cbind(rep(c(0, 1), each = 4),
                rep(c(0, 1, 0, 1), each = 2), c(rep(0, 6), rep(1, 2))),
    Z_g = rbind(diag(1, 4), diag(1, 4)),
    run_estimation = 0,
    a_sig2 = rep(10, 3),
    b_sig2 = rep(10, 3),
    a_mu_offset = 5,
    b_mu_offset = 1,
    a_sig2_offset = 10,
    b_sig2_offset = 10,
    a_sig2_u = rep(10, 4),
    b_sig2_u = rep(10, 4)
)

sim_out <- mod$sample(data = hpl3_data, seed = 17, chains = 1, iter_warmup = 10, iter_sampling = 100)

# extract one draw of simulated y ----
y_sim <- extract_variable_array(sim_out$draws(), "y_g_sim")
which_comp <- extract_variable_array(sim_out$draws(), "which_comp")
y_sim_single <- y_sim[1, 1, , ]
which_comp_single <- which_comp[1, 1, ]
y_sim_single

hpl3_data$y <- c(t(y_sim_single))
hpl3_data$run_estimation <- 1

fit <- mod$sample(data = hpl3_data, seed = 17, chains = 2, parallel_chains = 2, iter_warmup = 1000, iter_sampling = 100)

profile_G <- function(G, mod, iter_warmup = 1000, iter_sampling = 1000,
                      chains = 2, parallel_chains = 2) {
    d <- list(
        G = G,
        N_g = 8,
        K = 3,
        U = 4,
        N_comps = 2,
        comps = rbind(1, c(1, 1, 0)),
        prob = c(0.5, 0.5),
        N_mix = 1,
        comps_per_mix = 1,
        mix_idx = matrix(1),
        y = rpois(G * 8, lambda = 10),
        X_g = cbind(rep(c(0, 1), each = 4),
                    rep(c(0, 1, 0, 1), each = 2), c(rep(0, 6), rep(1, 2))),
        Z_g = rbind(diag(1, 4), diag(1, 4)),
        run_estimation = 0,
        a_sig2 = rep(10, 3),
        b_sig2 = rep(10, 3),
        a_mu_offset = 5,
        b_mu_offset = 1,
        a_sig2_offset = 10,
        b_sig2_offset = 10,
        a_sig2_u = rep(10, 4),
        b_sig2_u = rep(10, 4)
    )

    s <- mod$sample(data = d, seed = 17, chains = 1, iter_warmup = 10, iter_sampling = 100)

    y_sim <- extract_variable_array(s$draws(), "y_g_sim")
    which_comp <- extract_variable_array(s$draws(), "which_comp")
    y_sim_single <- y_sim[1, 1, , ]
    which_comp_single <- which_comp[1, 1, ]

    d$y <- c(t(y_sim_single))
    d$run_estimation <- 1

    fit <- mod$sample(data = d, seed = 17, chains = chains,
                      parallel_chains = parallel_chains, iter_warmup = iter_warmup,
                      iter_sampling = iter_sampling)

    fit$time()
}

G_list <- as.list(seq(100, 1000, by = 100))
names(G_list) <- G_list

G_profile <- lapply(G_list, profile_G, mod = mod, iter_warmup = 100, iter_sampling = 100)

total <- sapply(G_profile, function(.x) {.x$total})
lm(total ~ as.numeric(names(total)))
plot(names(total), total)

