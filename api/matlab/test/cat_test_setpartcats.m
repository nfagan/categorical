function cat_test_setpartcats()

f = fcat.example();
c = categorical( f );
cats = getcats( f );

iters = 1e3;
maxn = 100;

for i = 1:iters
  
  to_inds = randperm( length(f), maxn );
  from_inds = randperm( length(f), maxn );
  
  some_cats = cats( randperm(numel(cats), randi(numel(cats))) );
  [~, cat_inds] = ismember( some_cats, cats );
  
  f2 = f';  
  setcats( f2, some_cats, f(from_inds, some_cats), to_inds );
  
  c2 = c;
  c2(to_inds, cat_inds) = c(from_inds, cat_inds);
  
  assert( isequal(categorical(f2), c2), 'Assigned subsets were not equal.' );
end

end