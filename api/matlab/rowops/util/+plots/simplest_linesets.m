function [axs, hs] = simplest_linesets(x, data, PI, PL, varargin)

%   SIMPLEST_LINESETS -- Simple sets of lines with errors.
%
%     SIMPLEST_LINESETS( x, data, PI, PL ) for the 1xN vector `x`, 
%     MxN numeric matrix `data`, Px1 cell array of indices `PI` and 
%     Px2 cell array of labels `PL` generates lines of `data` plotted 
%     against `x` in separate panels.
%   
%     A separate panel is made for each element of `PI`, with separate
%     summary and error lines for each subset of `data` given by the indices 
%     in `PI{i}` (for the i-th element of `PI`).
%
%     Each line is an average within a given subset, and errors lines show
%     +/- standard deviation.
%
%     SIMPLEST_LINESETS(..., 'summary_func', sfunc) and
%     SIMPLEST_LINESETS(..., 'error_func', efunc) use `sfunc` and
%     `efunc` to compute summary statistics and error statistics,
%     respectively. By default, `sfunc` is @mean and `efunc` is @std.
%
%     axs = SIMPLEST_LINESETS(...) returns an array of axis handles, with
%     one element for each panel.
%
%     See also rowsets, plots.simplest_barsets, fcat, plots.lines,
%       plots.lineerrs, plots.nest2

assert_rowsmatch( PI, PL );

defaults = struct();
defaults.summary_func = @(x) mean(x, 1);
defaults.error_func = @(x) std(x, [], 1);
defaults.smooth_func = @identity;
defaults.cla = true;
params = shared_utils.general.parsestruct( defaults, varargin );

smooth = params.smooth_func;

ms = eachcell( smooth, nest_apply(params.summary_func, data, PI) );
errs = eachcell( smooth, nest_apply(params.error_func, data, PI) );
axs = plots.panels( numel(ms), params.cla );
hs = plots.simple_linesets( axs, x, ms, errs, PL );

end

function d = nest_apply(f, data, I)
d = eachcell( @(i) cate1(rowifun(f, i, data, 'un', 0)), I );
end