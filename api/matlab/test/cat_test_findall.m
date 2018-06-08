function cat_test_findall()

f = fcat.example();
c = categorical( f );
cats = getcats( f );
N = numel( cats );

iters = 1e2;

for i = 1:iters
  
  some_cats = cats(randperm(N, randi(N, 1)));
  [~, cat_inds] = ismember( some_cats, cats );
  
  I1 = cellfun( @double, findall(f, some_cats), 'un', false );
  I2 = cat_findall_categorical( c(:, sort(cat_inds)) );
  
  %   in order to match subsets, we need to sort by the combination of the
  %   number of indices and the minimum index. indices returned by
  %   findall() are not with respect to the sorted unique rows of `f`, but
  %   instead depend on the order of elements in `f`.
  
  ns1 = cellfun( @numel, I1 );
  ns2 = cellfun( @numel, I2 );
  
  mins1 = cellfun( @min, I1 );
  mins2 = cellfun( @min, I2 );
  
  tot1 = [ ns1, mins1 ];
  tot2 = [ ns2, mins2 ];
  
  [~, sort1] = sortrows( tot1 );
  [~, sort2] = sortrows( tot2 );  
  
  assert( isequal(I1(sort1), I2(sort2)), 'Category index subsets were not equal.' );
  
end

end