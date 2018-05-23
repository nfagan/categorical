function cat_test_remove()

f = fcat.create( 'a', {'a', 'c'}, 'b', {'b', 'd'} );

f1 = remove( copy(f), 'a' );

assert( haslab(f1, 'a') );

prune( f1 );

assert( ~haslab(f1, 'a'), 'Label was present after being removed.' );
assert( size(f1, 1) == 1, 'Size was not reduced after removing.' );

f2 = remove( copy(f), {'a', 'd'} );

assert( isempty(f2), 'Not all rows were removed.' );

end