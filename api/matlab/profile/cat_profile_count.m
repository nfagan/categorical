function cat_profile_count()

f = fcat.example( 'small' );
c = categorical( f );
labs = getlabs( f );
nlabs = numel( labs );
max_labs = 2;

iters = 1e3;

cs = zeros( iters, 2 );

for i = 1:iters
  
  ind = randperm( length(f), randi(length(f)) );
  some_labs = labs( randperm(nlabs, randi(max_labs)) );
  
  tic;
  cts = count( f, some_labs, ind );
  cs(i, 1) = toc;
  
  tic;
  cts2 = cellfun( @(x) nnz(c(ind, :) == x), some_labs );
  cs(i, 2) = toc;  
  
  assert( all(cts == cts2) );
end

c1 = sum( cs(:, 1) );
c2 = sum( cs(:, 2) );

fprintf( '\n fcat:        (count) %0.3f (ms) [%d]', c1 * 1e3, iters );
fprintf( '\n categorical: (count) %0.3f (ms) [%d]', c2 * 1e3, iters );
fprintf( '\n' );

end