function cat_test_merge()

x = cat_test_get_mat_categorical();

y = fcat.create( 'a', 'b', 'c', 'd' );
z = fcat.create( 'e', 'f', 'g', 'h' );

y2 = merge( copy(y), z );

assert( all(hascat(y2, {'a', 'c', 'e', 'g'})) ...
  , 'New categories weren''t present after merge.' );

z = fcat.create( 'a', 'd' );

try
  y2 = merge( copy(y), z );
  error( 'failed' );
catch err
  if ( strcmp(err.message, 'failed') )
    error( 'Merge succeeded with labels in different categories.' );
  end
end

y2 = repmat( copy(y), 2 );

setcat( y2, 'a', 'f', 1 );

z = fcat.create( 'a', 'f', 'b', 'e' );

y3 = merge( copy(y2), z );

assert( all(hascat(y3, [getcats(y2), getcats(z)])) ...
  , 'New categories weren''t present after merge.' );

assert( isequal(find(y3, 'f')', 1:size(y3, 1)), 'Assignment failed.' );


f1 = fcat.create( 'a', '<b>', 'c', 'd' );
f2 = fcat.create( 'b', 'c', 'c', 'd' );

try
  f3 = merge( copy(f1), f2 );
  error( 'failed' );
catch err
  if ( strcmp(err.message, 'failed') )
    error( 'Merge succeeded with collapsed expression in wrong category.' );
  end
end

end