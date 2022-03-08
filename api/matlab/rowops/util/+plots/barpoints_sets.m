function hs = barpoints_sets(axs, data, id, L, xs, ip, ii, varargin)

%   BARPOINTS_SETS -- Scatter atop bar plots in multiple panels.
%
%     BARPOINTS_SETS( axs, data, id, L, xs, PI, II ) scatters elements of
%     `data` against x coordinates in `xs` separately for each element of
%     `xs`.
%
%     EX //
%
%     f = fcat.example(); d = fcat.example( 'smalldata' );
%     [I, id, C] = rowsets( 3, f, 'roi', 'image', 'dose' ...
%       , 'mask', find(f, {'outdoors', 'scrambled'}) );
%     L = plots.cellstr_join( C );
%     [PI, PL, II] = plots.nest3( id, I, L );
%     axs = plots.holdon( plots.cla(plots.panels(numel(PI))) );
%     means = nested_rowifun( @mean, PI, d );
%     [~, xs] = plots.simple_barsets( axs, means, [], PL );
%     plots.barpoints_sets( axs, d, id(:, 3), L(:, 3), xs, PI, II );
%
%     See also plots.nest3, plots.simple_barsets

assert_rowsmatch( id, L );
assert( isequal(size(xs), size(ip), size(ii)), 'Input sizes do not correspond.' );

defaults.color_func = @hsv;
params = shared_utils.general.parsestruct( defaults, varargin );

colors = params.color_func( numel(unique(id)) );
hs = cell( size(ip) );
for i = 1:numel(ip)
  si = cate1( ii{i} );
  hs{i} = plots.barpoints( ...
    axs(i), data, xs{i}, ip{i}, L(si), colors(id(si), :) );
end

end