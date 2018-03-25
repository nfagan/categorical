function cat_test_append_resize()

x = fcat();
x.requirecat( {'hi', 'hello'} );
x.setcat( 'hello', 'sup', 100 );
x.resize( 101 );
ind = find( x, '<hello>' );
assert( numel(ind) == 100 && ind(end) == 101 );
assert( isequal(find(x, '<hi>')', 1:101) );

x.resize( 1 );
x.append( x );

assert( isequal(find(x, '<hi>')', 1:2) );

x.resize( 1 );
x.resize( 0 );
x.resize( 1 );

y = fcat();
y.requirecat( getcats(x) );

new_sz = 2;

y.resize( new_sz );

assert( isequal(find(y, '<hi>')', 1:new_sz), 'Indices before append weren''t equal.' );
assert( isequal(find(y, '<hello>')', 1:new_sz), 'Indices before append weren''t equal.' );

append( y, x );

labs = getlabs( y );
for i = 1:numel(labs)
  ind = find( y, labs{i} );
  assert( isequal(ind', 1:new_sz+1), 'Indices after append weren''t equal.' );
end

C = combs( y );

end