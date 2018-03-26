function cat_profile_keep()

x = cat_test_get_mat_categorical();

f = fcat.from( x.c );

n_iters = 1e2;

tic;
c = x.c;
for i = 1:n_iters
  new_cat = c(randperm(size(c, 1)), :);
end
c1 = toc();

%
%
%

tic;
for i = 1:n_iters
  keep( copy(f), randperm(numel(f)) );
end
c2 = toc();

fprintf( '\n categorical (keep): %0.3f (ms)', c1 * 1e3 );
fprintf( '\n fcat        (keep): %0.3f (ms)', c2 * 1e3 );

end