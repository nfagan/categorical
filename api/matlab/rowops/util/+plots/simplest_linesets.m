function axs = simplest_linesets(x, data, PI, PL, varargin)

%   SIMPLEST_LINESETS -- Simple sets of lines with errors.
%
%     SIMPLEST_LINESETS( x, data, I, id, L ) for the 1xN vector 
%     `x`, MxN numeric matrix `data`, MxQ array `labels`, and vectors of 
%     column subscripts `pcats` and `gcats` generates lines of `data` 
%     plotted against `x` in separate panels.
%   
%     A separate panel is made for each unique row of `labels(:, pcats)` 
%     columns. Within each panel, a separate line is drawn for each unique 
%     row of `labels(:, gcats)` columns.
%
%     Each line is an average within a given subset, and errors lines show
%     +/- standard deviation.
%
%     SIMPLEST_LINESETS(..., 'summary_func', sfunc) and
%     SIMPLEST_LINESETS(..., 'error_func', efunc) use `sfunc` and
%     `efunc` to compute summary statistics and error statistics,
%     respectively. By default, `sfunc` is @mean and `efunc` is @std.
%
%     SIMPLEST_LINESETS(..., 'mask', mask) for `mask`, a logical or
%     numeric index vector, restricts the plotted data and labels to the
%     subset of `mask` rows.
%
%     axs = SIMPLEST_LINESETS(...) returns an array of axis handles, with
%     one element for each panel.
%
%     See also rowsets, plots.simplest_barsets, fcat, plots.lines,
%       plots.lineerrs, plots.nest2

assert_rowsmatch( PI, PL );

defaults = struct();
defaults.summary_func = @(x) mean(x, 1);
defaults.error_func = @(x) std(x, 1);
defaults.smooth_func = @identity;
defaults.cla = true;
params = shared_utils.general.parsestruct( defaults, varargin );

smooth = params.smooth_func;

ms = eachcell( smooth, nest_apply(params.summary_func, data, PI) );
errs = eachcell( smooth, nest_apply(params.error_func, data, PI) );
axs = plots.panels( numel(ms), params.cla );
plots.simple_linesets( axs, x, ms, errs, PL );

end

function d = nest_apply(f, data, I)
d = eachcell( @(i) cate1(rowifun(f, i, data, 'un', 0)), I );
end