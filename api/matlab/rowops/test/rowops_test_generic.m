function rowops_test_generic(iters, n_inds, max_n_vals, test_func, equiv_func, name, include_nan)

%   ROWOPS_TEST_GENERIC -- Run generic test.
%
%     IN:
%       - `iters` (double) -- Number of iterations.
%       - `n_inds` (double) -- Number of indices of subsets.
%       - `max_n_vals` (double) -- Maximum number of indices per subset.
%       - `test_func` (function_handle) -- Handle to rowop function to
%         test.
%       - `equiv_func` (function_handle) -- Handle to matlab function
%         that should produce equivalent output to `test_func`, and against
%         which `test_func` will be compared.
%       - `name` (char) -- Name of test, in case it fails.
%       - `include_nan` (logical) |OPTIONAL| -- True if nan values should 
%         be randomly inserted. Default is `false`.

if ( nargin < 7 ), include_nan = false; end

for i = 1:iters
  z = rand( 1e3, 1e3 );
  
  I = arrayfun( @(x) sort(uint64(randperm(1e3, randi(max_n_vals, 1, 1)))), 1:n_inds, 'un', false );
  
  if ( include_nan )
    rand_nans = randi( numel(z), 1e3, 1 );
    z(rand_nans) = NaN;
  end
  
  A = test_func( z, I );
  B = rowop( z, I, equiv_func );
  
  assert( isequaln(A, B), 'Subsets for function "%s" did not match equivalent matlab result.', name );
end

if ( ~include_nan ), return; end

% test all nans
n_vals = 10;
x = nan( n_vals );
I = arrayfun( @(x) sort(uint64(randperm(n_vals, randi(n_vals, 1, 1)))), 1:n_vals, 'un', false );

A = test_func( x, I );
B = rowop( x, I, equiv_func );

assert( isequaln(A, B), 'All NaN subsets were not equal for "%s".', name );

% test single NaN
x = [ NaN; 1 ];
inds = { uint64([1, 2]) };

A = test_func( x, inds );
B = rowop( x, inds, equiv_func );

assert( isequaln(A, B), 'Single NaN subsets were not equal for "%s".', name );

end