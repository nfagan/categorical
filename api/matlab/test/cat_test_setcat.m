function cat_test_setcat()

test_indexed();
test_collapsed_expressions();
test_set_from_empty_error_assignment();

end

function test_indexed()

x = fcat.with( {'hi', 'hello'} );

%   using 0 as index should be invalid.

try
  setcat( x, 'hi', 'hello', 0 );
  error( 'failed' );
catch err
  if ( strcmp(err.message, 'failed') )
    error( 'Failed to catch invalid index.' );
  end
end

end

function test_set_from_empty_error_assignment()

f1 = none( fcat.example );
cat_test_assert_fail( @() setcat(f1, 'dose', makecollapsed(f, 'day')) ...
  , 'Setting wrong collapsed expression succeeded with empty object.' );

assert( isequal(size(f1), [0, ncats(f1)]), 'Failed setcat assignment modified size.' );

f2 = none( fcat.example );
assert( haslab(f2, 'ugit'), 'Expected ugit label present.' );
assert( strcmp(whichcat(f2, 'ugit'), 'image'), 'Expected ugit label in image category.' );

cat_test_assert_fail( @() setcat(f2, 'dose', 'ugit') ...
  , 'Setting label to wrong category succeeded with empty object.' );

assert( isequal(size(f2), [0, ncats(f2)]), 'Failed setcat assignment modified size.' );

end

function test_collapsed_expressions()

f = fcat.example();

cat_test_assert_fail( @() setcat(f, 'dose', makecollapsed(f, 'day')) ...
  , 'Setting wrong collapsed expression succeeded.' );

end