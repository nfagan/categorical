function results = cat_benchmark_generate_findall(varargin)

results = cat_benchmark_generate( @cat_benchmark_findall, 'iter', 100, varargin{:} );

end