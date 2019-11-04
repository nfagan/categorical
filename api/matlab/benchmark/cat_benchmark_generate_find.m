function results = cat_benchmark_generate_find(varargin)

results = cat_benchmark_generate( @cat_benchmark_find, 'iter', 100, varargin{:} );

end