function cat_test_find()

cat_test_assert_depends_present( mfilename );

f = fcat.example();
s = SparseLabels.from_fcat( f );

labs = getlabs( f );
N = numel( labs );

iters = 1e2;

for i = 1:iters
  
  some_labs = labs(randperm(N, randi(N, 1)) );
  i1 = find( f, some_labs );
  i2 = uint64( find(full(where(s, some_labs))) );
  
  assert( isequal(i1, i2), 'Found subsets were not equal.' );
end


end