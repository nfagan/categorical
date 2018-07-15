function cat_test_findnot()

f = fcat.example();
labs = getlabs( f );
maxlabs = 5;
full_ind = reshape( 1:length(f), [], 1 );

iters = 1e3;

for i = 1:iters
  
  label_comb = labs( randperm(numel(labs), maxlabs) );
  
  ind1 = find( f, label_comb );
  not_ind1 = findnot( f, label_comb );
  
  matched_ind = setdiff( full_ind, ind1 );
  
  assert( isequal(matched_ind, not_ind1), 'Not find and setdiff produced different result.' );
  
end

%   findnot with no labels should be 1:length(f)
assert( isequal(full_ind, findnot(f, {})) ...
  , 'findnot with no labels did not return a complete index.' );

end