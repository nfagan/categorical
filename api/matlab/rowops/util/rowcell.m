function c = rowcell(n)

%   ROWCELL -- Row-vector cell array.
%
%     c = rowcell( `M` ) returns an `M`x1 empty cell array.
%
%     IN:
%       - `n` (double)
%     OUT:
%       - `c` (cell)

rowrep_validate( n );
c = cell( n, 1 );

end