function cat_test_union()

f1 = fcat.example();
f2 = fcat.example();

% need to test same vs. diff progenitor.

test_indexed( f1, f1 );
test_indexed( f1, f2 );

test_empty_indexed( f1, f1 );
test_empty_indexed( f1, f2 );

test_fullset( f1, f1 );
test_fullset( f1, f2 );

test_subset_cats( f1, f1 );
test_subset_cats( f1, f2 );

end

function test_indexed(f1, f2)

cats = getcats( f1 );
iters = 1e2;

for i = 1:iters
  subset_cats = sample_categories( cats );
  ind_a = randperm( rows(f1), randi(rows(f1)) );
  ind_b = randperm( rows(f2), randi(rows(f2)) );
  
  cpp = fcat.union( f1, f2, subset_cats, ind_a, ind_b );
  cpp_mat = sortrows( categorical(cpp, subset_cats) );
  
  mat = union( categorical(f1, subset_cats, ind_a), categorical(f2, subset_cats, ind_b), 'rows' );
  
  assert( isequal(cpp_mat, mat), 'Indexed subsets were not equal.' );
end

end

function test_empty_indexed( f1, f2 )

f3 = fcat.union( f1, f2, getcats(f1), [], [] );
z = categorical( f3 );

assert( isequal(z, categorical(f1, getcats(f1), [])), 'Empty indexed subset was not equal.' );

end

function test_subset_cats(f1, f2)

cats = getcats( f1 );
iters = 100;

for i = 1:iters
  subset_cats = sample_categories( cats );
  
  cpp = fcat.union( f1, f2, subset_cats );
  cf = categorical( f1, subset_cats );
  mat = union( cf, cf, 'rows' );
  cpp_mat = categorical( cpp, subset_cats );
  
  assert( isequal(sortrows(cpp_mat), mat), 'Union of subsets were not equal.' );
end

end

function test_fullset(f1, f2)

cpp = fcat.union( f1, f2 );

y = categorical( f1 );
mat = union( y, y, 'rows' );

assert( isequal(sortrows(cpp{:}), mat), 'Union of full sets were not equal.' );

end

function cats = sample_categories(cats)

cats = cats(randperm(numel(cats), randi(numel(cats))));

end