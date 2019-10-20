function cat_test_combine()

f1 = fcat.example();
f2 = fcat.example();

test_fully_included_subset();
test_combine_categories();

test_bidirectional();

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

function test_fully_included_subset()

f = fcat.example();
% f1 is a strict subset of f2.
f1 = rmcat( f', setdiff(getcats(f), {'session', 'image'}) );
f2 = rmcat( f', setdiff(getcats(f), {'session', 'day', 'image'}) );

z1 = fcat.combine( f1, f2 );
z2 = fcat.combine( f2, f1 );

assert( isequal(sortrows(categorical(z1)), sortrows(categorical(z2))) ...
  , 'Strict subsets were not equivalent depending on order of inputs.' );

end

function test_combine_categories()

f01 = fcat.example();
f02 = fcat.example();

f1 = rmcat( f01', 'image' );
f2 = rmcat( f02', 'dose' );

y1 = fcat.combine( f1, f2 );
y2 = fcat.combine( f2, f1 );

[sesh_I, sesh_C] = findall( y1, 'session' );
for i = 1:numel(sesh_I)
  u_dose_combs = combs( y1, 'dose', sesh_I{i} );
  orig_dose_combs = combs( f01, 'dose', find(f01, sesh_C(:, i)) );
  assert( isequal(u_dose_combs, orig_dose_combs), 'Doses changed for a given session.' );
end

[sesh_I, sesh_C] = findall( y2, 'session' );
for i = 1:numel(sesh_I)
  u_dose_combs = combs( y2, 'dose', sesh_I{i} );
  orig_dose_combs = combs( f01, 'dose', find(f01, sesh_C(:, i)) );
  assert( isequal(u_dose_combs, orig_dose_combs), 'Doses changed for a given session.' );
end

assert( isequal(sortrows(categorical(y1)), sortrows(categorical(y2))) ...
  , 'Ordering effects.' );

end

function test_bidirectional()

f1 = fcat.example( 'large2' );
f2 = fcat.example( 'large2' );

z = rmcat( f1', {'date', 'looks_by', 'roi', 'event_type'} );
y = rmcat( f2', {'mat_filename', 'task_type', 'channel'} );

c = fcat.combine( z, y );
d = fcat.combine( y, z );

assert( isequal(sortrows(categorical(c)), sortrows(categorical(d))) ...
  , 'ordering effects.' );

end

function test_subsets(a, b, allow_diff_categories)

iters = 1e2;

for i = 1:iters
  fprintf( '\n %d of %d', i, iters );
  
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
  
  z = fcat.combine( ap, bp, ind_a, ind_b );
  ensure_contains_union( z, ap, bp, ind_a, ind_b );
  
  z2 = fcat.combine( bp, ap, ind_b, ind_a );
  ensure_contains_union( z2, bp, ap, ind_b, ind_a );
  
  y = sortrows( categorical(z) );
  y2 = sortrows( categorical(z2) );
  assert( isequal(y, y2), 'Ordering effects.' );
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
  
  cpp = fcat.combine( f1, f2, subset_cats, ind_a, ind_b );
  cpp_mat = sortrows( categorical(cpp, subset_cats) );
  
  mat = union( categorical(f1, subset_cats, ind_a), categorical(f2, subset_cats, ind_b), 'rows' );
  
  assert( isequal(cpp_mat, mat), 'Indexed subsets were not equal.' );
end

end

function test_empty_indexed( f1, f2 )

f3 = fcat.combine( f1, f2, getcats(f1), [], [] );
z = categorical( f3 );

assert( isequal(z, categorical(f1, getcats(f1), [])), 'Empty indexed subset was not equal.' );

end

function test_subset_cats(f1, f2)

cats = getcats( f1 );
iters = 100;

for i = 1:iters
%   subset_cats = sample_categories( cats );
  subset_cats = cats;
  
  cpp = fcat.combine( f1, f2, subset_cats );
  cf = categorical( f1, subset_cats );
  mat = union( cf, cf, 'rows' );
  cpp_mat = categorical( cpp, subset_cats );
  
  assert( isequal(sortrows(cpp_mat), mat), 'Union of subsets were not equal.' );
end

end

function test_fullset(f1, f2)

cpp = fcat.combine( f1, f2 );

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