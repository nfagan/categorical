function cat_test_append()

eg = cat_test_get_mat_categorical();
n_iters = 1e3;

cats = eg.f;
categ = eg.c;

C = requirecat( Categorical(), cats );

categ2 = categorical();
categ2(1e3, numel(cats)) = '<undefined>';

for i = 1:n_iters
  ind = randperm( size(categ, 1), 1 );
  
  row = categ(ind, :);
  
  categ2(i, :) = row;
  
  tmp = requirecat( Categorical(), cats );
  
  for j = 1:numel(cats)
    setcat( tmp, cats{j}, cellstr(row(j)) );
  end
  
  append( C, tmp );
  
  delete( tmp );
end

categ3 = categorical( C );

assert( isequal(size(categ3), size(categ2)), 'Sizes didn''t match.' );
assert( all(all(categ3 == categ2)), 'Values didn''t match.' );

all_labs = getlabs( C );

assert( numel(all_labs) == numel(unique(categ2)), 'Label numbers didn''t match.' );

for i = 1:numel(all_labs)
  
  [r, c] = find( categ2 == all_labs{i} );
  
  assert( isequal(r, find(C, all_labs{i})), 'Indices weren''t equal.' );
end

end