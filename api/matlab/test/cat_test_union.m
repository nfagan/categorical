function cat_test_union()

f1 = fcat.example();
f2 = fcat.example();

test_different_category_sets();
test_different_category_order();

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

function test_different_category_sets()

f1 = fcat.example();
f2 = fcat.example( 'large2' );

shared_labs = intersect( getlabs(f1), getlabs(f2) );
rmcat( f2, whichcat(f2, shared_labs) );
shared_cats = intersect( getcats(f1), getcats(f2) );
rmcat( f2, shared_cats );

iters = 20;
max_cats = min( ncats(f1), ncats(f2) );

cats1 = getcats( f1 );
cats2 = getcats( f2 );

for i = 1:iters
  num_rename = randi( max_cats );
  cats1p = cats1(randperm(numel(cats1), num_rename));
  cats2p = cats2(randperm(numel(cats2), num_rename));
  
  f2p = copy( f2 );
  
  if ( ncats(f2) > ncats(f1) )
    for j = 1:num_rename
      renamecat( f2p, cats2p{j}, cats1p{j} );
    end
    use_cats = cats1p;
  else
    for j = 1:num_rename
      renamecat( f1p, cats1p{j}, cats2p{j} );
    end
    use_cats = cats2p;
  end
  
  a = fcat.union( f1, f2p, use_cats );
  b = fcat.union( f2p, f1, use_cats );
  
  test_a = categorical( f1, use_cats );
  test_b = categorical( f2p, use_cats );
  u_test = union( test_a, test_b, 'rows' );
  u_test = sortrows( reordercats(u_test) );
  
  c_a = sortrows( reordercats(categorical(a, use_cats)) );
  c_b = sortrows( reordercats(categorical(b, use_cats)) );
  
  assert( isequal(u_test, c_a), 'Incorrect subset union.' );
  assert( isequal(c_a, c_b), 'Ordering effects on subset union.' );
end

end

function test_different_category_order()

f = fcat.example();
c = getcats( f );

while ( isequal(c, getcats(f)) )
  c = c(randperm(numel(c)));
end

f2 = fcat.with( c, rows(f) );
assign( f2, f, rowmask(f2) );

a = fcat.union( f2, f );
b = fcat.union( f, f2 );

assert( isequal(sortrows(categorical(a)), sortrows(categorical(b))) ...
  , 'Ordering effects with same categories ordered separately.' );

iters = 100;

for i = 1:iters
  use_c = c(randperm(numel(c), randi(numel(c))));
  
  ind_a = randperm( rows(f), randi(rows(f)) );
  ind_b = randperm( rows(f2), randi(rows(f2)) );
  
  a = fcat.union( f, f2, use_c, ind_a, ind_b );
  b = fcat.union( f2, f, use_c, ind_b, ind_a );
  
  c_subset_a = categorical( f, use_c, ind_a );
  c_subset_b = categorical( f, use_c, ind_b );
  c_union = union( c_subset_a, c_subset_b, 'rows' );
  
  c_a = sortrows( categorical(a, use_c) );
  c_b = sortrows( categorical(b, use_c) );

  assert( isequal(c_a, c_b) ...
    , 'Ordering effects with same subsets of categories ordered separately.' );
  
  assert( isequal(c_union, c_a), 'Unions were not equal.' );
end

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