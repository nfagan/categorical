function cat_test_union()

f1 = fcat.example();
f2 = fcat.example();

% need to test same vs. diff progenitor.
test_subsets( f1, f1, false );
test_subsets( f1, f2, false );

test_subsets( f1, f1, true );
test_subsets( f1, f2, true );

test_indexed( f1, f1 );
test_indexed( f1, f2 );

test_empty_indexed( f1, f1 );
test_empty_indexed( f1, f2 );

test_fullset( f1, f1 );
test_fullset( f1, f2 );

test_subset_cats( f1, f1 );
test_subset_cats( f1, f2 );

end

function test_subsets(a, b, allow_diff_categories)

iters = 1e2;

for i = 1:iters
  cats_a = sample_categories(getcats(a));
  
  if ( allow_diff_categories )
    cats_b = sample_categories(getcats(b));
  else
    cats_b = cats_a;
  end
  
  ap = rmcat( copy(a), cats_a );
  bp = rmcat( copy(b), cats_b );
  
  if ( isempty(ap) )
    ind_a = [];
  else
    ind_a = randperm( rows(ap), randi(rows(ap)) );
  end
  
  if ( isempty(bp) )
    ind_b = [];
  else
    ind_b = randperm( rows(bp), randi(rows(bp)) );
  end
  
  z = fcat.union( ap, bp, ind_a, ind_b );
  ensure_contains_union( z, ap, bp, ind_a, ind_b );
  
  z2 = fcat.union( bp, ap, ind_b, ind_a );
  ensure_contains_union( z2, bp, ap, ind_b, ind_a );
  
  y = sortrows( categorical(z) );
  y2 = sortrows( categorical(z2) );
  
  if ( ~allow_diff_categories )
    assert( isequal(y, y2), 'Ordering effects.' );
  end
end

end

function test_indexed(f1, f2)

cats = getcats( f1 );
iters = 1e2;

for i = 1:iters
%   subset_cats = sample_categories( cats );
  subset_cats = cats;
  
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
%   subset_cats = sample_categories( cats );
  subset_cats = cats;
  
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

function ensure_contains_union(z, a, b, ma, mb)

marked_rows = false( rows(z), 1 );

if ( nargin < 4 )
  ma = rowmask( a );
end
if ( nargin < 5 )
  mb = rowmask( b );
end

a_sub = unique( categorical(a, getcats(a), ma), 'rows' );
b_sub = unique( categorical(b, getcats(b), mb), 'rows' );

for i = 1:rows(a_sub)
  ind = find( z, cellstr(a_sub(i, :)) );
  assert( numel(ind) > 0, 'Missing row entry from a.' );
  marked_rows(ind) = true;
end
for i = 1:rows(b_sub)
  ind = find( z, cellstr(b_sub(i, :)) );
  assert( numel(ind) > 0, 'Missing row entry from b.' );
  marked_rows(ind) = true;
end

assert( all(marked_rows), 'Some rows were not marked.' );

end