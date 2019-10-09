function cat_test_join()

f1 = fcat.create( 'a', 'b' );
f2 = fcat.create( 'a', 'e', 'b', 'c' );

f3 = join( copy(f1), f2 );

contents_msg = 'Joining contents overwrote original contents.';
no_contents_msg = 'Joining contents did not add new category.';

assert( ~haslab(f3, 'e'), contents_msg );
assert( haslab(f3, 'c') && hascat(f3, 'b'), no_contents_msg );

f1 = fcat.create( 'a', 'b', 'c', 'd' );
f2 = fcat.create( 'a', 'd', 'c', 'b', 'e', 'f' );

f3 = join( copy(f1), f2 );

assert( isequal(combs(f3, {'a', 'c'}), combs(f1, {'a', 'c'})), contents_msg );
assert( haslab(f3, 'f') && hascat(f3, 'e'), no_contents_msg );

%
%   joiningwith collapsed expression in incorrect categories of B should 
%   be ok as long as the category already exists in A.
%

f = fcat.create( 'a', 'b', 'c', 'd', 'e', '<e>' );
f2 = fcat.create( 'a', '<b>', 'c', '<e>' );

f3 = join( copy(f), f2 );

f = fcat.create( 'a', '<b>', 'c', '<d>' );
f2 = fcat.create( 'a', 'b', 'd', 'd' );

cat_test_assert_fail( @() join(copy(f), f2) ...
  , 'Allowed placing collapsed expression in incorrect category.' );

end