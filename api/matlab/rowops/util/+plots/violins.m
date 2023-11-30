function axs = violins(data, I, id, L)

%   VIOLINS -- Grouped violin plots.
%
%     See also plots.panels, plots.simplest_barsets

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