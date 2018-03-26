x = cat_test_get_mat_categorical();
c = x.c;

%%

tic;
f = fcat.from( c, x.f );
toc;

%%

cs = cellstr( x.c );
tic;
categ = categorical( cs );
toc;

%%

addpath( '~/Documents/MATLAB/hannah_data/02222018/for_upload/' );
x = load( 'looking_duration.mat' );

%%
fs = fieldnames( x.looking_duration.labels );
m = cell( size(x.looking_duration.labels.(fs{1}), 1), numel(fs) );
for i = 1:numel(fs)
  m(:, i) = x.looking_duration.labels.(fs{i});
end

%%
tic;
f = fcat.from( m, fs );
toc;

%%

subset_cats = { 'images' };

tic;
[y, I] = keepeach( copy(f), subset_cats );
data = rowmean( x.looking_duration.data, I );
toc;

%%

tic; cont = Container( x.looking_duration.data, x.looking_duration.labels ); toc;

%%

tic;
B = each1d( cont, subset_cats, @rowops.mean );
toc;
