function cat_test_whichcat()

f = fcat.example();

cats = getcats( f );

for i = 1:numel(cats)
  labs = incat( f, cats{i} );
  C = whichcat( f, labs );
  
  unq_c = unique( C );
  
  assert( numel(unq_c) == 1 && strcmp(unq_c{1}, cats{i}) ...
    , 'whichcat failed to identify the category of labels in a category.' );
end

%   should be error when non-present label is requested

id = char( java.util.UUID.randomUUID() );

while ( haslab(f, id) )
  id = char( java.util.UUID.randomUUID() );
end

cat_test_assert_fail( @() whichcat(f, id), 'Requesting non-present label failed to trigger error.' );



end