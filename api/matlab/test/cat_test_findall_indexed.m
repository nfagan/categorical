function cat_test_findall_indexed()

f = fcat.example();
cats = getcats( f );
N = numel( cats );

iters = 10;

for i = 1:iters
  
  some_cats = cats(randperm(N, randi(N, 1)));
  
  inds = sort( randperm(length(f), randi(length(f), 1)) );
  
  I2 = findall( f, some_cats, inds );
  
  for j = 1:numel(I2)
    
    copied1 = f(I2{j});
    copied2 = f(intersect(inds, I2{j}));
    
    assert( copied1 == copied2, 'Combinations of subsets were not equal.' );    
  end
end

end