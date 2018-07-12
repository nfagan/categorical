function cat_test_getuncats()

x = fcat.create( 'a', {'b', 'c'}, 'd', 'e' );

y = getcats( x );
assert( isequal(sort(y), {'a'; 'd'}), 'Categories were not equal to begin with.' );

un_cats = getcats( x, 'uniform' );
assert( numel(un_cats) == 1 && strcmp(un_cats{1}, 'd'), 'Uniform categories were not obtained.' );
non_uncats = getcats( x, 'nonuniform' );
assert( numel(non_uncats) == 1 && strcmp(non_uncats{1}, 'a'), 'Non-uniform categories were not obtained.' );

%
%   a category with multiple labels is still uniform if only one label is
%   actually present.
%

setcat( x, 'd', 'f', 1:length(x) );
assert( haslab(x, 'e'), 'Expected label to still be present after setting.' );
assert( isequal(getcats(x, 'uniform'), un_cats) ...
  , 'Category was specified as non-uniform despite having only 1 label.' );

end