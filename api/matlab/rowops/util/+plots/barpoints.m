function h = barpoints(ax, data, xs, ip, L, colors, varargin)

%   BARPOINTS -- Scatter atop bar plot.
%
%     BARPOINTS( ax, data, xs, ip, L, colors ) scatters elements of `data`
%     against x coordinates drawn from the matrix `xs` corresponding to the
%     index matrix `ip`. Elements of `data` given by the i-th index in `ip`
%     are scattered against the i-th x coordinate in `xs`. `L` is a vector
%     of labels with sum(cellfun('length', ip)) elements, that is, one
%     element for each element of `data` extracted using the indices in
%     `ip`. `colors` is an Mx3 matrix of colors with M == numel(L).
%
%     //  EX
%     L = {'x1', 'x1', 'x1', 'x2', 'x2', 'x2'}';
%     colors = [ repmat([1, 0, 0], 3, 1); repmat([0, 1, 0], 3, 1) ];
%     ax = plots.holdon( cla(gca) );
%     plots.barpoints( ax, rand(8, 1), [0.5, 1], {1:3, 4:6}, L, colors );
%     xlim( [0, 2] );
%
%     See also plots.points

[sx, sy] = plots.extract_points( ip, xs, data );
h = plots.points( ax, sx, sy, L, colors, varargin{:} );

end