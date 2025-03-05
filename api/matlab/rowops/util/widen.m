function [t, I] = widen(T, vars, un)

%   WIDEN -- Stack select variables into columns.
%
%     y = widen( T, variables ); "widens" the `variables` in the table `T`
%     by stacking their values into columns based on groups formed by 
%     remaining table variables.
%
%     y = widen( T, variables, uniform ); for the flag `uniform` specifies 
%     whether `variables` can be concatenated into a homogeneous array 
%     after forming groups by remaining table variables. If false, then 
%     `variables` are cell arrays in `y`. The flag equivalently specifies
%     whether all groups have the same number of elements. Default is true.
%
%     EX //
%
%     x = [1:5, 1:5]';
%     y = [rand(5, 1); rand(5, 1)];
%     g = [ strings(5, 1) + "a"; strings(5, 1) + "b"];
%     t = table( x, y, g )
%     % arrange scalar x's and y's into vectors, grouped by the remaining
%     % variable g
%     y = widen( t, {'x', 'y'} )
%
%     See also summarize_within, findeach, rowsets, groupi, splitapply

if ( nargin < 3 || isempty(un) ), un = true; end

vars = string( vars );
[I, t] = rowgroups( T(:, setdiff(T.Properties.VariableNames, vars)) );

for i = 1:numel(vars)
  v = cellfun( @(x) reshape_var(T.(vars(i)), x), I, 'un', 0 );
  if ( un ), v = cate1( v ); end
  t.(vars(i)) = v;
end

function dv = reshape_var(v, i)
  clns = colons( ndims(v) - 1 );
  subv = v(i, clns{:});
  dv = reshape( subv, [1, size(subv)] );
end

end