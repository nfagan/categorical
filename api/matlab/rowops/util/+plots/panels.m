function [axs, shape] = panels(shape, cl)

%   PANELS -- Subplot panels.
%
%     axs = PANELS( shape ) for the 2 element vector `shape` returns an Mx1
%     array of axis handles `axs` with M == prod(shape).
%
%     [axs, shape] = PANELS( N ) for the scalar `N` uses a heuristic to 
%     select a subjectively "reasonable" PxQ subplot shape with P * Q >= N, 
%     and returns an Nx1 array of axis handles along with the computed
%     shape.
%
%     PANELS( ..., cla ) clears the axes if the logical flag `cla` is
%     true.
%
%     See also plots.bars, plots.lines, gca

if ( numel(shape) == 1 )
  n = shape;
  shape = n_to_shape( shape );
else
  n = prod( shape );
end

axs = gobjects( n, 1 );

for i = 1:n
  axs(i) = subplot( shape(1), shape(2), i );
  if ( nargin > 1 && cl )
    cla( axs(i) );
  end
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