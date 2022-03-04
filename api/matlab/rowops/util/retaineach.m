function [Y, I] = retaineach(X, coli, varargin)

%   RETAINEACH -- Retain each unique row.
%
%     Y = RETAINEACH( X, each ) for the 2D array `X` and vector of column
%     subscripts `each` returns an array `Y` with the same number of
%     columns as `X` and one row for each unique row of `X(:, each)` 
%     columns. The rows of `Y(:, each)` columns are exactly the unique rows
%     of `X(:, each)` columns. The remaining columns of `Y` not specified 
%     in `each` contain values that depend on a particular unique row of  
%     `X(:, each)` columns. For each unique row of `X(:, each)` columns, 
%     the value of a remaining column will be copied from `X` if the value 
%     is the same across all rows of `X` matching this unique row. 
%     Otherwise, the value of the column will be set to a missing value 
%     depending on the class of `X`.
%
%     [..., I] = RETAINEACH(...) also returns a cell array of index vectors
%     `I` with the same number of rows as `Y.` Each element is the set of
%     row indices into `X` that contain the corresponding unique row of
%     `Y`.
%
%     [Y, I] = RETAINEACH( X, each, mask ) for the vector `mask` operates 
%     on the rows of `X(mask, :)` and returns indices that are a subset of
%     `mask`.
%
%     //  EX
%     eg = load( 'carbig' );
%     t = table( cellstr(eg.Model), cellstr(eg.Origin), cellstr(eg.org) ...
%              , 'VariableNames', {'model', 'origin', 'org'} );
%
%     % There is one row for each 'origin'. The values in columns of 'org'
%     % are preserved because, for every unique value of 'origin', there is
%     % exactly one unique value of 'org'. Most of the values of 'model'
%     % are missing because there is more than one 'model' from most
%     % 'origin's. The exception is 'triumph tr7 coupe'; this value is 
%     % preserved because it is the only 'model' from 'England'.
%     y = retaineach( t, 'origin' )
%
%     See also findeach, rowsets, fcat, missing

if ( isa(X, 'fcat') )
  [Y, I] = keepeach_or_one( copy(X), coli, varargin{:} );
  return
end

[I, C] = findeach( X, coli, varargin{:} );
Y = X(1:size(C, 1), :);

coli = numeric_column_indices( X, coli );

if ( ~isempty(C) )
  Y(:, coli) = C;
end

resti = setdiff( 1:size(X, 2), coli );
for i = 1:numel(resti)
  ri = resti(i);
  missing_v = missing_value( X, ri );
  
  for j = 1:numel(I)
    v = unique( X(I{j}, ri) );
    if ( numel(v) == 1 )
      Y(j, ri) = v;
    else
      Y(j, ri) = missing_v;
    end
  end
end

end

function miss = missing_value(X, ci)

if ( istable(X) )
  if ( isempty(X) )
    miss = X([], ci);
  else
    miss = X(1, ci);
    miss{1, 1} = missing_value( miss{1, 1}, 1 );
  end
elseif ( iscell(X) )
  miss = {''};
elseif ( ischar(X) )
  miss = '';
else
  miss = X([]);
  miss(1) = missing;
end

end