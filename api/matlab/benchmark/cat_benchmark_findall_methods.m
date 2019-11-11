function results = cat_benchmark_findall_methods(f, c, cats, varargin)

if ( nargin == 0 )
  f = fcat.example();
  [c, cats] = categorical( f );
end

params = cat_benchmark_config( varargin{:} );
iters = params.iters;
category_sets = make_category_sets( f, iters );

common_inputs = make_common_inputs( params );

methods = { 'hash', 'cust', 'sort' };
results = cell( numel(methods), 1 );

for i = 1:numel(methods)
  method = methods{i};
  
  results{i} = cat_benchmark_run( @(i) fcat_findall(f, category_sets, method, i) ...
    , 'name', sprintf('findall-%s', method) ...
    , common_inputs{:} ...
  );
end

results = vertcat( results{:} );

end

function common_inputs = make_common_inputs(params)

common_inputs = { ...
    'iters' params.iters ...
  , 'func', mfilename ...
  , 'group', 'findall' ...
  , 'tag', [params.tags, {'findall'}] ...
  , 'date', cat_datestr_ms( now ) ...
};

end

function t = fcat_findall(f, cats, method, i)

tic();
inds = findall( f, cats{i}, method );
t = toc;

end

function category_sets = make_category_sets(f, iters)

category_sets = cell( iters, 1 );

cats = getcats( f );

for i = 1:iters  
  category_sets{i} = cats(randperm(numel(cats), randi(numel(cats))));
end

end