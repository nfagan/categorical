function [sx, sy] = extract_points(I, x, data)

%   EXTRACT_POINTS -- Extract points from subsets of data.
%
%     [sx, sy] = EXTRACT_POINTS(I, x, data) for the cell array of index 
%     vectors `I`, numeric array `x`, and vector `data` returns numeric 
%     vectors `sx` and `sy` from  indexed subsets of `x` and `data`. Arrays 
%     `I` and `x` are of the same size. Each element of `I` indexes into 
%     `data`, producing a vector of y values at the corresponding `x`.
%     These sets are then concatenated vertically in order.
%
%     See also plots.points, plots.nest3

assert( isequal(size(I), size(x)), 'Input sizes do not correspond.' );

sx = [];
sy = [];

for i = 1:numel(I)
  d = columnize( data(I{i}) );
  sx = [ sx; repmat(x(i), size(d)) ];
  sy = [ sy; d ];
end

end