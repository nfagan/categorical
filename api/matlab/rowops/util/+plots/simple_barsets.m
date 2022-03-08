function [hs, xps] = simple_barsets(axs, ms, errs, ls, varargin)

%   SIMPLE_BARSETS -- Sets of bars with errors.
%
%     SIMPLE_BARSETS(axs, ms, errs, ls) for the Mx1 cell array of matrices 
%     `ms`, Mx1 cell array of matrices `errs`, Mx3 cell array of labels
%     `ls` and Mx1 vector of axes `axs` makes a grouped bar plot for each 
%     row of `ms`, `errs`, and `ls`, in a separate axis.
%
%     Each element of `ms` is a PxQ matrix of P groups of Q bars. Each 
%     element of `errs` is a PxQ matrix of errors. Error lines are drawn at 
%     each m +/- e for corresponding elements of `ms` and `errs`. Each
%     row of `ls` has three elements. The first element is a scalar label
%     titling the plot. The second element is a Px1 vector labeling the 
%     rows of the data matrix, and the third element is a Qx1 vector 
%     labeling the columns.
%
%     Alternatively, specify `errs` as the empty array ([]) to avoid
%     plotting error lines.
%
%     SIMPLE_BARSETS(..., 'name', value) specifies additional name-value
%     paired inputs. In particular:
%     SIMPLE_BARSETS( ..., 'error_width', ew ); for scalar `ew` specifies
%       the width of error lines. Default is 0.1.
%
%     hs = SIMPLE_BARSETS(...) also returns a cell array of handles to the 
%     created bars.
%     [..., xps] = SIMPLE_BARSETS(...) also returns a cell array of x
%     locations of each bar.
%
%     //  EX
%     l1 = { {'my title'}, {'x1'}, {'group1', 'group2'} };
%     l2 = { {'my title2'}, {'x2'}, {'group1', 'group2'} };
%     L = [l1; l2];
%     M = { rand(1, 2); rand(1, 2) };
%     E = { rand(1, 2) * 0.1; rand(1, 2) * 0.1 };
%     plots.simple_barsets( plots.cla(plots.panels(2)), M, E, L );
%
%     See also plots.bars, plots.barerrs, plots.nest3

defaults = struct();
defaults.error_width = 0.1;
params = shared_utils.general.parsestruct( defaults, varargin );

if ( ~isempty(errs) )
  assert( isequal(size(ms), size(errs)) );
end

assert_rowsmatch( ms, ls );

hs = cell( size(ms) );
xps = cell( size(ms) );

for i = 1:numel(ms)
  ax = axs(i);
  [hs{i}, xp] = plots.bars( ax, ms{i}, ls{i, 2}, ls{i, 3}, ls{i, 1} );
  plots.holdon( ax );
  if ( ~isempty(errs) )
    plots.barerrs( ax, xp, ms{i}, errs{i}, params.error_width );
  end
  axs(i) = ax;
  xps{i} = xp;
end

end