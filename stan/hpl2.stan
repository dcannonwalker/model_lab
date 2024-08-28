#include poisson_log_mixture_lpmf.stan
data {
    int<lower=1> G;
    int<lower=1> N_g;
    int<lower=1> N_comps;
    matrix[N_g, K] X_g;
    array[N] int<lower=0> y;
    array[N_comps, K] int<lower=0, upper=1> comps
}
transformed data {
    array[G, N_g] int y_g;
    array[N_comps, N_g, K] matrix X_g_comps;
    for (g in 1:G) {
        y_g[g] = y[N_g * (g - 1) + 1:N_g * g];
    }
    for (i in 1:N_comps) {
        matrix[N_g, K] rbind_comps;
        for (r in 1:N_g) {
            rbind_comps[r, ] = comps[i];
        }
        X_g_comps[i] = X_g .* rbind_comps;
    }
}
parameters {
    array[G, K] beta;
}
transformed parameters {

}
