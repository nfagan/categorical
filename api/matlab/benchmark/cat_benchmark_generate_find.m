function results = cat_benchmark_generate_find()

kinds = { 'small', 'large', 'large2' };

results = [];

for i = 1:numel(kinds)
  f = fcat.example( kinds{i} );
  [c, cats] = categorical( f );

  params = cat_benchmark_config( 'iter', 100, 'tag', kinds{i} );
  
  tmp_results = cat_benchmark_find( f, c, cats, params );
  results = [ results; tmp_results ];
end

end