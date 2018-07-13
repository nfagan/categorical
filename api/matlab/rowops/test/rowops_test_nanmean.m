function rowops_test_nanmean()

n_inds = 100;
max_n_vals = 20;
iters = 1e2;
include_nan = true;

rowops_test_generic( iters, n_inds, max_n_vals ...
  ,  @rownanmean, @(x) nanmean(x, 1), 'nanmean', include_nan );

end
