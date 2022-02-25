function h = lines(ax, x, m, gl, pl)

%   LINES -- Line plots.
%
%     LINES( ax, x, m, gl, pl ) for the vector `x` with N elements and MxN
%     matrix `m` plots a line against `x` for each row of `m`. `gl` is a
%     string-like vector with M elements identiying each line, and for
%     which a legend is created. `pl` is a string-like scalar titling the
%     plot. `ax` is a handle to the axis in which to plot.
%
%     h = LINES(...) returns an array of handles to the plotted lines.
%
%     See also plots.prepare2, plots.bars

assert( numel(x) == size(m, 2) ...
  , 'X must be a vector corresponding to the columns of data.' );

h = plot( ax, x(:)', m' );
legend( h, gl, 'autoupdate', false );
title( ax, pl );

end