function cat_test_rename_cat()

f = fcat.example();

try
  f2 = renamecat( copy(f), 'day', 'days' );
catch err
  error( 'Valid renaming from day to days failed.' );
end

f2 = f';

setcat( f2, 'day', '<days>', 1 );

try
  renamecat( f2, 'day', 'days' );
catch err
  error( 'Valid renaming failed when collapsed expression was present in right cat.' );
end

f2 = f';
setcat( f2, 'day', '<none>' );

clpsed_msg = 'Allowed renaming to category whose collapsed expression exists in a diff category.' ;

try
  renamecat( f2, 'monkey', 'none' );
  error( clpsed_msg );
catch err
  if ( strcmp(err.message, clpsed_msg) )
    throw( err );
  end  
end

f2 = f';

present_msg = 'Allowed renaming to already-present category.' ;

try
  renamecat( f2, 'day', 'monkey' );
  error( present_msg );
catch err
  if ( strcmp(err.message, present_msg) )
    throw( err );
  end
end

end