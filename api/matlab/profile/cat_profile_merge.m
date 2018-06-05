function cat_profile_merge()

x = fcat.example();

y = x(randperm(length(x)));

n_iters = 1e3;

tic;
for i = 1:n_iters
  z = merge( copy(x), y );
end
c1 = toc();

fprintf( '\n fcat: %0.3f (ms) [%d]', c1 * 1e3, n_iters );

end