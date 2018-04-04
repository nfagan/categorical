function rowops_test_nanmean()

n_inds = 100;
max_n_vals = 20;

for i = 1:1e2
  z = rand( 1e3, 1e3 );
  
  I = arrayfun( @(x) sort(uint64(randperm(1e3, randi(max_n_vals, 1, 1)))), 1:n_inds, 'un', false );
  
  rand_nans = randi( numel(z), 1000, 1 );
  z(rand_nans) = NaN;
  
  A = rownanmean( z, I );
  B = like_rownanmean( z, I );
  
  assert( isequaln(A, B) );
end

% test all nans

n_vals = 10;
x = nan( n_vals );
I = arrayfun( @(x) sort(uint64(randperm(n_vals, randi(n_vals, 1, 1)))), 1:n_vals, 'un', false );

A = rownanmean( x, I );
B = like_rownanmean( x, I );

assert( isequaln(A, B) );

x = nan( 10, 2 );
A = rownanmean( x, {uint64(1:10)} );
B = like_rownanmean( x, {uint64(1:10)} );

end

function out = like_rownanmean( a, I )

n_inds = numel( I );
out = zeros( n_inds, size(a, 2) );
for i = 1:n_inds
  out(i, :) = nanmean( a(I{i}, :), 1 );
end

end
