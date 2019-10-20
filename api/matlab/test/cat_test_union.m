function cat_test_union()

f1 = fcat.example();
f2 = fcat.example();

% same progenitor
test_full_union( f1, f1 );
% diff progenitor
test_full_union( f1, f2 );
% bidirectional
test_full_union( f2, f1 );

test_subset_rows_all_categories( f1, f1 );
test_subset_rows_all_categories( f1, f2 );
test_subset_rows_all_categories( f2, f1 );

test_one_empty( f1, f1 );
test_one_empty( f1, f2 );
test_one_empty( f2, f1 );

end

function test_one_empty(f1, f2)

a = fcat.union( f1, f2, [], 1:rows(f1) );
b = fcat.union( f2, f1, 1:rows(f2), [] );

assert( a == b, 'Ordering effects on empty subset.' );
assert( isequal(sortrows(categorical(a)), unique(categorical(f1), 'rows')) ...
  , 'Incorrect union with one empty subset.' );

end

function test_subset_rows_all_categories(f1, f2)

iters = 1e2;
rf1 = rows( f1 );
rf2 = rows( f2 );

for i = 1:iters
  ind_a = randperm( rf1, randi(rf1) );
  ind_b = randperm( rf2, randi(rf2) );
  
  u1 = fcat.union( f1, f2, ind_a, ind_b );
  cu1 = union( categorical(f1, getcats(f1), ind_a) ...
    , categorical(f2, getcats(f2), ind_b), 'rows' );
  
  assert( isequal(sortrows(categorical(u1)), cu1), 'Subset row union was not equivalent.' );
end

end

function test_full_union(f1, f2)

u1 = fcat.union( f1, f2 );

cf1 = categorical( f1 );
cf2 = categorical( f2 );

cu1 = union( cf1, cf2, 'rows' );

assert( isequal(cu1, sortrows(categorical(u1))) ...
  , 'Full union was incorrect.' );

end