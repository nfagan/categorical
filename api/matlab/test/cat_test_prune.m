function cat_test_prune()

conf = cat_buildconfig();

built_with_prune_after_assign = conf.prune_after_assign;

x = fcat.with( {'one', 'two'} );
y = fcat.with( getcats(x) );

x.resize( 3 );
y.resize( 3 );

setcat( x, 'one', {'hi', 'hello'}, 1:2 );
setcat( x, 'two', {'sup', 'sup'}, 1:2 );
setcat( x, 'two', {'no', 'no'}, 1:2 );

setcat( y, 'one', {'sup', 'sup'}, 1:2 );

if ( built_with_prune_after_assign )
  assert( ~haslab(x, 'sup') );
else
  %
  % 'sup' should be present, but have a count of 0
  %
  assert( haslab(x, 'sup'), 'Label wasn''t present.' );
  assert( count(x, 'sup') == 0 );
end

if ( built_with_prune_after_assign )
  %
  % since 'sup' has been pruned from 'two', append operation should work
  %
  append( x, y );
else
  try
    append( x, y );
    error( 'failed' );
  catch err
    if ( strcmp(err.message, 'failed') )
      error( 'Append succeeded.' );
    end
  end
  
  %   now prune x, to remove 'sup';
  prune( x );
  
  assert( ~haslab(x, 'sup') );
  
  append( x, y );
end

end