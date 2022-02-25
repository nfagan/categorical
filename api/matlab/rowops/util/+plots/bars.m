function [h, x] = bars(ax, m, xl, gl, pl)

%   BARS -- Bar plots.
%
%     BARS( ax, m, xl, gl, pl ) plots a grouped bar plot using data in the 
%     matrix `m`. `m` is an MxN matrix of M groups of N bars. `xl` is a 
%     string-like vector with M elements labeling the x-axis. `gl` is a 
%     string-like vector with N elements labeling the bars, and for which 
%     a legend is created. `pl` is a string-like scalar titling the plot. 
%     `ax` is a handle to the axis in which to plot.
%
%     h = BARS(...) returns an array of handles to the bar objects.
%
%     [..., x] = BARS(...) also returns `x`, a matrix the same size as `m`
%     giving the x coordinate of the center of each bar, and corresponding
%     to `m`.
%
%     //  EX
%     h = plots.bars( gca, rand(2, 4) ...
%       , {'x0', 'x1'}, {'c', 'd', 'e', 'f'}, 'my title')
%
%     See also rowsets, plots.nest3, plots.barerrs

ntick = size( m, 1 );
if ( ntick == 1 )
  m(end+1, :) = nan;
end

h = bar( ax, m );
legend( h, gl, 'autoupdate', false );
set( ax, 'xtick', 1:ntick );
set( ax, 'xticklabel', xl );
xlim( ax, [0, ntick+1] );
set( ax, 'xticklabelrotation', 60 );
title( ax, pl );

if ( nargout > 1 )
  x = arrayfun( @(x) x.XOffset, h ) + 1;
  for i = 2:size(m, 1)
    x(end+1, :) = x(1, :) + (i - 1);
  end
end

end