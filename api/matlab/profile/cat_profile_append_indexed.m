function cat_profile_append_indexed()

f = fcat.example( 'small' );

n_iters = 1e3;

max_inds = 1e3;

cs = zeros( n_iters, 4 );

a = fcat();
b = fcat();

for i = 1:n_iters  
  inds = sort( randperm(length(f), max_inds) );
  
  tic;
  append( a, f, inds );
  cs(i, 1) = toc();
  
  tic;
  append( b, f(inds) );  
  cs(i, 2) = toc();
end

assert( a == b );

c1 = sum( cs(:, 1) );
c2 = sum( cs(:, 2) );

fprintf( '\n fcat: (append indexed)   %0.3f (ms) [%d]', c1 * 1e3, n_iters );
fprintf( '\n fcat: (subs copy)        %0.3f (ms) [%d]', c2 * 1e3, n_iters );
fprintf( '\n' );

end