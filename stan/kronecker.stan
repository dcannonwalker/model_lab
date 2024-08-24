matrix kronecker(matrix A, matrix B) {
    matrix[rows(A) * rows(B), cols(A) * cols(B)] C;
    int m, n, p, q;
    m = rows(A);
    n = cols(A);
    p = rows(B);
    q = cols(B);
    for (i in 1:m) {
        for (j in 1:n) {
            int rs, re, cs, ce; // row and column start and end indices
            rs = (i - 1) * p + 1;
            re = i * p;
            cs = (j - 1) * q + 1;
            ce = j * q;
            C[rs:re, cs:ce] = A[i, j] * B;
        }
    }
    return(C);
}
