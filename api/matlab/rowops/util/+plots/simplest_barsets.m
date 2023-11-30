function [axs, hs, xs] = simplest_barsets(data, I, id, L, varargin)

%   SIMPLEST_BARSETS -- Simple sets of bars with errors.
%
%     SIMPLEST_BARSETS( data, I, id, L ) for the numeric vector `data`, 
%     Mx1 cell array of indices `I`, MxN `id` matrix, and MxP cell matrix 
%     of labels `L` generates grouped bar plots from `data` in separate 
%     panels. 
%   
%     A separate panel is made for each unique value of `id(:, 1)`. 
%     Within each panel, separate sets of bars are drawn for each unique 
%     value of `id(:, 2)`, with a separate bar for each unique value
%     of `id(:, 3)`. Data are extracted based on indices in the 
%     corresponding rows of `I`, with labels drawn from the corresponding
%     rows of `L`.
%
%     Each bar is an average within a given subset, and errors lines show
%     +/- standard deviation.
%
%     SIMPLEST_BARSETS(..., 'summary_func', sfunc) and
%     SIMPLEST_BARSETS(..., 'error_func', efunc) use `sfunc` and
%     `efunc` to compute summary statistics and error statistics,
%     respectively. By default, `sfunc` is @mean and `efunc` is @std.
%
%     axs = SIMPLEST_BARSETS(...) returns an array of axis handles, with
%     one element for each panel.
%
%     //  EX 1.
%     f = fcat.example(); d = fcat.example( 'smalldata' );
%     % Create a panel for each 'dose', a bar for each 'monkey', and a set
%     % of bars for each 'roi'
%     [I, id, C] = rowsets( 3, f, 'dose', 'roi', 'monkey' );
%     axs = plots.simplest_barsets( d, I, id, plots.cellstr_join(C) );
%
%     //  EX 2.
%     f = fcat.example(); d = fcat.example( 'smalldata' );
%     % Create a panel for each 'image', a bar for each 'monkey', and a set
%     % of bars for each ('dose x 'roi').
%     % use `mask` to only plot 'outdoors' and 'scrambled' images
%     [I, id, C] = rowsets( 3, f, 'image', {'dose', 'roi'}, 'monkey' ...
%       , 'mask', find(f, {'outdoors', 'scrambled'}) );
%     axs = plots.simplest_barsets( d, I, id, plots.cellstr_join(C) );
%
%     //  EX 3.
%     f = fcat.example(); d = fcat.example( 'smalldata' );
%     % Create a panel for each 'image', a bar for each 'roi', and a set of
%     % bars for each 'dose'. Additionally, for each bar, preserve the set
%     % of 'monkey's within each bar and add points labeled by 'monkey'.
%     [I, id, C] = rowsets( 4, f, 'image', 'dose', 'roi', 'monkey' ...
%         , 'mask', find(f, {'outdoors', 'scrambled', 'cron', 'hitch'}) ...
%     );
%     L = plots.cellstr_join( C );
%     plots.simplest_barsets( d, I, id, L, 'add_points', true );
%
%     See also rowsets, findeach, fcat, plots.lines, plots.nest3

validateattributes( data, {'double'}, {'vector'}, mfilename, 'data' );

assert_rowsmatch( I, id );
assert_rowsmatch( I, L );

defaults = struct();
defaults.as_line_plot = false;
defaults.summary_func = @mean;
defaults.error_func = @std;
defaults.color_func = @jet;
defaults.cla = true;
defaults.add_points = false;
defaults.point_col = 4;
defaults.point_data = [];
defaults.panel_shape = [];
params = shared_utils.general.parsestruct( defaults, varargin );

if ( params.add_points )
  check_id( id, params.point_col );
end

[ip, lp, ii] = plots.nest3( id, I, L );
mus = nested_rowifun( params.summary_func, ip, data );
errs = nested_rowifun( params.error_func, ip, data );

if ( isempty(params.panel_shape) )
  axs = plots.panels( numel(mus), params.cla );
else
  axs = plots.panels( params.panel_shape, params.cla );
end

if ( params.as_line_plot )
  [hs, xs] = error_bar( axs, mus, errs, lp );
else
  [hs, xs] = plots.simple_barsets( axs, mus, errs, lp );
end

if ( params.add_points )
  pc = params.point_col;
  pd = check_point_data( params.point_data, data );
  plots.barpoints_sets( axs, pd, id(:, pc), L(:, pc), xs, ip, ii ...
    , 'color_func', params.color_func ...
  );
end

end

function pd = check_point_data(pd, data)

if ( isempty(pd) )
  pd = data;
else
  assert( isequal(size(pd), size(data)) ...
    , ['The size of data used to plot points must match the size of' ...
    , ' data used to plot bars.'] );
end

end

function check_id(id, point_col)

assert( size(id, 2) >= point_col ...
  , ['id matrix does not contain enough columns to plot points' ...
  , ' because ''point_col'' is %d but the matrix has %d columns.' ...
  , ' Use rowsets(%d, ...) to generate' ....
  , ' an id matrix with the appropriate number of columns' ....
  , ' or set ''point_col'' <= %d' ] ...
  , point_col, size(id, 2), point_col, size(id, 2) );

end

function [hs, xs] = error_bar(axs, mus, errs, lp)

hs = cell( size(mus) );
xs = {};

for i = 1:min(numel(axs), numel(mus))
  [r, c] = size( mus{i} );
  h = errorbar( axs(i), mus{i}, errs{i} );
  set( axs(i), 'xtick', 1:r );
  set( axs(i), 'xticklabels', lp{i, 2} );
  xlim( axs(i), [0, r+1] );
  for j = 1:c
    set( h(j), 'displayname', lp{i, 3}{j} );
  end
  title( axs(i), lp{i, 1} );
  legend( h );
  hs{i} = h;
end

end