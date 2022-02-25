function h = hist(ax, m, pl)

%   HIST -- Histogram.
%
%     HIST( ax, m, pl ) plots a histogram from the data in vector `m`. `pl`
%     is a string-like scalar titling the plot. `ax` is a handle to the 
%     axis in which to plot.
%
%     h = HIST(...) returns a handle to the histogram object.
%
%     See also plots.nest1, plots.bars, plots.lines

h = histogram( ax, m );
title( ax, pl );

end