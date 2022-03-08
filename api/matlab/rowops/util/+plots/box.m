function [h, x] = box(ax, data, I, gl, pl)

%   BOX -- Box plot.
%
%     h = BOX( ax, data, I, gl ) plots a grouped box plot from indexed
%     subsets of `data` into the axis `ax`. There is one group for each
%     element of `I`. Groups are labeled by `gl`, a string-like array with
%     one element for each group (and element of `I`).
%
%     h = BOX(..., pl) for the scalar string-like `pl` titles the axis with
%     `pl`.
%
%     [..., x] = BOX(...) also returns a vector of `x` bar centers
%     corresponding to each group.
%
%     //  EX
%     plots.box( gca, rand(8, 1), {1:4, 5:8}, {'x', 'y'} );
%
%     See also plots.bars, plots.

x = (1:numel(I))';
g = rowdistribute( nan(size(data)), I, x );
h = boxplot( ax, data, g, 'labels', gl );

if ( nargin > 4 )
  title( ax, pl );
end

end