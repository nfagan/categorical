function h = points(ax, sx, sy, sg, sc, varargin)

%   POINTS -- Grouped scatter plot.
%
%     POINTS( ax, x, y, g, c ) scatters vectors `x` against `y`. `g` is a
%     grouping vector the same size as `x` and `y`, with separate scatters 
%     created for the unique rows of `g`, and for which a legend is
%     created. `sc` is an Mx3 matrix with one row for each value of `x` and 
%     `y`, specifying the marker color. `ax` is a handle to the axis in 
%     which to plot.
%
%     POINTS( ..., 'marker_size', ms ) for the scalar `ms` specifies the 
%       marker size. Default is 8.
%     POINTS( ..., 'marker', marker ) for the char `marker` specifies the 
%       marker style. Default is 'o'.
%
%     h = POINTS(...) returns an array of handles to the scatter plots.
%     There is a separate scatter object for each unique row of `sg`.
%
%     See also scatter, plots.lines, plots.bars

defaults = struct();
defaults.marker_size = 8;
defaults.marker = 'o';
params = shared_utils.general.parsestruct( defaults, varargin );

assert( isequal(size(sx), size(sy), size(sg)), 'Input sizes do not correspond.' );
assert_rowsmatch( sg, sc );

leg = findobj( ax.Parent, 'type', 'legend' );
curr_update = arrayfun( @(x) get(x, 'autoupdate'), leg );
for i = 1:numel(leg)
  set( leg(i), 'autoupdate', true );
end

[gi, gc] = findeach( sg, 1 );
h = gobjects( size(gi) );
for i = 1:numel(gi)
  h(i) = scatter( ax, sx(gi{i}), sy(gi{i}), params.marker_size, sc(gi{i}, :) ...
    , params.marker ...
    , 'DisplayName', string(gc(i)) );
end

for i = 1:numel(leg)
  set( leg, 'autoupdate', curr_update(i) );
end

end