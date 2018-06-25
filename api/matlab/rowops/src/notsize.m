function sz = notsize(X, dim)

%   NOTSIZE -- Array size, except along dimension(s).
%
%     S = notsize( X, 1 ) returns the size of `X`, except along the first
%     dimension.
%
%     S = notsize( X, 1:2 ) returns the size of `X`, except along the first
%     and second dimensions.
%
%     IN:
%       - `X` (/any/)
%       - `dim` (double)
%     OUT:
%       - `sz` (double)

sz = size( X );
sz(dim) = [];

end