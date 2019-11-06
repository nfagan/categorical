function results = cat_benchmark_findall_indexed(f, c, cats, varargin)

if ( nargin == 0 )
  f = fcat.example();
  [c, cats] = categorical( f );
end

params = cat_benchmark_config( varargin{:} );

iters = params.iters;

[category_sets, row_inds] = make_category_sets( f, iters );

common_inputs = { ...
    'iters' params.iters ...
  , 'func', mfilename ...
  , 'group', 'findall' ...
  , 'tag', [params.tags, {'findall'}] ...
  , 'date', cat_datestr_ms( now ) ...
};

results = {};

results{end+1} = cat_benchmark_run( @(i) fcat_findall(f, category_sets, row_inds, i) ...
  , 'name', 'fcat-findall-indexed' ...
  , common_inputs{:} ...
);

results{end+1} = cat_benchmark_run( @(i) mat_findall(c, cats, category_sets, row_inds, i) ...
  , 'name', 'mat-findall-indexed' ...
  , common_inputs{:} ...
);

results = vertcat( results{:} );

end

function t = mat_findall(c, cats, category_sets, row_inds, i)

cat_set = category_sets{i};
row_ind = row_inds{i};
[~, cat_inds] = ismember( cat_set, cats );

tic;
[~, ~, ind] = unique( c(row_ind, cat_inds), 'rows' );
ind = row_ind(ind);
t = toc;

end

function t = fcat_findall(f, cats, row_inds, i)

tic();
inds = findall( f, cats{i}, row_inds{i} );
t = toc;

end

function [category_sets, row_inds] = make_category_sets(f, iters)

category_sets = cell( iters, 1 );
row_inds = cell( size(category_sets) );

cats = getcats( f );

for i = 1:iters  
  category_sets{i} = cats(randperm(numel(cats), randi(numel(cats))));
  row_inds{i} = sort( randperm(rows(f), randi(rows(f))) );
end

end