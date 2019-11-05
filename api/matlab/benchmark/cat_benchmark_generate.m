function results = cat_benchmark_generate(func, varargin)

results = {};

results{end+1} = cat_benchmark_generate_examples( func, varargin{:} );
results{end+1} = cat_benchmark_generate_randomized( func, varargin{:} );

results = vertcat( results{:} );

end