function cat_test_replace()

x = cat_test_get_mat_categorical();
conf = fcat.buildconfig();

f = fcat.from( x.c, x.f );

incat1 = incat( f, x.f{1} );
incat2 = incat( f, x.f{2} );

try
  replace( f, incat1{1}, incat2{1} );
  error( 'failed' );
catch err
  if ( strcmp(err.message, 'failed') )
    error( 'Allowed labels to reside in multiple categories.' );
  end
end

try
  assert( ~haslab(f, 'a') );
  replace( f, [incat1(1), incat2(1)], 'a' );
  error( 'failed' )
catch err
  if ( strcmp(err.message, 'failed') )
    error( 'Allowed labels to reside in multiple categories.' );
  end
end

assert( ~haslab(f, 'a') );

replace( f, incat1, 'a' );

assert( haslab(f, 'a'), 'Label was not inserted.' );
assert( count(f, 'a') == size(f, 1), 'Label did not fill category.' );

if ( conf.prune_after_assign )
  assert( ~any(haslab(f, incat1)), 'Original labels existed after replacemenet.' );
else
  assert( all(haslab(f, incat1)), 'Original labels did not exist after replacement.' );
end

f1 = fcat.create( 'a', {'a', 'b'} );
f2 = replace( copy(f1), 'a', 'c' );
f3 = replace( copy(f1), 'a', 'b' );

assert( progenitorsmatch(f1, f3), 'Replacing single label with present label updated progenitors.' );
assert( ~progenitorsmatch(f1, f2), 'Replacing single label with new label did not update progenitors.' );

end