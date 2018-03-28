function cat_test_setcat()

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