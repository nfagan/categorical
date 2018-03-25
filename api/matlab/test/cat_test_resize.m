function cat_test_resize()

x = cat_test_get_mat_categorical();
cats = x.c;

c1 = fcat.from( cats );
c2 = fcat.from( cats );

keep( c1, 1 );
keep( c2, 1 );

resize( c1, 10 );
resize( c2, 10 );

collapsed_labs = cellfun( @(x) sprintf('<%s>', x), getcats(c1), 'un', false );
for i = 1:numel(collapsed_labs)
  assert( isequal(find(c1, collapsed_labs{i}), (2:10)'), 'Indices weren''t equal at first.' );
end

append( c1, c2 );

for i = 1:numel(collapsed_labs)
  assert( isequal(find(c1, collapsed_labs{i}), ([2:10, 12:20])'), 'Indices weren''t equal.' );
end

delete( c1 );
delete( c2 );

end