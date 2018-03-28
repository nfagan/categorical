function cat_profile_append()

eg = cat_test_get_mat_categorical();
n_iters = 1e4;

cats = eg.f;
categ = eg.c;

tic;
categ2 = categorical();
categ2(1e3, numel(cats)) = '<undefined>';

% categorical
tic();
for i = 1:n_iters
  ind = randperm( size(categ, 1), 1 );
  
  row = categ(ind, :);
  
  categ2(i, :) = row;
end
c1 = toc();

% fcat
tic;
C = requirecat( fcat(), cats );
tmp = requirecat( fcat(), cats );

for i = 1:n_iters
  ind = randperm( size(categ, 1), 1 );
  
  row = cellstr( categ(ind, :) );
  
  setcats( tmp, cats, row );
  
  append( C, tmp );
end
c2 = toc();

% fcat - subsasgn
tic;
C = requirecat( fcat(), cats );
tmp = requirecat( fcat(), cats );
resize( tmp, 1 );

for i = 1:n_iters
  ind = randperm( size(categ, 1), 1 );
  
  row = cellstr( categ(ind, :) );
  tmp(1, :) = row;
  
  append( C, tmp );
end
c3 = toc();

% fcat - assign
C2 = fcat.from( categ, eg.f );
tic;
C = requirecat( fcat(), cats );
tmp = requirecat( fcat(), cats );
resize( tmp, 1 );
resize( C, n_iters );

for i = 1:n_iters
  ind = randperm( size(C2, 1), 1 );
  
  assign( tmp, C2, 1, ind );
  
  assign( C, tmp, i );
end
c4 = toc();


delete( C );
delete( tmp );

fprintf( '\n categorical:   %0.3f (ms) [%d]', c1 * 1e3, n_iters );
fprintf( '\n fcat:          %0.3f (ms) [%d]', c2 * 1e3, n_iters );
fprintf( '\n fcat: (subs)   %0.3f (ms) [%d]', c3 * 1e3, n_iters );
fprintf( '\n fcat: (assign) %0.3f (ms) [%d]', c4 * 1e3, n_iters );

end