function cat_test_append_indexed()

f = fcat.example();

c = categorical( f );

iters = 1e2;

max_inds = 100;

for i = 1:iters
  
  f1 = copy( f );
  
  inds = randperm( length(f1), max_inds );
  
  append( f1, f, inds );
  
  c1 = [ c; c(inds, :) ];
  c2 = categorical( f1 );
  
  assert( isequal(c1, c2), 'Appended subsets with matching sources were not equal.' );
  
end

for i = 1:iters
  
  x = fcat.from( c, getcats(f) );
  y = fcat.from( c, getcats(f) );
  
  assert( ~progenitorsmatch(x, y) );
  
  inds = randperm( length(x), max_inds );
  
  z1 = append( copy(x), y, inds );
  z2 = append( copy(x), y(inds) );
  
  assert( z1 == z2, 'Appended subsets with different sources were not equal.' );
end

for i = 1:iters
  f1 = copy( f );
  
  inds = randperm( length(f1), 1 );
  
  append( f1, f, inds );
  
  c1 = [ c; c(inds, :) ];
  c2 = categorical( f1 );
  
  assert( isequal(c1, c2), 'Appended subsets with matching sources and single row were not equal.' );
end

for i = 1:iters
  
  x = fcat.from( c, getcats(f) );
  y = fcat.from( c, getcats(f) );
  
  assert( ~progenitorsmatch(x, y) );
  
  inds = randperm( length(x), 1 );
  
  z1 = append( copy(x), y, inds );
  z2 = append( copy(x), y(inds) );
  
  assert( z1 == z2, 'Appended subsets with different sources and single row were not equal.' );
end

a = fcat();
b = fcat();

inds = [ 1, 2, 1 ];

append( a, f, inds );
append( b, f(inds) );

assert( a == b, 'Appended subsets were not equal when appending from empty.' ); 

end