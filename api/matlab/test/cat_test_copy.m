function cat_test_copy()

x = cat_test_get_mat_categorical();

c1 = fcat.from( x.c );

c2 = copy( c1 );

labs1 = getlabs( c1 );
labs2 = getlabs( c2 );

assert( isequal(sort(labs1), sort(labs2)), 'Labels weren''t equal.' );

for i = 1:numel(labs1)
  assert( isequal(find(c1, labs1{i}), find(c2, labs1{i})), 'Indices weren''t equal.' );
end

orig_size = numel( c2 );

keep( c1, sort(randperm(numel(c1), 100)) );

assert( numel(c2) == orig_size, 'Size changed.' );

assert( isequal(sort(getlabs(c2)), sort(labs2)), 'Labels changed.' );

delete( c1 );
delete( c2 );

end