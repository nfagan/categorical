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
  [y, ic] = do_unique( t );
  I = groupi( ic );
else
  m = m(:);
  [y, ic] = do_unique( t(m, :) );
  if ( islogical(m) ), m = find( m ); end
  I = cellfun( @(x) m(x), groupi(ic), 'un', 0 );
end

end

function [y, ic] = do_unique(t)

if ( iscell(t) )
  % try to use our custom unique function for cell arrays of strings.
  % only works when iscellstr(t) is true, i.e., t cannot contain
  % heterogeneous datatypes or non-char vector data.
  % remove this if/when matlab implements the 'rows' option for cell arrays.
  try
    [yi, ic] = cellstr_unique_rowi( t );
  catch err
    if ( ~iscellstr(t) )
      error( 'Can only compute groups of rows for a cell array of strings.' );
    else
      rethrow( err );
    end
  end
  y = t(yi, :);
else
  % defer to matlab's unique.
  [y, ~, ic] = unique( t, 'rows', 'stable' );
end

end