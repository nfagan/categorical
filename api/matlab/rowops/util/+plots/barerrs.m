function h = barerrs(ax, xs, ms, errs, w)

%   BARERRS -- Add error lines to bar plots.
%
%     BARERRS( ax, xs, ms, errs ) for arrays `xs`, `ms` and `errs` of
%     equal size plots an error-line, `m` +/- `e` for each element `m` of 
%     `ms` and `e` of `errs`, at the corresponding `x` coordinate from 
%     `xs`. `ax` is a handle to the axis in which to plot.
%
%     BARERRS( ..., w ) specifies the width of the top and bottom error
%     lines. Default is 0.1.
%
%     h = BARERRS(...) returns a cell array the same size as `xs`. Each
%     element is a 1x3 array of handles to the plotted lines.
%
%     See also plots.bars

if ( nargin < 5 )
  w = 0.1;
end

assert( isequal(size(xs), size(ms), size(errs)) );

h = cell( size(xs) );
for i = 1:numel(xs)
  xc = xs(i);
  m = ms(i);
  e = errs(i);
  
  x0 = xc - w * 0.5;
  x1 = xc + w * 0.5;

  h0 = plot( ax, [xc, xc], [m - e, m + e] );
  h1 = plot( ax, [x0, x1], [m - e, m - e] );
  h2 = plot( ax, [x0, x1], [m + e, m + e] );
  hs = [ h0, h1, h2 ];
  set( hs, 'color', zeros(1, 3) );
  h{i} = hs;
end

end