function out = uint64_cell(varargin)

%   UINT64_CELL -- Convert to cell array of uint64.
%
%     b = uint64_cell( a ) converts each element of the cell array `a` to
%     uint64, and returns a cell array `b`. Entries of `a` must be numeric
%     or convertible to uint64.
%
%     b = uint64_cell( in1, in2, ... inN ) converts each array `in1` to 
%     `inN` to uint64, and gathers the arrays in the cell array `b`.
%
%     See also uint64

narginchk( 1, inf );

if ( iscell(varargin{1}) )
  if ( nargin > 1 )
    error( 'Only 1 input allowed if first input is a cell array.' );
  end
  
  out = cellfun( @uint64, varargin{1}, 'un', 0 );
else
  out = cellfun( @uint64, varargin, 'un', 0 );
end

end