function cat_profile_setcats()

iters = 1e3;

x = cat_test_get_mat_categorical();
x = fcat.from( x.c, x.f );

sz = 100;

x = x(1:sz);

tic;
vals = cellstr( x );
for i = 1:iters
  setcats( x, getcats(x), vals );
end
c1 = toc;

tic;
vals = x(1:sz, :);
for i = 1:iters
  x(:, :) = vals;
end
c2 = toc;

fprintf( '\n fcat:        %0.3f (ms) [%d]', c1 * 1e3, iters );
fprintf( '\n fcat: (subs) %0.3f (ms) [%d]', c2 * 1e3, iters );

end