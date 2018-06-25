function cs = colons(n)

%   COLONS -- N-length vector of colons.
%
%     cs = colons( N ) is the same as repmat( {':'}, 1, N ), but is
%     generally much faster.
%
%     colons( 1 ) returns {':'}.
%     colons( 2 ) returns {':', ':'}.
%
%     IN:
%       - `n` (double)
%     OUT:
%       - `cs` (cell array of strings)

c = {':'};
cs = c(ones(1, n));

end