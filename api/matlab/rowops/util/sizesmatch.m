function tf = sizesmatch(varargin)

%   SIZESMATCH -- True if inputs have matching sizes in all dimensions.
%
%     See also joinsize, rowsmatch
%
%     IN:
%       - `varargin` (/any/)
%     OUT:
%       - `tf` (logical)

szs = cellfun( @size, varargin, 'un', 0 );
tf = isequal( szs{:} );

end