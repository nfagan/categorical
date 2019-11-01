function cat_benchmark_plot(results, varargin)

if ( isempty(results) )
  return
end

defaults = struct();
defaults.fig = [];
defaults.units = 'ms';
defaults.color_func = @jet;
defaults.include_errors = false;
defaults.plot_func = 'auto';
defaults.summary_type = 'mean';

params = parse_inputs( defaults, varargin );

time_factor = time_unit_factor( params.units );
plot_func = params.plot_func;
summary_type = params.summary_type;

fig = clf( get_figure(params) );
set( 0, 'currentfigure', fig );

[tag_groups, tag_names] = find_tag_groups( results );
panel_groups = unique( tag_groups );

shape = plotlabeled.get_subplot_shape( numel(panel_groups) );

for i = 1:numel(panel_groups)
  ax = subplot( shape(1), shape(2), i );
  
  panel_ind = tag_groups == panel_groups(i);
  subset_results = results(panel_ind);
  
  % x-axis
  [date_groups, dates] = find_date_groups( subset_results );
  % groups
  [name_groups, names] = find_name_groups( subset_results );
  
  summarized = arrayfun( @(x) x.stats.(summary_type), subset_results ) * time_factor;
  errs = arrayfun( @(x) x.stats.dev, subset_results ) * time_factor;
  iters = arrayfun( @(x) x.stats.n, subset_results );
  
  plt_summarized = nan( numel(dates), numel(names) );
  plt_errs = nan( size(plt_summarized) );
  plt_iters = nan( size(plt_summarized) );
  
  for j = 1:numel(names)
    for k = 1:numel(dates)
      ind = date_groups == k & name_groups == j;
      
      select_summarized = summarized(ind);
      select_errs = errs(ind);
      select_iters = iters(ind);
      
      if ( nnz(ind) > 1 )
        warning( 'More than one sample for the current date; averaging across these.' );
        select_summarized = mean( select_summarized );
        select_errs = mean( select_errs );
        select_iters = nan;
      end
      
      plt_summarized(k, j) = select_summarized;
      
      if ( params.include_errors )
        plt_errs(k, j) = select_errs;
      end
      
      plt_iters(k, j) = select_iters;
    end
  end
  
  colors = params.color_func( numel(names) );
  
  if ( strcmp(plot_func, 'errorbar') || (strcmp(plot_func, 'auto') && numel(dates) > 2) )
    hs = gobjects( numel(names), 1 );
  
    for j = 1:numel(names)
      if ( j == 1 )
        hold( ax, 'off' );
      end

      xs = 1:numel( dates ) + j * 0.01;
      hs(j) = errorbar( ax, xs, plt_summarized(:, j), plt_errs(:, j) );
      set( hs(j), 'color', colors(j, :) );
      set( hs(j), 'linewidth', 1.5 );

      if ( j == 1 )
        hold( ax, 'on' );
      end
    end
    
    set( ax, 'xtick', 1:numel(dates) );
    xlim( ax, [0, numel(dates)+1] );
    
  else
    if ( numel(dates) == 1 )
      plt_summarized = [ plt_summarized; plt_summarized ];
      x_lims = [0.5, 1.5];
    else
      x_lims = [];
    end
    
    hs = bar( 1:size(plt_summarized, 1), plt_summarized, 'grouped' );
    
    if ( ~isempty(x_lims) )
      xlim( ax, x_lims );
    end
    
    for j = 1:numel(hs)
      set( hs(j), 'facecolor', colors(j, :) );
    end
  end
  
  legend( hs, names );
  set( ax, 'xticklabel', format_dates(dates) );
  ylabel( ax, sprintf('Time (%s)', params.units) );
  title( ax, tag_names{i} );
end

end

function new_dates = format_dates(dates)

new_dates = datestr( dates );

end

function params = parse_inputs(defaults, varargin)

params = cat_parsestruct( defaults, varargin );
params.units = validatestring( params.units, {'ms', 's'}, mfilename, 'units' );
params.plot_func = validatestring( params.plot_func ...
  , {'auto', 'bar', 'errorbar'}, mfilename, 'plot_func' );
params.summary_type = validatestring( params.summary_type ...
  , {'mean', 'median'}, mfilename, 'summary_type' );

end

function factor = time_unit_factor(units)

switch ( units )
  case 'ms'
    factor = 1e3;
  case 's'
    factor = 1;
  otherwise
    error( 'Unhandled units "%s".', units );
end

end

function f = get_figure(params)

if ( isempty(params.fig) )
  f = gcf();
else
  f = params.fig;
end

end

function [date_groups, dates] = find_date_groups(results)

[date_groups, dates] = findgroups( {results.date} );

end

function [name_groups, names] = find_name_groups(results)

[name_groups, names] = findgroups( {results.name} );

end

function [groups, names] = find_tag_groups(results)

to_process = 1:numel(results);
groups = nan( size(results) );
names = {};
group_num = 1;

while ( ~isempty(to_process) )
  curr_tags = results(to_process(1)).tags;
  matches = arrayfun( @(x) isequal(x.tags, curr_tags), results(to_process) );
  
  groups(to_process(matches)) = group_num;
  names{group_num} = strjoin( curr_tags, ' | ' );
  
  to_process(matches) = [];
  group_num = group_num + 1;
end

end