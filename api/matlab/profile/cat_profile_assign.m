function cat_profile_assign()

x = cat_test_get_mat_categorical();

c = [x.c; x.c; x.c; x.c; x.c];

f = fcat.from( c, x.f );

n_iters = 1e2;

%   categorical - preallocate 
new_cat = categorical();
new_cat(n_iters, numel(x.f)) = '<undefined>';
indices = randperm( numel(f), n_iters );

tic;
new_cat(:, :) = c(indices, :);
c1 = toc;

%   fcat - preallocate

new_f = fcat.with( x.f, n_iters );

tic;
new_f(1:numel(new_f)) = f(indices);
c2 = toc;

fprintf( '\n categorical (subscripts): %0.3f (ms)', c1 * 1e3 );
fprintf( '\n fcat        (subscripts): %0.3f (ms)', c2 * 1e3 );

%
%  direct assignment
%

tic;
new_cat = c(indices, :);
c1 = toc;

tic;
new_f = f(indices);
c2 = toc;

fprintf( '\n categorical (direct): %0.3f (ms)', c1 * 1e3 );
fprintf( '\n fcat        (direct): %0.3f (ms)', c2 * 1e3 );


%
% looped assignment
%

tic;
for i = 1:numel(indices)
  new_cat(i, :) = c(indices(i), :);
end
c1 = toc;

tic;
for i = 1:numel(indices)
  new_f(i) = f(indices(i));
end
c2 = toc;

fprintf( '\n categorical (loop): %0.3f (ms)', c1 * 1e3 );
fprintf( '\n fcat        (loop): %0.3f (ms)', c2 * 1e3 );

end