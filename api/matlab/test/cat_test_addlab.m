function cat_test_addlab()

f = fcat();

cat_test_assert_fail( @() addlab(f, 'a', 'b'), 'Adding label to a non-existent category succeeded.' );

try
  addcat( f, {'a', 'c'} );
  addlab( f, 'a', 'b' );
catch err
  error( 'Adding a new label in an existing category failed.' );
end

cat_test_assert_fail( @() addlab(f, 'a', '<c>'), 'Adding collapsed expression of wrong category succeeded.' );

f2 = addcat( fcat(), {'a', 'b'} );

try
  addlab( f2, {'a', 'b'}, {'a', 'b'} );
  
catch err
  error( 'Adding matched labels to matched categories failed.' );
end

end