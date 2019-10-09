function cat_test_find_present_labels_empty_object()

f = fcat.example();
keep( f, [] );

labels = { 'face', 'image' };
assert( all(haslab(f, labels)) );
assert( isempty(f) );

find_funcs = { @find, @findnot, @findor, @findnone };

reg_msg = 'Present labels returned a non empty index.';
index_msg = 'Present labels returned a non empty index with indices.';

for i = 1:numel(find_funcs)
  assert( isempty(find_funcs{i}(f, labels)), reg_msg );
  assert( isempty(find_funcs{i}(f, labels, [])), index_msg );
  
  assert( isempty(find_funcs{i}(f, getlabs(f))), reg_msg );
  assert( isempty(find_funcs{i}(f, getlabs(f), [])), index_msg );
  
  cat_test_assert_fail( @() find_funcs{i}(f, labels, 1), 'Present labels did not throw on out of bounds index.' );
end

end