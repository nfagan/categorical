function axs = violins(data, I, id, L)

%   VIOLINS -- Grouped violin plots.
%
%     plots.violins( data, I, id, L ) for the vector `data`, cell array of
%     index vectors `I`, matrix of `id`s, and matrix of labels `L`s with
%     the same number of rows, creates panels of violin plots separately
%     for groups of `data` defined by id(:, 1). Within a panel, groups of
%     violins are defined by id(:, 2).
%
%     This function depends on `violinplot`, available from the MathWorks
%     file exchange:
%
%     https://www.mathworks.com/matlabcentral/fileexchange/45134-violin-plot
%
%     See also plots.panels, plots.simplest_barsets, rowsets

[PI, PL] = plots.nest2( id, I, L );
axs = plots.panels( numel(PI) );
for i = 1:numel(PI)
  [g, v] = ungroupi( PI{i} );
  gl = PL{i, 2}(g);
  axes( axs(i) );
  violinplot( data(v), gl );
  title( axs(i), PL{i, 1} );
end

end