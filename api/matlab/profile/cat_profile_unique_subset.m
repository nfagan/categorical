function cat_profile_unique_subset()

f = fcat.example( 'large' );
c = categorical( f );

cats = getcats( f );
nc = numel( cats );

max_n_inds = 100;

n_iters = 1e2;

cs = zeros( n_iters, 2 );

for i = 1:n_iters
  
  some_cats = cats( randperm(nc, randi(nc)) );
  some_rows = sort( randperm(length(f), randi(max_n_inds)) );
  
  tic;
  [~, cind] = ismember( some_cats, cats );
  unqs1 = unique( c(some_rows, cind), 'rows' );
  cs(i, 1) = toc();
  
  tic;
  unqs2 = combs( f, some_cats, some_rows );
  cs(i, 2) = toc();   
  
end

c1 = mean( cs(:, 1) );
c2 = mean( cs(:, 2) );

fprintf( '\n categorical:   %0.3f (ms) [%d]', c1 * 1e3, n_iters );
fprintf( '\n fcat:          %0.3f (ms) [%d]', c2 * 1e3, n_iters );
fprintf( '\n' );


end