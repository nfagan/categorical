function axs = simplest_barsets(data, labels, pcats, xcats, gcats, varargin)

%   SIMPLEST_BARSETS -- Simple sets of bars with errors.
%
%     SIMPLEST_BARSETS( data, labels, pcats, xcats, gcats ) for the Mx1 
%     numeric vector `data`, MxN array `labels`, and vectors of column 
%     subscripts `pcats`, `xcats`, and `pcats` generates grouped bar plots 
%     from `data` in separate panels. 
%   
%     Panels are drawn according to the unique rows of `labels(:, pcats)` 
%     columns. Within each panel, separate sets of bars are drawn from 
%     `labels(:, xcats)` unique rows, with a bar for each `labels(:, gcats)`
%     unique rows.
%
%     Each bar is an average within a given subset, and errors lines show
%     +/- standard deviation.
%
%     SIMPLEST_BARSETS(..., 'summary_func', sfunc) and
%     SIMPLEST_BARSETS(..., 'error_func', efunc) use `sfunc` and
%     `efunc` to compute summary statistics and error statistics,
%     respectively. By default, `sfunc` is @mean and `efunc` is @std.
%
%     SIMPLEST_BARSETS(..., 'mask', mask) for `mask`, a logical or
%     numeric index vector, restricts the plotted data and labels to the
%     subset of `mask` rows.
%
%     axs = SIMPLEST_BARSETS(...) returns an array of axis handles, with
%     one element for each panel.
%
%     //  EX 1.
%     f = fcat.example();
%     d = fcat.example( 'smalldata' );
%     % Create a panel for each 'dose', a bar for each 'monkey', and a set
%     % of bars for each 'roi'
%     axs = plots.simplest_barsets( d, f, 'dose', 'roi', 'monkey' );
%
%     //  EX 2.
%     f = fcat.example();
%     d = fcat.example( 'smalldata' );
%     % Create a panel for each 'image', a bar for each 'monkey', and a set
%     % of bars for each ('dose x 'roi').
%     % use `mask` to only plot 'outdoors' and 'scrambled' images
%     axs = plots.simplest_barsets( d, f, 'image', {'dose', 'roi'}, 'monkey' ...
%       , 'mask',find(f, {'outdoors', 'scrambled'}) );
%
%     See also rowsets, findeach, fcat, plots.lines, plots.nest3

assert_rowsmatch( data, labels );

defaults = struct();
defaults.summary_func = @mean;
defaults.error_func = @std;
defaults.mask = rowmask( data );
defaults.preserve = [];
defaults.cla = true;
params = shared_utils.general.parsestruct( defaults, varargin );

[I, id, C] = rowsets( 3, labels, pcats, xcats, gcats ...
  , 'mask', params.mask ...
  , 'preserve', params.preserve ...
);

[ip, lp] = plots.nest3( id, I, plots.cellstr_join(C) );
means = nested_rowifun( params.summary_func, ip, data );
errs = nested_rowifun( params.error_func, ip, data );
axs = plots.simple_barsets( means, errs, lp, 'cla', params.cla );

end