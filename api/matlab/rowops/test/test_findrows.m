function test_findrows()

f = fcat.example();
c = categorical( f );
s = string( c );
t = array2table( c, 'variablenames', categories(f) );
d = double( c );
cats = categories( c );
assert( isequal(categorical(cats(d)), c) );

for l = 1:numel(cats)
  fprintf( '\n %d of %d', l, numel(cats) );
  
  for i = 1:1e2
    sub = randperm( numel(cats), l );
    lsub = ismember( 1:numel(cats), sub );
    
    ind1 = find( f, cats(lsub) );
    ind2 = findrows( c, cats(lsub) );
    ind3 = findrows( t, cats(lsub) );
    ind4 = findrows( s, cats(lsub) );
    assert( isequal(ind1, ind2, ind3, ind4) );
  end
end

end