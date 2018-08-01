function tf = rowsmatch(varargin)

%   ROWSMATCH -- True if arrays have the same number of rows.
%
%     See also rows, joinsize, sizesmatch
%
%     IN:
%       - `varargin` (/any/)
%     OUT:
%       - `tf` (logical)

narginchk( 2, Inf );

if ( nargin == 2 )
  tf = rows( varargin{1} ) == rows( varargin{2} );
  return
end

rws = cellfun( @rows, varargin, 'un', 0 );
tf = isequal( rws{:} );

end