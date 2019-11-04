function results = cat_benchmark_generate(func, varargin)

base_params = cat_benchmark_config( varargin{:} );

kinds = { 'small', 'large', 'large2' };
results = cell( numel(kinds), 1 );

for i = 1:numel(kinds)
  f = fcat.example( kinds{i} );
  [c, cats] = categorical( f );

  params = base_params;
  params.tags = [ base_params.tags, kinds(i) ];
  
  results{i} = func( f, c, cats, params );
end

results = vertcat( results{:} );

end