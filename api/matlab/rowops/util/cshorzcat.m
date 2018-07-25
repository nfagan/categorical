function c = cshorzcat(varargin)

%   CSHORZCAT -- Horizontal concatenation, ensuring inputs are cellstr.
%
%     c = cshorzcat( A, B ) horizontally concatenates arrays `A` and `B`,
%     after ensuring that `A` and `B` are cell arrays of strings.
%
%     c = cshorzcat( A, B, C, ... ) concatenates all inputs as above.
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

c = horzcat( cs{:} );

end