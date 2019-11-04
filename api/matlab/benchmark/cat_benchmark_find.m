function results = cat_benchmark_find(f, c, cats, varargin)

if ( nargin == 0 )
  f = fcat.example();
  [c, cats] = categorical( f );
end

params = cat_benchmark_config( varargin{:} );

iters = params.iters;

max_num_labels = 10;
selectors = make_selector_sets( f, iters, max_num_labels );

common_inputs = { ...
    'iters' params.iters ...
  , 'func', mfilename ...
  , 'group', 'find' ...
  , 'tag', [params.tags, {'find'}] ...
  , 'date', cat_datestr_ms( now ) ...
};

results_f = cat_benchmark_run( @(i) fcat_find(f, selectors, i) ...
  , 'name', 'fcat-find' ...
  , common_inputs{:} ...
);

results_c = cat_benchmark_run( @(i) mat_eq_match_category_behavior(f, c, cats, selectors, i) ...
  , 'name', 'mat-find-equivalent' ...
  , common_inputs{:} ...
);

results = [ results_f; results_c ];

end

function t = mat_eq_match_category_behavior(f, c, cats, selectors, i)

subset_selectors = selectors{i};
selector_cats = whichcat( f, subset_selectors );
[groups, names] = findgroups( selector_cats );
unique_groups = unique( groups );

tic;
tot = true( size(c, 1), 1 );

for i = 1:numel(unique_groups)
  group_ind = find( groups == unique_groups(i) );
  c_col = c(:, ismember(cats, names{i}));
  
  for j = 1:numel(group_ind)
    if ( j == 1 )
      res = c_col == subset_selectors{group_ind(j)};
    else
      res = res | c_col == subset_selectors{group_ind(j)};
    end
  end
  
  tot = tot & res;
end

t = toc();

end

function t = fcat_find(f, selectors, i)

tic;
ind = find( f, selectors{i} );
t = toc();

end

function sets = make_selector_sets(f, iters, max_num_labels)

labs = getlabs( f );
sets = cell( iters, 1 );

for i = 1:iters
  sets{i} = labs(randperm(numel(labs), randi(max_num_labels)));
end

end