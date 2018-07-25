function c = csvertcat(varargin)

%   CSVERTCAT -- cellstr vertical concatenation.
%
%     c = csvertcat( A, B ) horizontally concatenates arrays `A` and `B`,
%     after ensuring that `A` and `B` are cell arrays of strings.
%
%     c = csvertcat( A, B, C, ... ) concatenates all inputs as above.
%
%     See also cscat
%
%     IN:
%       - `varargin` (/any/)
%     OUT:
%       - `c` (cell array of strings)

c = cscat( 1, varargin{:} );

end