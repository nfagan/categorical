function cat_test_findnot_indexed()

f = fcat.example();
labs = getlabs( f );
maxlabs = 5;

iters = 1e3;

for i = 1:iters
  
  label_comb = labs( randperm(numel(labs), maxlabs) );
  
  mask = sort( randperm(length(f), randi(length(f), 1)) );
  
  ind1 = find( f, label_comb );
  not_ind1 = findnot( f, label_comb, mask );
  
  matched_ind = setdiff( mask, ind1 );
  
  assert( isequal(matched_ind(:), not_ind1), 'Not find and setdiff produced different result.' );
  
end

%   ensure out of bounds indices fail
cat_test_assert_fail( @() findnot(f, label_comb, 0), 'Allowed 0 as index.' );
cat_test_assert_fail( @() findnot(f, label_comb, length(f)+1), 'Allowed out of bounds index.' );

%   findnot with indices + no labels should just return the index
for i = 1:iters
  mask = sort( randperm(length(f), randi(length(f), 1)) );
  
  ind = findnot( f, {}, mask );
  
  assert( isequal(ind, mask(:)), 'findnot with no labels did not return the mask.' );
end

end