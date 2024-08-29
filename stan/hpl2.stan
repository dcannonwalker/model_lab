functions {
    #include poisson_log_mixture_lpmf.stan
}
data {
    int<lower=1> G;
    int<lower=1> N_g;
    int<lower=1> N_comps;
    int<lower=1> K;
    matrix[N_g, K] X_g;
    array[N_g * G] int<lower=0> y;
    array[N_comps] row_vector[K] comps;
    array[N_comps] real<lower=0, upper=1> prob;
}
transformed data {
    array[G, N_g] int y_g;
    array[N_comps] matrix[N_g, K] X_g_comps;
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
    array[G] vector[K] beta;
}
transformed parameters {
    array[G] vector[N_comps] lp;
    array[G] real lse; // log sum of exponents for each group
    array[G, N_comps] vector[N_g] log_lambda;
    for (g in 1:G) {
        for (i in 1:N_comps) {
            log_lambda[g, i] = X_g_comps[i] * beta[g];
        }
        lp[g] = poisson_log_lpmf_mixture(y_g[g], log_lambda[g], prob);
        lse[g] = log_sum_exp(lp[g]);
    }
}
model {
    for (g in 1:G) {
        beta[g] ~ normal(0, 1);
    }
    target += sum(lse);
}

