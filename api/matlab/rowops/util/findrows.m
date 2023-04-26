function ind = findrows(X, labels, varargin)

%   FINDROWS -- Find rows matching label combination.
%
%     ind = findrows( X, labels ) returns row indices into `X` matching the
%     label combination `labels`. `X` is a 2D numeric, string, categorical, 
%     table, or fcat array. `labels` is an array whose elements are
%     compatible with the class underlying `X` for computing equality
%     between elements. For example, if `X` is a table whose variables are 
%     categorical arrays, then `labels` can be a cell array of strings, a 
%     string array, or categorical array.
%
%     `findrows` returns indices matching `labels` in the following way:
%     for each label in `labels`, columns of `X` are searched independently 
%     for the label. If no columns contain `label`, `findrows` returns an
%     empty array ([]). Otherwise, separately for each column, a union is
%     computed between previously matched row indices and currently matched
%     row indices (i.e., those containing `label`). After considering all 
%     `labels`, `findrows` returns the intersection of the sets of indices 
%     across columns, excluding columns that do not contain any of `labels`.
%
%     `X` is notionally a factor matrix or table whose columns constitute
%     variables and rows observations. Practically, the elements of `X`
%     should be distint across columns -- i.e., each unique element should 
%     reside in one and only one of its columns -- but this is not mandated
%     nor enforced.
%
%     ind = findrows( X, labels, mask ) for the logical or numeric index
%     vector `mask` operates on `X(mask, :)` rows and returns indices that
%     are a subset of `mask`. `findrows` always returns numeric indices,
%     regardless of the class of `mask`.
%
%     //  EX 1
%     X = [[1, 2, 3]; [1, 4, 5]; [1, 4, 5]]
%     i = findrows( X, [1, 4] ) % i = [2; 3]
%     % The labels 1 and 4 are considered in turn. The label 1 matches 
%     % the first through third rows of the first column of X. The label 4
%     % matches the second and third row of the second column of X. The 
%     % result `i` is equivalent to intersect( 1:3, 2:3 ). The third column 
%     % of `X` is ignored because it does not contain any of the query labels.
%
%     //  EX 2
%     X = [[1, 2, 3]; [1, 4, 5]; [1, 4, 5]]
%     i = findrows( X, [1, 4], 1:2 )  % i = 2
%     % Same as above, except that the mask `1:2` is given so that only 
%     % the first two rows of `X` are searched; the result is the subset of
%     % the mask that is matched, i.e., 2.
%
%     See also findeach, findeachv, retaineach, fcat/find

if ( isa(X, 'fcat') )
  ind = find( X, labels, varargin{:} );
  return
else
  validateattributes( X, {'table', 'string', 'numeric', 'categorical', 'cell'} ...
    , {'2d'}, mfilename, 'X' );
end

has_mask = nargin > 2;
if ( has_mask )
  mask = varargin{1};
  if ( islogical(mask) )
    mask = find( mask );
  end
end

if ( iscell(X) || isa(X, 'categorical') || isstring(X) || (isa(X, 'table') && ischar(labels)) )
  labels = cellstr( labels );
end

if ( isempty(labels) )
  ind = [];
  return
end

if ( has_mask )
  tmp = false( numel(mask), size(X, 2) );
else
  tmp = false( size(X) );
end

any_matched = false( 1, size(X, 2) );

for i = 1:numel(labels)
  non_existent = true;

  for j = 1:size(X, 2)
    if ( isa(X, 'table') )
      if ( has_mask )
        match = ismember( X{mask, j}, labels(i) );
      else
        match = ismember( X{:, j}, labels(i) );
      end
    else
      if ( has_mask )
        match = ismember( X(mask, j), labels(i) );
      else
        match = ismember( X(:, j), labels(i) );
      end
    end

    any_match = any( match );
    tmp(:, j) = tmp(:, j) | match;
    any_matched(j) = any_matched(j) | any_match;

    if ( any_match )
      non_existent = false;
    end
  end
  
  if ( non_existent )
    ind = [];
    return
  end
end

ind = all( tmp(:, any_matched), 2 );
if ( has_mask )
  ind = mask(ind);
else
  ind = find( ind );
end

end