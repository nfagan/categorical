function cat_profile_copy()

x = fcat.example();

n_iters = 1e4;

tic;
for i = 1:n_iters
  f = copy( x );
end
c1 = toc();

tic;
for i = 1:n_iters
  f2 = append( fcat(), x );
end
c2 = toc();

assert( f == f2 );

fprintf( '\n fcat   (copy): %0.3f (ms) [%d]', c1 * 1e3, n_iters );
fprintf( '\n fcat (append): %0.3f (ms) [%d]', c2 * 1e3, n_iters );
fprintf( '\n' );

end