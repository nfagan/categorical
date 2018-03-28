function cat_profile_assign_random()

x = cat_test_get_mat_categorical();

iters = 1e2;

c = x.c;
f = fcat.from( c );

alph = [ 'a':'z', 'A':'Z' ];

labels = arrayfun( @(x) alph(randi(numel(alph), 1, 20)), 1:iters, 'un', false );
inds = arrayfun( @(x) randperm(size(f, 1), randi(size(f, 1), 1, 1)), 1:iters, 'un', false );
cols = arrayfun( @(x) randi(size(f, 2), 1, 1), 1:iters, 'un', false );
cats = getcats( f );

tic;
for i = 1:iters
  lab = labels{i};
  ind = inds{i};
  col = cols{i};
  
  c(ind, col) = lab;
end
c1 = toc;

tic;
for i = 1:iters
  lab = labels{i};
  ind = inds{i};
  col = cols{i};
  
%   setcat( f, cats{col}, lab, ind );
  
  f(ind, col) = lab;
end
c2 = toc;

fprintf( '\n categorical (subscripts): %0.3f (ms)', c1 * 1e3 );
fprintf( '\n fcat        (subscripts): %0.3f (ms)', c2 * 1e3 );

end