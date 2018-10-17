function p = pnz(data)

%   PNZ -- Proportion non-zero elements.
%
%     p = pnz( DATA ); returns the fraction of the number of elements in 
%     `DATA` that are non-zero.
%
%     See also nnz
%
%     IN:
%       - `data` (/T/)
%     OUT:
%       - `p` (double)

p = nnz( data ) / numel( data );

end