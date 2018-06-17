function cat_test_findor()

x = fcat.example;
c = categorical( x );
labs = getlabs( x );
cats = getcats( x );
nlabs = numel( labs );
ncats = numel( cats );
maxlabs = 10;

iters = 1e3;

I2 = trueat( x, [] );

for i = 1:iters
  
  some_labs = labs( randperm(nlabs, maxlabs) );
  
  I1 = findor( x, some_labs );
  
  for j = 1:numel(some_labs)
    I2 = I2 | any( c == some_labs{j}, 2 );
  end
  
  assert( isequal(double(I1), find(I2)), 'Indices of random labels were not equal.' );
  
  I2(:) = false;
end

for i = 1:iters
  categ = cats{ randi(ncats) };
  clabs = incat( x, categ );
  
  I1 = findor( x, clabs );
  I2 = find( x, clabs );
  
  assert( isequal(I1, I2), ['Indices of labels in one category were not' ...
    , ' equal between find and findor.'] );
end

end