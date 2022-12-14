function axs = simple2(PI, PL, f)

%   SIMPLE2 -- Plot subsets using indices and labels with two levels of nesting.
%
%     plots.simple2( I, L, f ); applies the plotting function `f` to
%     subsets defined by `I` and `L`. `I` is a cell vector with one element
%     for each panel; each element is itself a cell vector with one element
%     for each subset. `PL` is a cell matrix with two columns and one row
%     for each panel (element of `I`). Elements in the first column of `PL`
%     are scalar string-like labels titling each panel. Elements in the
%     second column of `PL` label panel subsets; e.g., `PL{1, 2}` has the
%     same number of elements as `PI{1}`.
%
%     `f` is a handle to a function that receives four inputs: a handle to
%     the axis of the current panel, the full set of indices for the 
%     current panel `i` (i.e., `PI{i}`), the index of the current subset 
%     `j`, and the label of the current subset. `f` must return a handle
%     to a graphics object corresponding to the legend entry for that 
%     invocation of `f`.
%
%     For example, to plot a line, `f` could be:
%     @(ax, indices, i, label) plot(ax, data(indices{i}, :), 'displayname', label);
%
%     Ex 1. Line plots.
%
%     f = fcat.example();
%     d = rand( rows(f), 21 );  % random data corresponding to `f`
%     % panels are 'dose'; lines are 'roi'
%     [I, id, C] = rowsets( 2, f, 'dose', 'roi' );
%     [PI, PL] = plots.nest2( id, I, plots.cellstr_join(C) );
%     % callback plots an average across rows for the current subset of data
%     % given by `ind{i}` and returns a handle to the plotted line.
%     callback = @(ax, ind, i, label) plot(ax, mean(d(ind{i}, :)), 'displayname', label);
%     plots.simple2( PI, PL, callback );
%
%     See also plots.nest2

axs = plots.panels( numel(PI), true );

for i = 1:numel(axs)
  axes( axs(i) );
  hold( axs(i), 'on' );
  
  inds = PI{i};
  leg_hs = gobjects( numel(inds), 1 );
  
  for j = 1:numel(inds)
    leg_hs(j) = f( axs(i), inds, j, strrep(PL{i, 2}{j}, '_', ' ') );
  end
  
  legend( leg_hs );
  title( axs(i), strrep(PL{i, 1}, '_', ' ') );
end

end