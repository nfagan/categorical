function cat_profile_setcat()

f = fcat.example();
cats = getcats( f );

iters = 1e3;

cs = zeros( iters, 2 );

% max_n = length( f );
max_n = 1e3;

for i = 1:iters
  
  from_ind = randperm( length(f), max_n );
  to_ind = randperm( max_n, numel(from_ind) );
  
  categ = cats{ randi(numel(cats)) };
  labs = partcat( f, categ, from_ind );
  
  tic;
  setcat( f, categ, labs, to_ind );
  cs(i, 1) = toc();
  
  tic;
  f(to_ind, categ) = labs;
  cs(i, 2) = toc();  
end

c1 = sum( cs(:, 1) );
c2 = sum( cs(:, 2) );

fprintf( '\n fcat: (setcat) %0.3f (ms) [%d]', c1 * 1e3, iters );
fprintf( '\n fcat:   (subs) %0.3f (ms) [%d]', c2 * 1e3, iters );
fprintf( '\n' );


end