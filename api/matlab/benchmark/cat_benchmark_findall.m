function results = cat_benchmark_findall(f, c, cats, varargin)

if ( nargin == 0 )
  f = fcat.example();
  [c, cats] = categorical( f );
end

params = cat_benchmark_config( varargin{:} );

iters = params.iters;

category_sets = make_category_sets( f, iters );

common_inputs = { ...
    'iters' params.iters ...
  , 'func', mfilename ...
  , 'group', 'findall' ...
  , 'tag', [params.tags, {'findall'}] ...
  , 'date', cat_datestr_ms( now ) ...
};

results = {};

results{end+1} = cat_benchmark_run( @(i) fcat_findall(f, category_sets, i) ...
  , 'name', 'fcat-findall' ...
  , common_inputs{:} ...
);

results{end+1} = cat_benchmark_run( @(i) mat_findall(c, cats, category_sets, i) ...
  , 'name', 'mat-findall' ...
  , common_inputs{:} ...
);

results = vertcat( results{:} );

end

function t = mat_findall(c, cats, category_sets, i)

cat_set = category_sets{i};
[~, cat_inds] = ismember( cat_set, cats );

tic;
[~, ~, ind] = unique( c(:, cat_inds), 'rows' );
t = toc;

end

function t = fcat_findall(f, cats, i)

tic();
inds = findall( f, cats{i}, 'cust' );
t = toc;

end

function category_sets = make_category_sets(f, iters)

category_sets = cell( iters, 1 );

cats = getcats( f );

for i = 1:iters  
  category_sets{i} = cats(randperm(numel(cats), randi(numel(cats))));
end

end