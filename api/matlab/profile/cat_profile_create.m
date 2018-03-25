function cat_profile_create()

eg = cat_test_get_mat_categorical();

n_iters = 1e1;

X = cellstr( [eg.c; eg.c; eg.c] );

c1 = zeros( n_iters, 1 );
c2 = zeros( n_iters, 1 );

cats = eg.f;

for i = 1:n_iters  
  tic;
  categ = categorical( X );
  c1(i) = toc;
  
  tic;
  C = requirecat( fcat(), cats );
  for j = 1:numel(cats)
    setcat( C, cats{j}, X(:, j) );
  end
  c2(i) = toc();
  
  delete( C );
end

fprintf( '\n categorical: %0.3f (ms) [%d]', mean(c1) * 1e3, n_iters );
fprintf( '\n fcat:        %0.3f (ms) [%d]', mean(c2) * 1e3, n_iters );

end