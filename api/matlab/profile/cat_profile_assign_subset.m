function cat_profile_assign_subset()

x = cat_test_get_mat_categorical();
f = fcat.from( x.c );
repeat( f, 99 );
c = repmat( x.c, 100, 1 );

iters = 1e2;
z = fcat.with( getcats(f) );
resize( z, iters );

tic;
for i = 1:iters
  ind = randi( size(f, 1), 1, 1 );
  assign( z, f, i, ind );
end
c1 = toc;

% tic;
% for i = 1:iters
%   ind = randi( size(f, 1), 1, 1 );
%   assign( z, f(ind), i );
% end
% c2 = toc;

categ = c(1:iters, :);
tic;
for i = 1:iters
  ind = randi( size(c, 1), 1, 1 );
  categ(i, :) = c(ind, :);
end
c3 = toc;

n_assign = 1e6;
ind = randperm( size(c, 1), n_assign );

tic;
resize( z, n_assign );
assign( z, f, 1:n_assign, ind );
c4 = toc;

tic;
z = keep( copy(f), ind );
c5 = toc;

tic;
categ = c(ind, :);
c6 = toc;

fprintf( '\n fcat      (loop, function): %0.3f (ms)', c1 * 1e3 );
% fprintf( '\n fcat    (loop, subscripts): %0.3f (ms)', c2 * 1e3 );
fprintf( '\n categorical         (loop): %0.3f (ms)', c3 * 1e3 );
fprintf( '\n fcat            (function): %0.3f (ms)', c4 * 1e3 );
fprintf( '\n fcat                (copy): %0.3f (ms)', c5 * 1e3 );
fprintf( '\n categorical               : %0.3f (ms)', c6 * 1e3 );

end