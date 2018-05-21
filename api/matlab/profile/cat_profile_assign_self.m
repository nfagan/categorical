function cat_profile_assign_self()

x = cat_test_get_mat_categorical();
c = repmat( x.c, 10, 1 );
f = fcat.from( c );

z = copy( f );
% z(1, 1) = 'hi';

c_copy = c;

iters = 1e3;

tic;
for i = 1:iters
  ind = randi( size(f, 1), 1, 1 );
  assign( z, f, ind, ind );
end
c1 = toc;

tic;
for i = 1:iters
  ind = randi( size(c, 1), 1, 1 );
  c_copy(ind, :) = c(ind, :);
end
c2 = toc;

inds = randi( size(c, 1), iters, 1 );
tic;
z = f(inds);
c3 = toc();

tic;
c_copy = c(inds, :);
c4 = toc();

fprintf( '\n fcat        (loop): %0.3f (ms)', c1 * 1e3 );
fprintf( '\n categorical (loop): %0.3f (ms)', c2 * 1e3 );
fprintf( '\n fcat        (subs): %0.3f (ms)', c3 * 1e3 );
fprintf( '\n categorical (subs): %0.3f (ms)', c4 * 1e3 );
fprintf( '\n' );


end