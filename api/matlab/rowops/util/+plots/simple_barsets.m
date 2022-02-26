function [axs, hs, xps] = simple_barsets(ms, errs, ls, varargin)

%   SIMPLE_BARSETS -- Sets of bars with errors.
%
%     SIMPLE_BARSETS(ms, errs, ls) for the Mx1 cell array of matrices `ms`, 
%     Mx1 cell array of matrices `errs`, and Mx3 cell array of labels `ls`
%     makes a grouped bar plot for each row of `ms`, `errs`, and `ls`, in 
%     a separate axis.
%
%     Each element of `ms` is a PxQ matrix of P groups of Q bars. Each 
%     element of `errs` is a PxQ matrix of errors. Error lines drawn at 
%     each m +/- e for corresponding elements of `ms` and `errs`. Each
%     row of `ls` has three elements. The first element is a scalar label
%     titling the plot. The second element is a Px1 vector labeling the 
%     rows of the data matrix, and the third element is a Qx1 vector 
%     labeling the columns.
%
%     SIMPLE_BARSETS(..., 'name', value) specifies additional name-value
%     paired inputs. In particular:
%     SIMPLE_BARSETS( ..., 'cla', tf ); for logical scalar `tf` is true if an
%       axis should be cleared prior to plotting. Default is true.
%     SIMPLE_BARSETS( ..., 'error_width', ew ); for scalar `ew` specifies
%       the width of error lines. Default is 0.1.
%
%     axs = SIMPLE_BARSETS(...) returns handles to the created axes.
%     [..., hs] = SIMPLE_BARSETS(...) also returns a cell array of handles
%     to the created bars.
%     [..., xps] = SIMPLE_BARSETS(...) also returns a cell array of x
%     locations of each bar.
%
%     //  EX
%     l1 = { {'my title'}, {'x1'}, {'group1', 'group2'} };
%     l2 = { {'my title2'}, {'x2'}, {'group1', 'group2'} };
%     L = [l1; l2];
%     M = { rand(1, 2); rand(1, 2) };
%     E = { rand(1, 2) * 0.1; rand(1, 2) * 0.1 };
%     plots.simple_barsets( M, E, L );
%
%     See also plots.bars, plots.barerrs, plots.nest3

defaults = struct();
defaults.cla = true;
defaults.error_width = 0.1;
params = shared_utils.general.parsestruct( defaults, varargin );

assert( isequal(size(ms), size(errs)) );
assert_rowsmatch( ms, ls );

axs = gobjects( size(ms) );
hs = cell( size(ms) );
xps = cell( size(ms) );

for i = 1:numel(ms)
  ax = plots.panel( numel(ms), i, params.cla );  
  [hs{i}, xp] = plots.bars( ax, ms{i}, ls{i, 2}, ls{i, 3}, ls{i, 1} );
  plots.holdon( ax );
  plots.barerrs( ax, xp, ms{i}, errs{i}, params.error_width );
  axs(i) = ax;
  xps{i} = xp;
end

end