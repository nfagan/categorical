f = fcat.example( 'large' );
dat = fcat.example( 'largedata' );

%%

[x, I] = keepeach( f', setdiff(getcats(f), 'trials') );

%%  

tic;
means = rowmean( dat, I );
devs = rowstd( dat, I );
toc;

tic;
eq_means = rowop( dat, I, @mean );
eq_devs = rowop( dat, I, @std );
toc;

assert( isequaln(means, eq_means) && isequaln(devs, eq_devs) );

%%

