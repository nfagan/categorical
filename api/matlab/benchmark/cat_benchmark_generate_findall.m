function results = cat_benchmark_generate_findall()

kinds = { 'small', 'large', 'large2' };

results = cell( numel(kinds), 1 );

for i = 1:numel(kinds)
  f = fcat.example( kinds{i} );
  [c, cats] = categorical( f );

  params = cat_benchmark_config( 'iter', 1e3, 'tag', kinds{i} );
  
  results{i} = cat_benchmark_findall( f, c, cats, params );
end

results = vertcat( results{:} );

end