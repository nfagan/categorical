function results = cat_benchmark_generate_randomized(func, varargin)

base_params = cat_benchmark_config( varargin{:} );

sizes = [ 1e4, 1e6 ];
densities = [ 0.5, 0.001 ];
density_labels = { 'dense', 'sparse' };
randomized_combs = combvec( 1:numel(sizes), 1:numel(densities) );

num_cats = 10;
results = cell( size(randomized_combs, 2), 1 );

for i = 1:size(randomized_combs, 2)
  comb = randomized_combs(:, i);
  
  num_rows = sizes(comb(1));
  label_density = densities(comb(2));
  
  f = fcat.random( 'rows', num_rows, 'numlabel', label_density, 'numcat', num_cats );
  [c, cats] = categorical( f );
  
  tags = { density_labels{comb(2)}, sprintf('%d rows', num_rows) };
  params = base_params;
  params.tags = [ base_params.tags, tags ];
  
  results{i} = func( f, c, cats, params );
end

results = vertcat( results{:} );

end