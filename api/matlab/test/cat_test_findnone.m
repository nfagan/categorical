function cat_test_findnone()

f = fcat.example();
labs = getlabs( f );
maxlabs = 5;
full_ind = reshape( 1:length(f), [], 1 );

iters = 1e3;

for i = 1:iters
  
  label_comb = labs( randperm(numel(labs), maxlabs) );
  
  ind1 = findor( f, label_comb );
  not_ind1 = findnone( f, label_comb );
  
  matched_ind = setdiff( full_ind, ind1 );
  
  assert( isequal(matched_ind, not_ind1), 'Not findor and setdiff produced different result.' );
  
end

%   findnone with no labels should be 1:length(f)
assert( isequal(full_ind, findnone(f, {})) ...
  , 'findnone with no labels did not return a complete index.' );

end