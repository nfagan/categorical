function C = cellstr_join(X, jc)

%   CELLSTR_JOIN -- Convert to cell array of joined strings.
%
%     c = CELLSTR_JOIN( X ) for the numeric, logical, char, or string array
%     `X` returns a scalar cell array of strings `c`. Elements of `X` are 
%     converted to string and then joined by the pattern ' | ' to produce a 
%     scalar string.
%
%     c = CELLSTR_JOIN( T ) for the table `T` works as above, converting 
%     all elements in all rows and columns of `T` to string and joining
%     them to produce a scalar cell array of strings.
%
%     c = CELLSTR_JOIN( C ) for the cell array `C` independently converts 
%     each element of `C` to string as above, so that the output is a cell
%     array of strings the same size as `C`. Elements of `C` that are
%     cell-arrays are visited recursively to produce a scalar string, so
%     that the final output `c` is always a cell array of strings (as
%     opposed to e.g. a cell array of cell arrays of strings).
%
%     c = CELLSTR_JOIN( ..., jc ) uses the pattern `jc` instead of ' | ' to 
%     join the string arrays.
%
%     //  EX1
%     plots.cellstr_join( {1:3, {'a', 'b'}, table(1)} )
%     
%     //  EX2
%     plots.cellstr_join( 1:3 )
%
%     See also string

if ( nargin < 2 )
  jc = ' | ';
end

if ( ~iscell(X) )
  X = { X };
end

C = cellfun( @(x) char(strjoin(to_string(x, jc), jc)), X, 'un', 0 );

end

function s = to_string(element, jc)

if ( istable(element) )
  try
    s = strings( size(element, 1), size(element, 2) );
    for i = 1:size(element, 2)
      s(:, i) = string( element{:, i} );
    end
    s = s(:);
  catch err
    throw( err );
  end
  
elseif ( iscell(element) )
  s = cellfun( @(x) strjoin(to_string(x, jc), jc), element );
  
else
  s = string( element );
end

end