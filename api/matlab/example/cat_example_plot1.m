%%  load example data

fcat.addpath();
labs = fcat.example( 'small' );
data = fcat.example( 'smalldata' );

% for clarity, relabel esoteric image codes
replace( labs, 'ugin', 'neutral' );
replace( labs, 'ugit', 'threat' );

%%
% for each 'roi' and 'session', get the mean difference in looking duration
% to 'threat' and 'neutral' images. Plot the differences collapsed across
% subjects, or for each subject.

specificity = { 'roi', 'session' };
% specificity = { 'roi', 'monkey' };

[newlabs, I] = keepeach( labs', specificity );

diffs = zeros( size(I) );

img1 = 'threat';
img2 = 'neutral';

for i = 1:numel(I)
  ind1 = find( labs, img1, I{i} );
  ind2 = find( labs, img2, I{i} );
  
  mean1 = mean( data(ind1) );
  mean2 = mean( data(ind2) );
  
  diffs(i) = mean1 - mean2;
end

newlabs('image') = sprintf( '%s - %s', img1, img2 );

plt = labeled( diffs, newlabs );
pl = plotlabeled();

pl.summary_func = @plotlabeled.nanmean;
pl.error_func = @plotlabeled.nansem;
pl.x_order = { 'saline', 'low', 'high' };

pl.fig = figure(1);
bar( pl, plt, 'dose', 'roi', {'image', 'monkey'} );

pl.fig = figure(2);
bar( pl, plt, 'dose', 'roi', 'image' );