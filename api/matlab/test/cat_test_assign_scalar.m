function cat_test_assign_scalar()

f = fcat.example();
c = categorical( f );

iters = 1e2;

for i = 1:iters
  
  from_ind = randi( length(f), 1 );
  to_inds = randperm( length(f), randi(length(f), 1) );
  from_inds = repmat( from_ind, numel(to_inds), 1 );
  
  a = c;
  a(to_inds, :) = c(from_inds, :);
  
  f2 = categorical( assign(copy(f), f, to_inds, from_ind) );
  
  assert( all(all(a == f2)), 'Assigned rows were not equal.' );
end

%   check that non-progenitor matching assignment also works.

x = fcat.create( 'a', {'b', 'c', 'e'} );
y = fcat.create( 'a', {'b', 'c', 'd'} );

assert( ~progenitorsmatch(x, y) );

z = assign( copy(x), y, 1:2, 3 );

assert( prune(z) == fcat.create('a', {'d', 'd', 'e'}) ...
  , 'Non-progenitor matching subsets were not equal.' );


end