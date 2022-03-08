function tf = contains(a, l, ignore_case)

%   CONTAINS -- True for elements containing substring.
%
%     tf = CONTAINS( a, s ) returns an array the same size as `a`
%     which is true for elements containing the string 's', treating `a`
%     as a string type. In particular, if `a` is numeric or categorical, 
%     it is converted to string, otherwise `a` must be string, a cell
%     array, or a table. If `a` is a table or cell array its elements are
%     converted to string and tested recursively.
%
%     tf = CONTAINS( ..., ignore_case ); matches strings independent of
%     case if `ignore_case` is true.
%
%     See also contains

validateattributes( a, {'table', 'numeric', 'string', 'cell', 'categorical', 'char'} ...
  , {}, mfilename, 'a' );

if ( nargin < 3 )
  ignore_case = false;
end

if ( iscellstr(a) || isstring(a) || ischar(a) )
  tf = contains( a, l, 'IgnoreCase', ignore_case );
  
elseif ( iscell(a) )
  tf = false( size(a) );
  for i = 1:numel(a)
    v = plots.contains( a{i}, l, ignore_case );
    tf(i) = any( v(:) );
  end  
  
elseif ( isa(a, 'categorical') || isnumeric(a) )
  tf = contains( string(a), l, 'IgnoreCase', ignore_case );
  
elseif ( istable(a) )
  tf = false( size(a) );
  for i = 1:size(a, 2)
    tf(:, i) = plots.contains( a{:, i}, l, ignore_case );
  end
  
else
  error( 'Unhandled type.' );  
end

end