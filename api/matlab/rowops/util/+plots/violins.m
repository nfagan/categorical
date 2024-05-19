function axs = violins(data, I, id, L, varargin)

%   VIOLINS -- Grouped violin plots.
%
%     See also plots.panels, plots.simplest_barsets

defaults = struct();
defaults.panel_shape = [];

params = shared_utils.general.parsestruct( defaults, varargin );

[PI, PL] = plots.nest2( id, I, L );

shape = numel( PI );
if ( ~isempty(params.panel_shape) )
  shape = params.panel_shape;
end

axs = plots.panels( shape );
for i = 1:numel(PI)
  [g, v] = ungroupi( PI{i} );
  gl = PL{i, 2}(g);
  axes( axs(i) );
  violinplot( data(v), gl );
  title( axs(i), PL{i, 1} );
end

end