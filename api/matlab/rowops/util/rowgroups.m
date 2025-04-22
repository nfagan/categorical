function [I, y] = rowgroups(t, m)

%   ROWGROUPS -- Find groups of unique rows.
%
%     I = rowgroups( t ); for the 2D array `t` returns a cell array of 
%     index vectors `I`. Each element of `I` contains the set of indices
%     into `t` associated with a unique row of `t`.
%
%     [I, y] = rowgroups( t ); also returns the unique rows of `t`, which 
%     correspond to elements of `I`.
%
%     [I, y] = rowgroups( t, m ); for the logical or numeric index vector
%     `m` evaluates the subset of `t(m, :)` rows and returns indices that
%     are a subset of `m`.
%
%     //  EX
%
%     load('carbig');
%     t = rmmissing(table(Model, Origin, MPG, Displacement, Horsepower));
%     [I, y] = rowgroups(t(:, {'Origin', 'MPG'}));
%     y.Horsepower = rowifun( @mean, I, t.Horsepower )
%
%     See also groupi, rowifun, findeach, rowsets, findgroups

narginchk( 1, 2 );

if ( nargin < 2 )
  [y, ~, ic] = unique( t, 'rows' );
  I = groupi( ic );
else
  [y, ~, ic] = unique( t(m, :), 'rows' );
  if ( islogical(m) ), m = find( m ); end
  I = cellfun( @(x) m(x), groupi(ic), 'un', 0 );
end

end