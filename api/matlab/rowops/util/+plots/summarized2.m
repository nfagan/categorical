function axs = summarized2(data, I, pL, gL, xL, options)

%   SUMMARIZED2 -- Create a series of plots from group-summarized data.
%
%     plots.summarized2( data, I, pl, gl, xl );
%
%     creates a series of shaded-line plots with means and standard errors
%     of `data`.
%
%     `I` is a cell array of index vectors identifying groups of `data`. 
%     `pl`, `gl`, `xl` are grouping arrays with the same number of rows as
%     the number of elements of `I`. Panels are constructed from the unique
%     rows of `pl`; within a panel, data are grouped by the unique rows of 
%     `gl`, and plotted over corresponding (unique) elements of `xl`.
%
%     plots.summarized2( ..., name=value ) specifies additional
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
%     //  EX.
%     t = struct2table( load('carbig') );
%     [I, pl, gl, xl] = rowsets3( t, "Origin", "Cylinders", "when", Mask=~isnan(t.MPG) );
%     figure(1); clf; axs = plots.summarized2( t.MPG, I, pl, gl, xl, Type='bar' );
%     ylabel( axs, 'Average MPG' );
%
%     See also rowsets3, table, grp2idx

arguments
  data, I cell, pL {mustBeMatrix}, gL {mustBeMatrix}, xL {mustBeMatrix};
  options.Summarize logical = true;
  options.XJitter = 0;
  options.SummaryFunc function_handle = @mean;
  options.ErrorFunc function_handle = @plotlabeled.sem;
  options.ColorFunc function_handle = @hsv;
  options.MarkerSize = [];
  options.PerPanelGroups = false;
  options.PerPanelX = false;
  options.WarnMissingX = true;
  options.WarnMissingG = false;
  options.MatchXLims = true;
  options.MatchYLims = true;
  options.Type string {...
    mustBeMember(options.Type, ["shaded-line", "error-bar", "bar", "scatter"]) ...
  } = "shaded-line";
  options.YAxis = [];
end

% ----------------------------------------------------------------------
% validation

if ( iscell(xL) )
  assert( size(xL, 2) == 1, ['If X-axis values are a cell array, they' ...
    , ' must be a column vector, not a matrix.'] );
end

if ( ~options.Summarize )
  assert( options.Type == "scatter" ...
    , "Can only plot non-summarized data as a scatter plot." );
end

assert( numel(I) == rows(pL), 'Index sets do not correspond to panel labels.' );
assert( numel(I) == rows(gL), 'Index sets do not correspond to group labels.' );
assert( numel(I) == rows(xL), 'Index sets do not correspond to x labels.' );

% ----------------------------------------------------------------------

[pI, pLL] = rowgroups( pL );
axs = plots.panels( numel(pI) );

for i = 1:size(pI, 1)
  [mI, mxL, mgL] = build_panel_index_matrix( I, xL, gL, pI{i}, options );

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

  % determine the numeric x to plot data against.
  [nx, was_numeric_x, x_var] = to_numeric_x( mxL );

  % plot
  ax = axs(i); hold( ax, 'on' );
  if ( ~isempty(options.YAxis) ), yyaxis( ax, options.YAxis ); end
  h = draw( ax, nx, mu, er, gls, cs, options );
  legend( h );

  tl = make_title_label( pls(i), mI, options );
  title( ax, tl );

  if ( ~was_numeric_x )
    set( ax, 'xtick', 1:numel(xls), 'xticklabels', xls );
    xlim( ax, [0, numel(xls) + 1] );
  end
  if ( ~isempty(x_var) ), xlabel( ax, x_var ); end
end

if ( ~options.PerPanelGroups ), plots.onelegend( gcf ); end
if ( options.MatchXLims ), shared_utils.plot.match_xlims( axs ); end
if ( options.MatchYLims ), shared_utils.plot.match_ylims( axs ); end

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

end

function h = draw(ax, pxl, mu, er, gls, cs, options)

switch ( options.Type )
  case 'shaded-line'
    h = plot( ax, pxl, mu, 'linewidth', 2 );
    shaded_line( ax, pxl', mu', er', cs );
    cp = 'color';
  case 'error-bar'
    h = errorbar( ax, pxl, mu, er, 'linewidth', 2 );
    cp = 'color';
  case 'bar'
    h = bar( ax, pxl, mu );
    cp = 'facecolor';
  case 'scatter'
    h = gobjects( size(mu, 2),  1 );
    cp = 'markerfacecolor';
    for j = 1:size(mu, 2)
      x = pxl;
      y = mu(:, j);
      if ( ~options.Summarize )
        x = repelem( x, cellfun(@numel, y), 1 );
        dx = mean( diff(pxl(:)) );
        x = x + ((rand(size(x))) * 2 - 1) * dx * options.XJitter;
        y = vertcat( y{:} );
      end
      h(j) = scatter( ax, x, y, options.MarkerSize, cs(j, :) );
    end
  otherwise
    error( 'Unrecognized type "%s"', options.Type );
end

for j = 1:numel(h)
  set( h(j), 'displayname', gls(j), cp, cs(j, :) ); 
end

end

function [nx, was_numeric_x, x_var] = to_numeric_x(mxL)

nx = mxL;
was_numeric_x = false;
x_var = '';

if ( ~isnumeric(nx) )
  if ( istable(nx) && size(nx, 2) == 1 && isnumeric(nx{:, 1}) )
    x_var = nx.Properties.VariableNames{1};
    nx = nx{:, 1};
    was_numeric_x = true;
  else
    % [~, ~, nx] = unique( nx, 'rows', 'stable' );
    nx = (1:size(nx, 1))';
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
    mI{mx, mg} = vertcat( I{xII{k}} );
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