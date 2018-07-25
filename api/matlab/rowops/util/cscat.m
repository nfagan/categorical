function c = cscat(dim, varargin)

%   CSCAT -- cellstr concatenation.
%
%     c = cscat( DIM, A, B ) concatenates arrays `A` and `B` along `DIM`,
%     after ensuring that `A` and `B` are cell arrays of strings.
%
%     c = cscat( DIM, A, B, C, ... ) concatenates all inputs as above.
%
%     See also csunion, cshorzcat
%
%     IN:
%       - `varargin` (/any/)
%     OUT:
%       - `c` (cell array of strings)

try
  cs = cellfun( @(x) cellstr(x), varargin, 'un', 0 );
catch err
  throw( err );
end

c = cat( dim, cs{:} );

end