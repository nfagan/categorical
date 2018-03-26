function cat_profile_assign()

x = cat_test_get_mat_categorical();

c = [x.c; x.c; x.c; x.c; x.c; x.c];

f = fcat.from( c, x.f );

n_iters = 1e5;

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
new_f(:) = f(indices);
c2 = toc;

tic;
new_f(:, :) = f(indices, :);
c3 = toc;

tic;
c_ = getcats( f );
setcats( new_f, c_, partcat(f, c_, indices) );
c4 = toc();

fprintf( '\n categorical (subscripts): %0.3f (ms)', c1 * 1e3 );
fprintf( '\n fcat        (subscripts): %0.3f (ms)', c2 * 1e3 );
fprintf( '\n fcat      (cellstr subs): %0.3f (ms)', c3 * 1e3 );
fprintf( '\n fcat      (cellstr subs): %0.3f (ms)', c4 * 1e3 );

%
%  direct assignment
%

tic;
new_cat = c(indices, :);
c1 = toc;

tic;
new_f = f(indices);
c2 = toc;

tic;
new_f = keep( copy(f), indices );
c3 = toc;

fprintf( '\n categorical     (direct): %0.3f (ms)', c1 * 1e3 );
fprintf( '\n fcat   (direct, subsref): %0.3f (ms)', c2 * 1e3 );
fprintf( '\n fcat  (direct, function): %0.3f (ms)', c3 * 1e3 );

end