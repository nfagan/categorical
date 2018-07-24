function cat_test_sortrows()

f = fcat.example();

iters = 1e3;

max_sz = 100;

for i = 1:iters
  N = randperm( length(f), randi(max_sz) );
  
  z = keep( copy(f), N );
  sorted = sortrows( copy(z) );
  cat = categorical( z );
  
  sorted_cat = sortrows( cat );
  
  assert( isequal(sorted_cat, categorical(sorted)), 'Sorted subsets were not equal.' );
end

end