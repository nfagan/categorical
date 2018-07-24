function cat_test_isuncat()

f = fcat.create( 'a', {'a', 'b'}, 'c', {'c', 'c'} );

assert( ~isuncat(f, 'a'), 'A non-uniform category was considered uniform.' );
assert( isuncat(f, 'c'), 'A uniform category was not considered uniform.' );

assert( isuncat(f, 'a', [1, 1, 1]), ['A category that was uniform over' ...
  , ' a subset of indices was not considered uniform'] );
assert( ~isuncat(f, 'a', []), 'A category was considered uniform without indices.' );
assert( isuncat(f, 'c', 1:length(f)), ['A uniform category was not considered' ...
  , ' uniform over the entire set of its indices.'] );

cat_test_assert_fail( @() isuncat(f, 'c', 0), 'Allowed out of bounds indices.' );
cat_test_assert_fail( @() isuncat(f, 'c', length(f)+1), 'Allowed out of bounds indices.' );
cat_test_assert_fail( @() isuncat(f, 'd'), 'Allowed non-existent category.' );

end