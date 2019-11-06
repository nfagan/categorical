function results = cat_benchmark_generate_findall_indexed(varargin)

results = cat_benchmark_generate( @cat_benchmark_findall_indexed, 'iter', 100, varargin{:} );

end