function axs = simplest_barsets(data, labels, pcats, xcats, gcats, varargin)

%   SIMPLEST_BARSETS -- Simple sets of bars with errors.
%
%     SIMPLEST_BARSETS( data, labels, pcats, xcats, gcats ) for the Mx1 
%     numeric vector `data`, MxN array `labels`, and vectors of column 
%     subscripts `pcats`, `xcats`, and `gcats` generates grouped bar plots 
%     from `data` in separate panels. 
%   
%     A separate panel is made for each unique row of `labels(:, pcats)` 
%     columns. Within each panel, separate sets of bars are drawn for each
%     unique row in `labels(:, xcats)` columns, with a separate bar for
%     each unique row in `labels(:, gcats)` columns.
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
defaults.color_func = @jet;
defaults.mask = rowmask( data );
defaults.preserve = [];
defaults.preserve_masked = [];
defaults.cla = true;
defaults.add_points = false;
defaults.points_are = [];
params = shared_utils.general.parsestruct( defaults, varargin );

[I, id, C] = rowsets( 4, labels, pcats, xcats, gcats, params.points_are ...
  , 'mask', params.mask ...
  , 'preserve', params.preserve ...
  , 'preserve_masked', params.preserve_masked ...
);

L = plots.cellstr_join( C );
[ip, lp, ii] = plots.nest3( id, I, L );
mus = nested_rowifun( params.summary_func, ip, data );
errs = nested_rowifun( params.error_func, ip, data );
[axs, ~, xs] = plots.simple_barsets( mus, errs, lp, 'cla', params.cla );

if ( params.add_points )  
  colors = params.color_func( numel(unique(id(:, 4))) );
  plots.holdon( axs );
  for i = 1:numel(ip)
    [sx, sy] = plots.extract_points( ip{i}, xs{i}, data );
    si = cate( 1, ii{i} );
    plots.points( axs(i), sx, sy, L(si, 4), colors(id(si, 4), :) );
  end
end

end