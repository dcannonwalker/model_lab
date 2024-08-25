#include kronecker.stan
data {
    int<lower=1> G;
    int<lower=1> N_g;
    int<lower=1> N;
    matrix[N_g, K] X_g;
    array[N] int<lower=0> y;
}
transformed data {
    matrix[G, G] I_g = diag_matrix(rep_vector(1, G));
    matrix[N, K] X;
    matrix[N, K] X_star;
    X = kronecker()
}
parameters {
    array[G, K] beta;

}
