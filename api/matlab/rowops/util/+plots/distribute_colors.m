function y = distribute_colors(gi, colors)

%   DISTRIBUTE_COLORS -- Distribute colors based on grouping variable.
%
%     colors = DISTRIBUTE_COLORS( g, f ) for the column vector `g` and
%     function handle `f` returns an Mx3 array of `colors`, with one row
%     for each element of `g`. `f` is a handle to a function that produces
%     a Px3 matrix of colors given `P`, the number of unique elements of 
%     `g`. For example, `f` can be @hsv, or @jet. Each row of `colors` is
%     a color matching a unique element of `g`.
%
%     //  EX
%     colors = plots.distribute_colors( [1, 2, 1, 2]', @jet );
%
%     See also rowsets, grp2idx, jet, spring

I = findeach( gi, 1 );
if ( isa(colors, 'function_handle') )
  colors = colors( numel(I) );
end

validateattributes( colors, {'numeric'}, {'nrows', numel(I), 'ncols', 3} ...
  , mfilename, 'colors' );
y = rowdistribute( zeros(rows(gi), 3, 'like', colors), I, colors );

end