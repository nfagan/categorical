function [axs, hs] = simple_linesets(x, ms, errs, ls, varargin)

%   SIMPLE_LINESETS -- Sets of lines with errors.
%
%     SIMPLE_LINESETS(x, ms, errs, ls) for the vector `x`, Mx1 cell array 
%     of matrices `ms`, Mx1 cell array of matrices `errs`, and Mx2 cell 
%     array of labels `ls` makes a line plot for each row of `ms`, `errs`, 
%     and `ls`, in a separate axis.
%
%     Each element of `ms` and `errs` is a MxN matrix of `M` lines by `N`
%     values, with `N == numel(x)`. Error lines drawn for each row
%     m(i, :) +/- e(i, :) for corresponding rows within `ms` and `errs`. 
%     Each row of `ls` has two elements. The first element is a scalar 
%     label titling the plot. The second element is an Mx1 vector
%     labeling the rows of the data matrix, and from which a legend is
%     created.
%
%     SIMPLE_LINESETS(..., 'name', value) specifies additional name-value
%     paired inputs. In particular:
%     SIMPLE_LINESETS( ..., 'cla', tf ); for logical scalar `tf` is true if 
%       an axis should be cleared prior to plotting. Default is true.
%
%     axs = SIMPLE_LINESETS(...) returns handles to the created axes.
%     [..., hs] = SIMPLE_LINESETS(...) also returns a cell array of handles
%     to the created lines.
%
%     //  EX
%     l1 = { {'my title'}, {'group1', 'group2'} };
%     l2 = { {'my title2'}, {'group1', 'group2'} };
%     L = [l1; l2];
%     M = { rand(2, 20); rand(2, 20) };
%     E = { rand(2, 20) * 0.1; rand(2, 20) * 0.1 };
%     x = linspace( -1, 1, 20 );
%     plots.simple_linesets( x, M, E, L );
%
%     See also plots.bars, plots.barerrs, plots.nest3, plots.lineerrs

defaults = struct();
defaults.cla = true;
params = shared_utils.general.parsestruct( defaults, varargin );

assert( isequal(size(ms), size(errs)) );
assert_rowsmatch( ms, ls );

axs = gobjects( size(ms) );
hs = cell( size(ms) );

for i = 1:numel(ms)
  ax = plots.panel( numel(ms), i, params.cla );  
  axs(i) = ax;
  hs{i} = plots.lines( ax, x, ms{i}, ls{i, 2}, ls{i, 1} );
  plots.holdon( ax );
  plots.lineerrs( ax, x, ms{i}, errs{i}, cat(1, hs{i}.Color) );
end

end