function [ax, shape] = panel(shape, i, cl)

%   PANEL -- Subplot panel.
%
%     ax = PANEL( shape, i ) for the 2 element vector `shape` and scalar
%     `i` in range [1, prod(shape)] returns the i-th axis of shape(1) *
%     shape(2) axes. It is the same as `subplot( shape(1), shape(2), i )`
%
%     ax = PANEL( N, i ) for the scalar `N` uses a heuristic to select
%     a subjectively "reasonable" PxQ subplot shape with P * Q >= N, and
%     returns the i-th axis.
%
%     ax = PANEL( ..., cla ) clears the axis if the logical flag `cla` is
%     true.
%
%     [..., shape] = PANEL(...) also returns the 2 element `shape` vector.
%
%     See also plots.bars, plots.lines, gca

if ( numel(shape) == 1 )
  shape = n_to_shape( shape );
end

ax = subplot( shape(1), shape(2), i );

if ( nargin > 2 && cl )
  cla( ax );
end

end

function shape = n_to_shape(N)

if ( N <= 3 )
  shape = [ 1, N ];
elseif ( N == 8 )
  shape = [ 2, 4 ];
else
  n_rows = round( sqrt(N) );
  n_cols = ceil( N/n_rows );
  shape = [ n_rows, n_cols ];
end

end