fcat.addpath();
x = fcat.example( 'small' );
data = fcat.example( 'smalldata' );

%%

[y, I] = keepeach( x', {'roi', 'session'} );

diffs = zeros( size(I) );

for i = 1:numel(I)
  ugin_ind = find( x, 'ugin', I{i} );
  ugit_ind = find( x, 'ugit', I{i} );
  
  ugin = mean( data(ugin_ind) );
  ugit = mean( data(ugit_ind) );
  
  diffs(i) = ugin - ugit;
end

y('image') = 'ugin - ugit';

plt = labeled( diffs, y );
pl = plotlabeled();

pl.summary_func = @plotlabeled.nanmean;
pl.error_func = @plotlabeled.nansem;
pl.x_order = { 'saline', 'low', 'high' };

pl.fig = figure(1);
bar( pl, plt, 'dose', 'roi', {'image', 'monkey'} );

pl.fig = figure(2);
bar( pl, plt, 'dose', 'roi', 'image' );