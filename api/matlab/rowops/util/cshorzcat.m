function c = cshorzcat(varargin)

%   CSHORZCAT -- cellstr horizontal concatenation.
%
%     c = cshorzcat( A, B ) horizontally concatenates arrays `A` and `B`,
%     after ensuring that `A` and `B` are cell arrays of strings.
%
%     c = cshorzcat( A, B, C, ... ) concatenates all inputs as above.
%
%     See also cscat
%
%     IN:
%       - `varargin` (/any/)
%     OUT:
%       - `c` (cell array of strings)

c = cscat( 2, varargin{:} );

end