function [axs, info] = summarized3(data, I, pL, gL, xL, options)

%   SUMMARIZED3 -- Create plots from group-summarized data with 3 levels of nesting.
%
%     plots.summarized3( data, [], pl, gl, xl );
%
%     creates a series of shaded-line plots with means and standard errors
%     of `data`. `pl`, `gl`, `xl` are grouping arrays with the same number
%     of rows as `data`. Panels are constructed from the unique rows of 
%     `pl`; within a panel, data are grouped by the unique rows of `gl`, 
%     and plotted over corresponding (unique) elements of `xl`.
%
%     plots.summarized3( data, I, pl, gl, xl ); works similarly, except
%     that groups are drawn `I`, a cell array of index vectors. In this
%     case, `pl`, `gl`, `xl` are grouping arrays with the same number of 
%     rows as the number of elements of `I`.
%
%     plots.summarized3( ..., name=value ) specifies additional
%     name/value paired arguments. These include:
%
%       Type - string specifying the type of plot to make. "shaded-line"
%         plots continuous lines surrounded by a shaded region for
%         dispersion. "error-bar" uses Matlab's error bar function. "bar"
%         makes bar plots. "scatter" makes a scatter. Default "shaded-line"
%
%       ColorFunc - handle to a function for specifying line colors. 
%         Default @hsv.
%
%       SummaryFunc - handle to a function for collapsing multiple
%         observations of data to a scalar value. Default @mean.
%
%       ErrorFunc - handle to a function for computing dispersion of
%         multiple observations of data. Default @plotlabeled.sem.
%
%       PerPanelGroups - true if unique groups should be computed 
%         separately for each panel, or remain consistent across panels. 
%         Default false.
%
%       PerPanelX - true if unique elements comprising the x axis should be
%         computed separately for each panel, or remain consistent across
%         panels. Default false.
%
%       WarnMissingX - true if the plot should include a visual warning (in
%         the title) if, within a given panel, a group does not have data 
%         for one or more levels of `x`. Default true.
%
%       WarnMissingGroup - true if the plot should include a visual warning
%         (in the title) if, within a given panel, a group is completely
%         missing (i.e., has no data for any level of `x`. Default false.
%
%       AddPoints - true if the plot should scatter individual data points
%         atop their summarized values. Default false.
%
%       NumericX - true if `xl` should be interpreted as numeric coordinates 
%         to plot `data` against; false if `xl` should be interpreted as 
%         categorical levels, in which case `data` will be plotted against
%         integers 1 through the number of levels. Can also be [], in which
%         case `xl` is interpreted as numeric if it is a numeric vector or
%         an equivalent table, and otherwise as categorical. Default [].
%
%     //  EX 1.
%     t = struct2table( load('carbig') );
%     [I, pl, gl, xl] = rowsets3( t, "Origin", "Cylinders", "when", Mask=~isnan(t.MPG) );
%     figure(1); clf; axs = plots.summarized3( t.MPG, I, pl, gl, xl, Type='bar' );
%     ylabel( axs, 'Average MPG' );
%
%     //  EX 2.
%     data = rand( 8, 1 );
%     gl = repmat( [1; 2; 1; 2], 2, 1 ); % groups
%     pl = [ zeros(4, 1); ones(4, 1) ]; % panels
%     figure(1); clf; plots.summarized3( data, [], pl, gl, [], Type='bar' );
%
%     See also rowsets3, table, grp2idx

arguments
  data, I, pL {mustBeMatrix}, gL {mustBeMatrix}, xL {mustBeMatrix};
  options.Summarize logical = true;
  options.XJitter = 0.05;
  options.SummaryFunc function_handle = @mean;
  options.ErrorFunc function_handle = @plotlabeled.sem;
  options.ColorFunc function_handle = @hsv;
  options.MarkerSize = 8;
  options.PerPanelGroups = false;
  options.PerPanelX = false;
  options.WarnMissingX = true;
  options.WarnMissingG = false;
  options.MatchXLims = true;
  options.MatchYLims = true;
  options.NumericX logical {mustBeScalarOrEmpty} = [];
  options.Type string {...
    mustBeMember(options.Type, [...
      "shaded-line", "error-bar", "bar", "scatter", "violin", "box"]) ...
  } = "shaded-line";
  options.YAxis = [];
  options.AddPoints = false;
  options.UseBarX = false;
  options.LegendFontSize = 22;
  options.LabelFontSize = 16;
end

% ----------------------------------------------------------------------
% validation

if ( iscell(xL) )
  assert( size(xL, 2) == 1, ['If X-axis values are a cell array, they' ...
    , ' must be a column vector, not a matrix.'] );
end

if ( ~options.Summarize )
  assert( ismember(options.Type, ["scatter", "violin", "box"]) ...
    , "Can only plot non-summarized data as a scatter, violin, or box plot." );
end

if ( ismember(options.Type, ["violin", "box"]) )
  assert( isscalar(rowgroups(gL)) || isempty(gL) ...
    , 'When making violin or box plots, data cannot be grouped.' );
end

if ( isequal(I, []) )
  ni = rows( data );
  if ( isequal(pL, []) ), pL = strings( ni, 1 ); end
  if ( isequal(gL, []) ), gL = strings( ni, 1 ); end
  if ( isequal(xL, []) ), xL = strings( ni, 1 ); end
else
  validateattributes( I, {'cell'}, {}, mfilename, 'I' );
  ni = numel( I );
end

assert( ni == rows(pL), 'Index sets do not correspond to panel labels.' );
assert( ni == rows(gL), 'Index sets do not correspond to group labels.' );
assert( ni == rows(xL), 'Index sets do not correspond to x labels.' );

% ----------------------------------------------------------------------

[pI, pLL] = rowgroups( pL );
axs = plots.panels( numel(pI) );
info = cell( numel(pI), 1 );

for i = 1:size(pI, 1)
  [mI, mxL, mgL] = build_panel_index_matrix( I, xL, gL, pI{i}, options );
  info{i} = make_panel_info( pLL(i, :), mI, mxL, mgL );

  if ( options.Summarize )
    mu = rowifun( options.SummaryFunc, mI, data );
  else
    mu = rowifun( @identity, mI, data, 'un', 0 );
  end

  er = rowifun( options.ErrorFunc, mI, data );
  cs = options.ColorFunc( rows(mgL) );

  pls = make_label_string( pLL );
  gls = make_label_string( mgL );
  xls = make_label_string( mxL );
  tl = make_title_label( pls(i), mI, options );

  % determine the numeric x to plot data against.
  [nx, was_numeric_x, x_var] = to_numeric_x( mxL, options );

  % plot
  ax = prepare_axes( axs(i), options );
  h = draw( ax, nx, mu, er, gls, cs, options );
  add_legend( h, options );
  add_title( ax, tl, options );
  configure_axes( ax, xls, was_numeric_x, x_var, options );
end

if ( ~options.PerPanelGroups ), plots.onelegend( gcf ); end
if ( options.MatchXLims ), shared_utils.plot.match_xlims( axs ); end
if ( options.MatchYLims ), shared_utils.plot.match_ylims( axs ); end

if ( options.AddPoints )
  args = { data, I, pL, gL, xL };
  replot_add_points( args, options );
end

info = vertcat( info{:} );

end

function replot_add_points(args, options)

% re-run with scatter option
opts = options;
opts.Type = 'scatter';
opts.AddPoints = false;
opts.Summarize = false;
opts = shared_utils.general.struct2varargin( opts );
plots.summarized3( args{:}, opts{:} );

end

function configure_axes(ax, xls, was_numeric_x, x_var, options)
if ( ~was_numeric_x )
  set( ax, 'xtick', 1:numel(xls), 'xticklabels', xls );
  xlim( ax, [0, numel(xls) + 1] );
end
if ( ~isempty(x_var) ), xlabel( ax, plots.strip_underscore(x_var) ); end

set( get(ax, 'xaxis'), 'fontsize', options.LabelFontSize );
set( get(ax, 'yaxis'), 'fontsize', options.LabelFontSize );
end

function add_title(ax, tl, options)
th = title( ax, tl ); 
set( th, 'fontsize', options.LabelFontSize );
end

function add_legend(h, options)
if ( ~isempty(h) )
  hl = legend( h ); 
  set( hl, 'edgecolor', 'none', 'fontsize', options.LegendFontSize );
end
end

function ax = prepare_axes(ax, options)
hold( ax, 'on' );
if ( ~isempty(options.YAxis) )
  yyaxis( ax, options.YAxis ); 
end
end

function info = make_panel_info(pl, mI, mxL, mgL)
info = struct();
info.I = mI;
info.pl = pl;
info.xl = mxL;
info.gl = mgL;
end

function tl = make_title_label(tl, mI, options)

isemp = cellfun( 'isempty', mI );

miss_g = all( isemp, 1 );
miss_x = any( isemp, 1 );

warn_x = miss_x & ~miss_g;
if ( any(warn_x) && options.WarnMissingX )
  tl = compose( "%s (~x!)", tl );
end
if ( any(miss_g) && options.WarnMissingG )
  tl = compose( "%s (~g!)", tl );
end

tl = plots.strip_underscore( tl );
tl = split_into_chunks_delim( char(tl), 32, ' | ' );

end

function h = draw(ax, nx, mu, er, gls, cs, options)

no_h = false;
switch ( options.Type )
  case 'shaded-line'
    h = plot( ax, nx, mu, 'linewidth', 2 );
    shaded_line( ax, nx', mu', er', cs );
    cp = 'color';

  case 'error-bar'
    h = errorbar( ax, nx, mu, er, 'linewidth', 2 );
    cp = 'color';

  case 'bar'
    [h, cp] = draw_bar( ax, nx, mu, er );

  case 'scatter'
    [h, cp] = draw_scatter( ax, nx, mu, cs, options );

  case 'violin'
    [h, cp] = draw_violin( ax, nx, mu );

  case 'box'
    [h, cp] = draw_box( ax, nx, mu );
    no_h = true;

  otherwise
    error( 'Unrecognized type "%s"', options.Type );
end

for j = 1:numel(h)
  if ( iscell(h) )
    hj = h{j};
  else
    hj = h(j);
  end
  set( hj, 'displayname', gls(j), cp, cs(j, :) ); 
end

if ( no_h ), h = []; end

end

function [h, cp] = draw_box(ax, nx, mu)

if ( iscell(mu) )
  % data are not summarized.
  nr = cellfun( @rows, mu );
  nx = repelem( nx, nr, 1 );
  mu = vertcat( mu{:} );
end

old_h = findobj( ax );
boxplot( ax, mu, nx, 'Positions', nx );
h = setdiff( findobj(ax, 'tag', 'boxplot'), old_h );
h = { h.Children };
cp = 'color';

end

function [h, cp] = draw_violin(ax, nx, mu)

if ( iscell(mu) )
  % data are not summarized.
  nr = cellfun( @rows, mu );
  nx = repelem( nx, nr, 1 );
  mu = vertcat( mu{:} );
end

h = violinplot( ax, nx, mu );
set( h, 'edgecolor', 'none' );
cp = 'FaceColor';

end

function [h, cp] = draw_bar(ax, nx, mu, er)

h = bar( ax, nx, mu ); set( h, 'edgecolor', 'none' );
eps = arrayfun( @(x) get(x, 'xendpoints'), h, 'un', 0 );
for i = 1:numel(eps)
  x = eps{i};
  y = reshape( mu(:, i), size(x) );
  yy = reshape( er(:, i), size(x) );
  plot( ax, [x; x], [y - yy * 0.5; y + yy * 0.5], 'linewidth', 1.5, 'color', 'k' );
end
cp = 'facecolor';

end

function [h, cp] = draw_scatter(ax, nx, mu, cs, options)

h = gobjects( size(mu, 2),  1 );
cp = 'markerfacecolor';

% Try to pull x-locations from bar centers, if requested.
use_bar_points = options.UseBarX;
bar_points_warn_msg = ['Bars do not correspond to scatter data; using' ...
  , ' unadjusted x positions to scatter data.'];
if ( use_bar_points )
  hb = flip( findobj(ax, 'type', 'bar') );
  xb = arrayfun( @(x) get(x, 'xendpoints'), hb, 'un', 0 );
  if ( numel(xb) ~= size(mu, 2) )
    warning( bar_points_warn_msg );
    use_bar_points = false;
  end
end

for j = 1:size(mu, 2)
  x = nx;
  y = mu(:, j);

  if ( use_bar_points )
    % Try to pull x-locations from bar centers.
    if ( numel(x) ~= numel(xb{j}) )
      warning( bar_points_warn_msg );
      use_bar_points = false;
    else
      x = reshape( xb{j}, size(x) );
    end
  end

  if ( ~options.Summarize )
    x = repelem( x, cellfun(@numel, y), 1 );
    if ( isscalar(nx) )
      dx = 1;
    else
      dx = mean( diff(nx(:)) );
    end
    x = x + ((rand(size(x))) * 2 - 1) * dx * options.XJitter;
    y = vertcat( y{:} );
  end
  h(j) = scatter( ax, x, y, options.MarkerSize, cs(j, :) );
  if ( use_bar_points ), set( h(j), 'markeredgecolor', 'k' ); end
end

end

function [nx, was_numeric_x, x_var] = to_numeric_x(mxL, options)

nx = mxL;
was_numeric_x = false;
x_var = '';
num_x = (1:size(nx, 1))';

if ( ~isempty(options.NumericX) && ~options.NumericX )
  nx = num_x;
  return
end

if ( ~isnumeric(nx) )
  if ( istable(nx) && size(nx, 2) == 1 && isnumeric(nx{:, 1}) )
    x_var = nx.Properties.VariableNames{1};
    nx = nx{:, 1};
    was_numeric_x = true;
  else
    % [~, ~, nx] = unique( nx, 'rows', 'stable' );
    nx = num_x;
  end
else
  was_numeric_x = true;
end

end

function [mI, mxL, mgL] = build_panel_index_matrix(I, xL, gL, si, options)

% build a matrix of indices, (x * group)

[gII, pgL] = rowgroups( gL, si );

mgL = pgL;
if ( ~options.PerPanelGroups )
  [~, mgL] = rowgroups( gL );
end

if ( options.PerPanelX )
  [~, mxL] = rowgroups( xL, si );
else
  [~, mxL] = rowgroups( xL );
end

mI = cell( rows(mxL), rows(mgL) );
for j = 1:numel(gII)
  [xII, pxL] = rowgroups( xL, gII{j} );
  [~, mg] = ismember( pgL(j, :), mgL );
  for k = 1:numel(xII)
    if ( size(mxL, 2) > 1 )
      [~, mx] = ismember( pxL(k, :), mxL, 'rows' );
    else
      [~, mx] = ismember( pxL(k, :), mxL );
    end
    if ( isequal(I, []) )
      mI{mx, mg} = xII{k};
    else
      mI{mx, mg} = vertcat( I{xII{k}} );
    end
  end
end

end

function y = make_label_string(x)

y = x;
if ( ~isstring(y) )
  if ( istable(y) )
    y = table2str( y );
  else
    y = string( y );
  end
end
y = plots.strip_underscore( y );

end

function hh = shaded_line(ax, x, mu, err, colors)

hh = gobjects( size(x, 1), 1 );
for i = 1:size(mu, 1)
  xp = [ x(1, :), fliplr(x(1, :)) ];
  y0 = mu(i, :) - err(i, :);
  y1 = mu(i, :) + err(i, :);
  between = [ y0, fliplr(y1) ];
  hh(i) = fill( ax, xp, between, colors(i, :) );
  set( hh(i), 'FaceAlpha', 0.25, 'edgecolor', 'none' );
end

end

function chunks = split_into_chunks_delim(s, l, delimiter)
  arguments
      s (1,:)        char
      l (1,1)        {mustBePositive, mustBeInteger}
      delimiter (1,:) char
  end

  % Pre-allocate a cell array with a reasonable upper bound on size
  % (worst-case: every character followed by delimiter gives ~|s| splits)
  chunks      = cell(1, ceil(numel(s)));  
  chunk_count = 0;

  while true
    % If the remaining text already fits, append and finish
    if numel(s) <= l
      chunk_count = chunk_count + 1;
      chunks{chunk_count} = s;
      break
    end

    % Find the earliest delimiter
    idx = strfind(s, delimiter);

    % No delimiter left — store the whole remainder and finish
    if isempty(idx)
      chunk_count = chunk_count + 1;
      chunks{chunk_count} = s;
      break
    end

    k = idx(1);                         % position of first delimiter
    left = s(1:k-1);                   % text before it
    right = s(k + numel(delimiter) : end);  % text after it

    % Only store non-empty pieces (handles delimiter at position 1)
    if ~isempty(left)
      chunk_count = chunk_count + 1;
      chunks{chunk_count} = left;
    end

    % Continue wrapping the remainder
    s = right;
  end

  % Trim any unused cells created by the rough pre-allocation
  chunks = chunks(1:chunk_count);
end
