data {
    int<lower=1> G; // number of groups
    int<lower=1> N_g; // number of observations per group
    int<lower=1> K; // number of columns in the model matrix (excluding the intercept)
    array[N_g * G] int<lower=0> y;
    matrix[N_g, K] X_g; // model matrix for a single group (excluding the intercept)
    int<lower=0, upper=1> run_estimation;
    array[K] real<lower=0> a_sig2; // shape
    array[K] real<lower=0> b_sig2; // scale
    real<lower=0> a_mu_offset; // location
    real<lower=0> b_mu_offset; // scale
    real<lower=0> a_sig2_offset; // shape
    real<lower=0> b_sig2_offset; // scale
}
transformed data {
    array[G, N_g] int<lower=0> y_g;
    for (g in 1:G) {
        y_g[g] = y[N_g * (g - 1) + 1:N_g * g];
    }
}
parameters {
    array[G] vector[K] beta;
    vector[G] log_offset; // log scale offset or intercept
    vector[K] mu;
    vector<lower=0>[K] sig2;
    real mu_offset;
    real<lower=0> sig2_offset;
}
transformed parameters {
    array[G] vector[N_g] log_lambda;
    for (g in 1:G) {
        log_lambda[g] = log_offset[g] + X_g * beta[g];
    }
}
model {
    mu ~ normal(0, 1);
    sig2 ~ inv_gamma(a_sig2, b_sig2);
    log_offset ~ normal(mu_offset, sig2_offset);
    mu_offset ~ normal(a_mu_offset, b_mu_offset);
    sig2_offset ~ inv_gamma(a_sig2_offset, b_sig2_offset);
    for (g in 1:G) {
        beta[g] ~ normal(mu, sig2);
        if(run_estimation == 1) {
            y_g[g] ~ poisson_log(log_lambda[g]);
        }
    }
}
generated quantities {
    array[G, N_g] int y_g_sim;
    for (g in 1:G) {
        y_g_sim[g] = poisson_log_rng(log_lambda[g]);
    }
}
