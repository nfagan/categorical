function rowops_test_generic(iters, n_inds, max_n_vals, test_func, equiv_func, name)

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
%     

for i = 1:iters
  z = rand( 1e3, 1e3 );
  
  I = arrayfun( @(x) sort(uint64(randperm(1e3, randi(max_n_vals, 1, 1)))), 1:n_inds, 'un', false );
  
  A = test_func( z, I );
  B = like_rowop( z, I, equiv_func );
  
  assert( isequaln(A, B), 'Subsets for function "%s" did not match equivalent matlab result.', name );
end


end

function out = like_rowop( a, I, func )

n_inds = numel( I );
out = zeros( n_inds, size(a, 2) );
for i = 1:n_inds
  out(i, :) = func( a(I{i}, :) );
end

end