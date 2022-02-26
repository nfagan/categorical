function axs = simplest_linesets(x, data, labels, pcats, gcats, varargin)

%   SIMPLEST_LINESETS -- Simple sets of lines with errors.
%
%     SIMPLEST_LINESETS( x, data, labels, pcats, gcats ) for the 1xN vector 
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

assert_rowsmatch( data, labels );

defaults = struct();
defaults.summary_func = @(x) mean(x, 1);
defaults.error_func = @(x) std(x, 1);
defaults.mask = rowmask( data );
defaults.preserve = [];
defaults.cla = true;
params = shared_utils.general.parsestruct( defaults, varargin );

[I, id, C] = rowsets( 2, labels, pcats, gcats ...
  , 'mask', params.mask ...
  , 'preserve', params.preserve ...
);

[ip, lp] = plots.nest2( id, I, plots.cellstr_join(C) );
ms = cellfun( @cell2mat, nested_rowifun(params.summary_func, ip, data, 'un', 0), 'un', 0 );
errs = cellfun( @cell2mat, nested_rowifun(params.error_func, ip, data, 'un', 0), 'un', 0 );
axs = plots.simple_linesets( x, ms, errs, lp, 'cla', params.cla );

end