function cat_test_append_keep()

categ = cat_test_get_mat_categorical();

n_iters = 1e2;

z = requirecat( fcat(), categ.f );

for i = 1:n_iters
  
  x = fcat.from( categ.c, categ.f );
  y = categ.c;
  
  n_choose = randi( numel(x), 1, 1 );
  keep_indices = sort( randperm(numel(x), n_choose) );
  
  y = y(keep_indices, :);
  keep( x, keep_indices );
  
  assert( numel(x) == size(y, 1), 'Sizes didn''t match.' );
  
  x_labs = sort( getlabs(x) );
  y_labs = sort( unique(y) );
  
  assert( isequal(x_labs, y_labs), 'Labels didn''t match.' );  
  
  for j = 1:numel(x_labs)
    ind = find( x, x_labs{j} );
    [r, c] = find( y == x_labs{j} );
    assert( isequal(ind, r), 'Indices didn''t match.' );
  end
  
  delete( x );
  
end


end