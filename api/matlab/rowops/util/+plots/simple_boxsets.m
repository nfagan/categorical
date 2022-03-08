function [hs, xs] = simple_boxsets(axs, data, I, L)

%   SIMPLE_BOXSETS -- Simple sets of boxplots.
%
%     SIMPLE_BOXSETS( axs, data, PI, PL ) creates boxplots from subsets of
%     `data`, with a separate panel for each element of `PI`, a cell array.
%     Each element of `PI` is a cell array of index vectors with one
%     element for each box (equivalently, group), drawing from `data`. `PL` 
%     is an Mx2 cell array of labels with one row for each element of `PI`. 
%     For each element PI{i}, PL{i, 1} is a vector of labels identifying the 
%     groups of PI{i}, and PL{i, 2} is a scalar label titling the panel.
%
%     // EX
%     f = fcat.example(); d = fcat.example( 'smalldata' );
%     [I, id, C] = rowsets( 2, f, 'dose', 'roi' );
%     [PI, PL] = plots.nest2( id, I, plots.cellstr_join(C) );
%     axs = plots.cla( plots.panels(numel(PI)) );
%     plots.simple_boxsets( axs, d, PI, PL );
%
%     See also plots.nest2, plots.box, plots.bars, plots.nest3

assert( numel(axs) == numel(I) && numel(I) == size(L, 1) ...
  , 'Input sizes do not correspond.' );

hs = cell( size(I) );
xs = cell( size(I) );

for i = 1:numel(axs)
  [hs{i}, xs{i}] = plots.box( axs(i), data, I{i}, L{i, 2}, L{i, 1} );
end

end