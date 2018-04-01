function rowops_test_mean()

n_inds = 100;
max_n_vals = 20;

for i = 1:1e2
  z = rand( 1e3, 1e3 );
  
  I = arrayfun( @(x) sort(uint64(randperm(1e3, randi(max_n_vals, 1, 1)))), 1:n_inds, 'un', false );
  
  A = rowmean( z, I );
  B = like_rowmean( z, I );
  
  assert( isequal(A, B) );
end

end

function out = like_rowmean( a, I )

n_inds = numel( I );
out = zeros( n_inds, size(a, 2) );
for i = 1:n_inds
  out(i, :) = mean( a(I{i}, :), 1 );
end

end
