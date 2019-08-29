function new_data = rowwise(data, func, varargin)

%   ROWWISE -- Apply function to each row of data.
%
%     out_data = rowwise( in_data, func ); calls `func` separately for each
%     row in `in_data`, and concatenates the output in `out_data`.
%
%     See also rowop

new_data = rowop( data, arrayfun(@identity, 1:rows(data), 'un', 0), func, varargin{:} );

end