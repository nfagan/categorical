function hs = lineerrs(ax, x, ms, errs, colors)

%   LINEERRS -- Add error lines to line plots.
%
%     LINEERRS( ax, x, ms, errs, colors ) for vector `x` and matrices `ms` 
%     and `errs` of equal size plots error-lines `m` +/- `e` against `x` 
%     for corresponding rows of `ms` and `errs`. `ax` is a handle to the 
%     axis in which to plot. `colors` is an Mx3 matrix with the same number
%     of rows as `ms`, giving the color of each line.
%
%     See also plots.bars, plots.lines

assert( isequal(size(ms), size(errs)) ...
  , 'Summary and error line matrices do not correspond.' );
assert( numel(x) == size(ms, 2), 'X does not correspond to data.' );

hs = gobjects( size(ms, 1), 2 );

for i = 1:size(ms, 1)
  h0 = plot( ax, x, ms(i, :)-errs(i, :) );
  plots.holdon( ax );
  h1 = plot( ax, x, ms(i, :)+errs(i, :) );
  set( [h0, h1], 'color', colors(i, :) );
  hs(i, :) = [h0, h1];
end

end