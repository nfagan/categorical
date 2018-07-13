function v = rowzeros(n, varargin)

%   ROWZEROS -- Row-vector of zeros.
%
%     v = rowzeros( M ) returns an `M`x1 row vector of zeros.
%
%     v = rowzeros( ..., 'like', A ) returns a vector of zeros with the
%     same data type, sparsity, and complexity (real or complex) as the 
%     numeric variable `A`.
%
%     See also rowop, rowones
%
%     IN:
%       - `n` (double)
%     OUT:
%       - `v` (double)

rowrep_validate( n );
v = zeros( n, 1, varargin{:} );

end