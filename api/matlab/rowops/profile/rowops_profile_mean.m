function rowops_profile_mean()

n_inds = [ 1e1, 1e2, 1e3, 1e4 ];
max_n_vals = [ 20, 100 ];
szs = [ 1e3, 1e4, 1e5, 1e6 ];
n_iters = 100;

inds = allcombn( numel(n_inds), numel(max_n_vals), numel(szs) );

for i = 1:size(inds, 1)
  run( n_inds(inds(i, 1)), max_n_vals(inds(i, 2)), n_iters, szs(inds(i, 3)) );
end

end

function run(n_inds, max_n_vals, n_iters, sz)

row_times = zeros( n_iters, 1 );
mat_times = zeros( size(row_times) );
mat_cell_times = zeros( size(row_times) );

for i = 1:n_iters
  z = rand( sz, 10 );
  
  I = arrayfun( @(x) sort(uint64(randperm(sz, randi(max_n_vals, 1, 1)))) ...
    , 1:n_inds, 'un', false );
  
  tic;
  A = rowmean( z, I );
  row_times(i) = toc;
  
  tic;
  B = like_rowmean( z, I );
  mat_times(i) = toc;
  
  tic;
  C = cellfun_like_rowmean( z, I );
  mat_cell_times(i) = toc;
  
  assert( isequal(A, B) );
end

m_row_time = mean( row_times );
m_mat_time = mean( mat_times );
m_mat_cell_time = mean( mat_cell_times );

fprintf( '\n Size: %d\n N indices: %d\n Max N Rows: %d', sz, n_inds, max_n_vals );
fprintf( '\n Mean row:          %0.4f (ms)', m_row_time * 1e3 );
fprintf( '\n Mean mat:          %0.4f (ms)', m_mat_time * 1e3 );
fprintf( '\n Mean mat (cell):   %0.4f (ms)', m_mat_cell_time * 1e3 );
fprintf( '\n Ratio (row / mat): %0.3f', m_row_time/m_mat_time );
fprintf( '\n' );

end

function out = cellfun_like_rowmean( a, I )

out = cell2mat( cellfun(@(x) mean(a(x, :), 1), I, 'un', false) );

end

function out = like_rowmean( a, I )

n_inds = numel( I );
out = zeros( n_inds, size(a, 2) );
for i = 1:n_inds
  out(i, :) = mean( a(I{i}, :), 1 );
end

end