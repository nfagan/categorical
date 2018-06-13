function rowops_test_mean()

n_inds = 100;
max_n_vals = 20;
iters = 1e2;

rowops_test_generic( iters, n_inds, max_n_vals, @rowmean, @(x) mean(x, 1), 'mean' );

end