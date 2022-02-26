function C = cellstr_join(X, jc)

%   CELLSTR_JOIN -- Convert to cell array of joined strings.
%
%     c = CELLSTR_JOIN( X ) for the cell array `X` produces a cell array of 
%     strings `c`. Each element of `X` is converted to string and then 
%     joined by the pattern ' | ' to produce a scalar string. Elements of 
%     `X` must be convertible to string.
%
%     c = CELLSTR_JOIN( ..., jc ) uses the pattern `jc` instead of ' | ' to 
%     join the string arrays.
%
%     See also string

if ( nargin < 2 )
  jc = ' | ';
end

C = cellfun( @(x) char(strjoin(to_string(x), jc)), X, 'un', 0 );

end

function s = to_string(element)

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
else
  s = string( element );
end

end