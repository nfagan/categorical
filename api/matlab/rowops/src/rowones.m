function v = rowones(n, varargin)

%   ROWONES -- Row-vector of ones.
%
%     v = rowones( M ) returns an `M`x1 row vector of ones.
%
%     v = rowones( ..., 'like', A ) returns a vector of ones with the
%     same data type, sparsity, and complexity (real or complex) as the 
%     numeric variable `A`.
%
%     See also rowop, rowzeros
%
%     IN:
%       - `n` (double)
%     OUT:
%       - `v` (double)

rowrep_validate( n );
v = ones( n, 1, varargin{:} );

end