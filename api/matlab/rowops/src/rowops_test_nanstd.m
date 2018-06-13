function rowops_test_nanstd()

n_inds = 100;
max_n_vals = 20;
iters = 1e2;
include_nan = true;

rowops_test_generic( iters, n_inds, max_n_vals ...
  ,  @rownanstd, @(x) nanstd(x, [], 1), 'nanstd', include_nan );

end