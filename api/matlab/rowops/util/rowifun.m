function d = rowifun(f, I, data, varargin)

%   ROWIFUN -- Apply function to indexed subsets of rows of data.
%
%     d = ROWIFUN( f, I, data ) applies `f` to each subset of rows of
%     `data` given by `I`, a cell array of index vectors. `d` is an array
%     the same size as `I`. `f` must return scalar values that can be 
%     concatenated into a homogeoneous array. 
%
%     That is, d(i) = f(data(I{i}, :)) for 2D `data`, and 
%              d(i) = f(data(I{i}, :, :)) for 3D `data`, and so on for
%               `data` of arbitrary dimension.
%
%     d = ROWIFUN( ..., 'UniformOutput', tf ) for `tf` = false allows `f` 
%     to return values that cannot be concatenated into a homogeneous array.
%     In this case `d` is a cell array the same size as `I`.
%
%     //  EX
%     % d(1) is the mean of elements 1:10; d(2) is the mean of elements 80:100
%     X = rand( 100, 1 );
%     d = rowifun( @mean, {1:10, 80:100}, X );
%
%     See also rowsets, rowref

d = cellfun( @(x) f(rowref(data, x)), I, varargin{:} );

end