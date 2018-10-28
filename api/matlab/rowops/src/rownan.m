function v = rownan(n, varargin)

%   ROWNAN -- Row-vector of nan.
%
%     v = rownan( M ) returns an `M`x1 row vector of nan.
%
%     v = rownan( ..., 'like', A ) returns a vector of nan with the
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
v = nan( n, 1, varargin{:} );

end