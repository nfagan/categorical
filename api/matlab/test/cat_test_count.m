function cat_test_count()

f = fcat.example;
c = categorical( f );
labs = getlabs( f );

iters = 1e3;

%   non-indexed
for i = 1:iters
  
  lab = labs{randi(numel(labs))};
  
  cs = count( f, lab );
  
  assert( cs == numel(find(f, lab)), 'Count did not match numel(find).' );
  assert( sum(sum(c==lab)) == cs, 'Count did not match sum of categorical.' );  
end

for i = 1:iters
  
  lab = labs{randi(numel(labs))};
  ind = randperm( length(f), randi(length(f)) );
  
  cs = count( f, lab, ind );
  
  assert( cs == numel(find(f, lab, ind)), 'Count did not match numel(find).' );
  assert( sum(sum(c(ind, :)==lab)) == cs, 'Count did not match sum of categorical.' );
end

%   confirm bounds-checking
cat_test_assert_fail( @() count(f, labs{1}, 0), 'Allowed counting of out-of-bounds indices.' );
cat_test_assert_fail( @() count(f, labs{1}, length(f)+1), 'Allowed counting of out-of-bounds indices.' );

end