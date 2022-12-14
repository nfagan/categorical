function c = color(n, i, f)

%   COLOR -- Evaluate a colormap function at a given index.
%
%     c = plots.color( n, i, f ); calls `f(n)` to generate a color map
%     matrix with `n` rows and 3 columns, then returns the `i`-th row. `f` is
%     a function handle and `n` and `i` are scalar integers.
%
%     c = plots.color( n, i ); uses `@hsv` for `f`.
%
%     See also plots.simple2, plots.bars, plots.panels

if ( nargin < 3 )
  f = @hsv;
end

m = f( n );
c = m(i, :);

end