function cat_test_union()

test_indexed();
test_empty_indexed();
test_fullset()
test_subset_cats()

end

function test_indexed()

f = fcat.example();
cats = getcats( f );
iters = 1e2;

for i = 1:iters
  subset_cats = sample_categories( cats );
  ind_a = randperm( rows(f), randi(rows(f)) );
  ind_b = randperm( rows(f), randi(rows(f)) );
  
  cpp = fcat.union( f, f, subset_cats, ind_a, ind_b );
  cpp_mat = sortrows( categorical(cpp, subset_cats) );
  
  mat = union( categorical(f, subset_cats, ind_a), categorical(f, subset_cats, ind_b), 'rows' );
  
  assert( isequal(cpp_mat, mat), 'Indexed subsets were not equal.' );
end

end

function test_empty_indexed()

f = fcat.example();
f2 = fcat.union( f, f, getcats(f), [], [] );
z = categorical( f2 );

assert( isequal(z, categorical(f, getcats(f), [])), 'Empty indexed subset was not equal.' );

end

function test_subset_cats()

f = fcat.example();
cats = getcats( f );
iters = 100;

for i = 1:iters
  subset_cats = sample_categories( cats );
  
  cpp = fcat.union( f, f, subset_cats );
  cf = categorical( f, subset_cats );
  mat = union( cf, cf, 'rows' );
  cpp_mat = categorical( cpp, subset_cats );
  
  assert( isequal(sortrows(cpp_mat), mat), 'Union of subsets were not equal.' );
end

end

function test_fullset()

f = fcat.example();

cpp = fcat.union( f, f );

y = categorical( f );
mat = union( y, y, 'rows' );

assert( isequal(sortrows(cpp{:}), mat), 'Union of full sets were not equal.' );

end

function cats = sample_categories(cats)

cats = cats(randperm(numel(cats), randi(numel(cats))));

end