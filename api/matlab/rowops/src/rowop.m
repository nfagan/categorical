function new_data = rowop(data, I, func, uniform)

%   ROWOP -- Apply function to subsets of rows of data.
%
%     newdata = rowop( data, I, func ) applys `func` to each subset of rows
%     of `data` identified by an index in `I`. `I` is a cell array of
%     numeric indices or logicals. `newdata` is an MxNx ... array where 
%     `M` is equal to `numel(I)`.
%
%     newdata = rowop( ..., false ) indicates that the output of `func` is
%     non-uniform, i.e., potentially of multiple classes, or with a 
%     first-dimension size not equal to 1. In this case `newdata` is an 
%     Mx1 cell array.
%
%     IN:
%       - `data` (/T/)
%       - `I` (cell array of integers, cell array of logical)
%       - `func` (function_handle)
%     OUT:
%       - `data` (/T/)

if ( nargin < 4 )
  uniform = true;
else
  assert( isscalar(uniform) && isa(uniform, 'logical') ...
    , 'Fourth input must be a logical scalar; was "%s".', class(uniform) );
end

assert( isa(I, 'cell'), 'Second input must be cell array of indices.' );
assert( isa(func, 'function_handle'), 'Third input must be function_hande; was "%s".', class(func) );

if ( ~uniform )
  new_data = nonuniform_rowop( data, I, func );
  return;
end

if ( isnumeric(data) )
  new_data = numeric_rowop( data, I, func );
else
  new_data = generic_rowop( data, I, func );
end

end

function new_data = nonuniform_rowop(data, I, func)

n_inds = numel( I );
colons = repmat( {':'}, 1, ndims(data)-1 );

new_data = cell( n_inds, 1 );

for i = 1:n_inds
  new_data{i} = func( data(I{i}, colons{:}) );
end

end

function new_data = generic_rowop(data, I, func)

n_inds = numel( I );
colons = repmat( {':'}, 1, ndims(data)-1 );

new_data = data( [], colons{:} );

for i = 1:n_inds
  new_data(i, colons{:}) = func( data(I{i}, colons{:}) );
end

end

function new_data = numeric_rowop(data, I, func)

n_inds = numel( I );
all_sz = size( data );
new_sz = [ n_inds, all_sz(2:end) ];
colons = repmat( {':'}, 1, ndims(data)-1 );

new_data = zeros( new_sz, 'like', data );

for i = 1:n_inds
  new_data(i, colons{:}) = func( data(I{i}, colons{:}) );
end

end