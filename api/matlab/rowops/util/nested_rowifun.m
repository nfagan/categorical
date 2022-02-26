function o = nested_rowifun(f, is, d, varargin)

%   NESTED_ROWIFUN -- Apply function to subsets of rows, for nested subsets.
%
%     o = nested_rowifun( f, I, d ) for the function_handle `f`, cell array 
%     of cell arrays `I`, and data `d` calls `rowifun( f, index, d )` for 
%     each `index` in `I`, and stores the results in the cell array `o`.
%
%     See also rowifun

o = cellfun( @(x) rowifun(f, x, d, varargin{:}), is, 'un', 0 );

end