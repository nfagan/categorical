function cat_test_setpartcat()

f = fcat.example();
cats = getcats( f );
ncats = numel( cats );

c = categorical( f );

iters = 1e3;

max_inds_mult = 100;

%   test multiple
for i = 1:iters
  do_test( max_inds_mult, false );
end

for i = 1:iters
  do_test( max_inds_mult, true );
end

%   test assign from empty
x = fcat.with( {'a', 'b'} );
setcat( x, 'a', 'a', [2, 20, 3] );

assert( length(x) == 20 ...
  , 'Assignment from empty did not match largest index.' );
assert( strcmp(x(end, 'a'), 'a') ...
  , 'Assignment from empty did not place "a" at last index.' );
assert( all(strcmp(x(2:3, 'a'), {'a'; 'a'})) ...
  , 'Assignment from empty did not place "a" correctly.' );

%   test assign with invalid index
x = fcat.with( {'a', 'b'}, 100 );

cat_test_assert_fail( @() setcat(x, 'a', 'a', 1:101) ...
  , 'Allowed assignment to out-of-bounds data.' );


  function do_test(max_inds, is_scalar)
    categ = cats{ randi(ncats) };
    cat_ind = strcmp( cats, categ );
    all_labs = cellstr( c(:, cat_ind) );
    inds = randperm( length(f), max_inds );
    
    if ( is_scalar )
      assign_labs = all_labs{randi(numel(all_labs))};
    else
      assign_labs = all_labs(inds);
    end
    
    z = copy( f );
    setcat( z, categ, assign_labs, inds );
    
    c2 = c;
    c2(inds, cat_ind) = assign_labs;
    
    assert( isequal(categorical(z), c2), 'Converted subsets were not equal.' );
  end

end