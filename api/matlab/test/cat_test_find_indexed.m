function cat_test_find_indexed()

f = fcat.example();

labs = getlabs( f );
N = numel( labs );

iters = 1e2;

for i = 1:iters
  
  some_labs = get_labs( labs, N );
  other_labs = get_labs( labs, N );
  
  I = find( f, some_labs );
  
  I_intersect = intersect( I, find(f, other_labs) );
  I_indexed = find( f, other_labs, I );
  
  assert( isequal(I_intersect, I_indexed), 'Found subsets were not equal.' );
end


end

function some_labs = get_labs(labs, N)
some_labs = labs( randperm(N, randi(N, 1)) );
end