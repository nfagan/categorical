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

C = cellfun( @(x) char(strjoin(string(x), jc)), X, 'un', 0 );

end