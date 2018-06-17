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

prune( labs );

rows = { 'image', 'monkey' };
cols = { 'dose' };

[t, rc] = tabular( labs, rows, cols );

means = cellfun( @(x) mean(egdat(x)), t );

tbl = fcat.table( means, rc{:} )

%%  concatenate cell matrices and display as single table

N = size( t, 1 );

rlabs = rc{1}';
clabs = rc{2}';

addcat( repmat(rlabs, 2), 'measure' );
setcat( rlabs, 'measure', 'mean', 1:N );
setcat( rlabs, 'measure', 'std', N+1:N*2 );

means = cellfun( @(x) mean(egdat(x)), t, 'un', false );
devs = cellfun( @(x) std(egdat(x)), t, 'un', false );

tbl2 = fcat.table( [means; devs], rlabs, clabs )