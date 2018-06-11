eglabs = fcat.example();
egdat = fcat.example( 'smalldata' );

%%

labs = eglabs';
dat = egdat;

[~, I] = only( labs, {'outdoors'} );
dat = dat(I);

prune( labs );

rows = { 'image', 'monkey' };
cols = { 'dose' };

[t, rc] = tabular( labs, rows, cols );

means = cellfun( @(x) mean(egdat(x)), t, 'un', false );
devs = cellfun( @(x) std(egdat(x)), t, 'un', false );

tbl = fcat.table( means, rc{:} )
% tbl = fcat.table( devs, rc{:} )