real poisson_log_mixture_lpmf(
    array[] int y,
    array[] log_lambda,
    array[] prob
    ) {
        n_comps = size(log_lambda);
        if (size(prob) != n_comps) {
            fatal_error("size(prob) must match size(log_lambda)");
        }
        vector[n_comps] comps;
        for (i in 1:n_comps) {
            comps[i] = prob[i] + poisson_log_lpmf(y | log_lambda[i]);
        }
        return(log_sum_exp(comps));
    }
