function cat_test_keep()

categ = cat_test_get_mat_categorical();
conf = cat_buildconfig();
use_progenitor_ids = conf.use_progenitor_ids;

n_iters = 1e2;
x1 = fcat.from( categ.c, categ.f );

for i = 1:n_iters
  x = copy( x1 );
  
  y = categ.c;
  
  n_choose = randi( size(x, 1), 1, 1 );
  keep_indices = sort( randperm(size(x, 1), n_choose) );
  
  y = y(keep_indices, :);
  keep( x, keep_indices );
  
  assert( size(x, 1) == size(y, 1), 'Sizes didn''t match.' );
  
  x_labs = sort( getlabs(x) );
  
  if ( ~use_progenitor_ids )
    y_labs = sort( unique(y) );
  else
    y_labs = sort( categories(y) );
  end
  
  assert( isequal(x_labs, y_labs), 'Labels didn''t match.' );  
  
  for j = 1:numel(x_labs)
    ind = find( x, x_labs{j} );
    [r, c] = find( y == x_labs{j} );
    assert( isequal(ind, r), 'Indices didn''t match.' );
  end
  
  delete( x );
  
end

end