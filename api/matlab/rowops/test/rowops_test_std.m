function rowops_test_std()

n_inds = 100;
max_n_vals = 20;
iters = 1e2;

rowops_test_generic( iters, n_inds, max_n_vals, @rowstd, @(x) std(x, [], 1), 'std' );

% additional case when N is 1

z = rand( 1, 100 );
inds = { uint64(1) };

x = rowstd( z, inds );
y = rowop( z, inds, @(x) std(x, [], 1) );

assert( isequaln(x, y), 'Single subsets were not equal.' );

end