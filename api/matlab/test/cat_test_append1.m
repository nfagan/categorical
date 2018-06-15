function cat_test_append1()

f = fcat.example();

z = append1( f', f, [] );

assert( z == f, 'Append1 with no indices changed values.' );

iters = 1e2;
max_n = min( 1e3, length(f) );

% test indexed

for i = 1:iters
  
  inds = randperm( length(f), max_n );
  
  f2 = append( f', one(f(inds)) );
  f3 = append1( f', f, inds );
  
  assert( f2 == f3, 'Indexed subsets were not equivalent.' );
  
end

for i = 1:iters
  f2 = append( f', one(f') );
  f3 = append1( f', f );
  
  assert( f2 == f3, 'Non-indexed subsets were not equivalent.' );
end

for i = 1:iters
  inds = randperm( length(f), 1 );
  
  f2 = append( f', one(f(inds)) );
  f3 = append1( f', f, inds );
  
  assert( f2 == f3, 'Indexed subsets were not equivalent with single row.' );
end

a = fcat();
b = fcat();

for i = 1:iters
  
  ind = randi( length(f) );
  
  append1( a, one(f(ind)) );
  append1( b, f, ind );
end

assert( prune(a) == prune(b), 'Pruned single-row subsets assigned from empty were not equal.' );

a = fcat();
b = fcat();

for i = 1:iters
  
  ind = randi( length(f), 100, 1 );
  
  append1( a, one(f(ind)) );
  append1( b, f, ind );
end

assert( prune(a) == prune(b), 'Pruned multi-row subsets assigned from empty were not equal.' );

end