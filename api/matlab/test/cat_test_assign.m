function cat_test_assign()

x = cat_test_get_mat_categorical();

c1 = fcat.from( x.c );
c2 = fcat.from( x.c );

c3 = assign( copy(c1), c2(1:10), 1:10 );

assert( c1 == c3, 'Subset of contents weren''t equal after assignment.' );

c3 = assign( copy(c1), c2(2:11), 1:10 );

assert( c1 ~= c3, 'Subset of contents were equal after assignment.' );

all_cats = getcats( c1 );

c3 = rmcat( copy(c1), all_cats{1} );

try
  assign( c3, c2(1:10), 1:10 );
  error( 'failed' );
catch err
  if ( strcmp(err.message, 'failed') )
    error( 'Was able to assign objects with different categories.' );
  end
end

try
  assign( c1, c2(1:10), 1:11 );
  error( 'failed' );
catch err
  if ( strcmp(err.message, 'failed') )
    error( 'Was able to assign objects with bad index.' );
  end
end

try
  assign( c1, c2(1), numel(c1)+1 );
catch err
  if ( strcmp(err.message, 'failed') )
    error( 'Was able to assign objects with out of bounds index.' );
  end
end

end