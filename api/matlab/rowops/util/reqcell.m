function A = reqcell(A)

%   REQCELL -- Require cell.
%
%     B = reqcell( A ); returns a cell array `B` that is equal to `A`, if
%     `A` is a cell array, or else contains `A`.
%
%     See also cell
%
%     IN:
%       - `A` (/any/)
%     OUT:
%       - `B` (cell)

if ( ~iscell(A) ), A = { A }; end

end