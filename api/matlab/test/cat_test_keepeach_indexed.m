function cat_test_keepeach_indexed()

f = fcat.example();

iters = 1e2;

cats = getcats( f );
NC = numel( cats );

labs = getlabs( f );
NL = numel( labs );

for i = 1:iters
  
  some_cats = cats( randperm(NC, randi(NC, 1)) );
  some_labs = labs( randperm(NL, randi(NL, 1)) );
  
  I1 = find( f, some_labs );
  f1 = keepeach( f(I1), some_cats );
  
  f2 = keepeach( copy(f), some_cats, I1 );
  
  assert( f1 == f2, 'Subsets were not equal.' ); 
  
end

end