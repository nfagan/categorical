function cs = colons(n)

%   COLONS -- N-length vector of colons.
%
%     cs = colons( N ) is the same as repmat( {':'}, 1, N ), but is
%     generally much faster.
%
%     colons( 1 ) returns {':'}.
%     colons( 2 ) returns {':', ':'}.
%
%     See also rowop, fcat
%
%     IN:
%       - `n` (double)
%     OUT:
%       - `cs` (cell array of strings)

c = {':'};

try
  cs = c(ones(1, n));
catch err
  throw( err );
end

end