function cat_test_partcat()

x = cat_test_get_mat_categorical();

y = fcat.from( x.c, x.f );

cats = getcats( y );

for i = 1:numel(cats)
  assert( isequal(fullcat(y, cats{i}), partcat(y, cats{i}, 1:numel(y))) ...
    , 'Categories were not equal.' );
end

try
  z = partcat( y, cats{1}, numel(y)+1 );
  error( 'failed' );
catch err
  if ( strcmp(err.message, 'failed') )
    error( 'Failed to error with out of bounds index.' );
  end
end

n_iters = 1e2;

for i = n_iters
  
  cat = cats{ randperm(numel(cats), 1) };
  ind = randperm( numel(y), randi(numel(y), 1, 1) );
  
  z1 = partcat( y, cat, ind );
  
  col = strcmp( x.f, cat );
  
  z2 = x.c(ind, col);
  
  assert( isequal(z1, cellstr(z2)), 'Partial categories were not equal.' );
end

end