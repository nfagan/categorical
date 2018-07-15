eglabs = fcat.example( 'small');
egdat = fcat.example( 'smalldata' );

%%
% Construct cell matrix of indices whose rows are combinations of 'image'
% and 'monkey', and whose columns are combinations of 'dose'. Take a mean
% for each cell, and create a table.

labs = eglabs';
dat = egdat;

[~, I] = only( labs, {'ubdn', 'ugit'} );
dat = dat(I);

rows = { 'image', 'monkey' };
cols = { 'dose' };

[t, rc] = tabular( labs, rows, cols );

means = reshape( rowmean(egdat, t), size(t) );

tbl = fcat.table( means, rc{:} )

%%  concatenate cell matrices and display as single table

rlabs = rc{1}';
clabs = rc{2}';

addcat( rlabs, 'measure' );
repset( rlabs, 'measure', {'mean', 'std'} );

means = reshape( rowmean(egdat, t), size(t) );
devs = reshape( rowstd(egdat, t), size(t) );

tbl2 = fcat.table( [means; devs], rlabs, clabs )