x = get_example_container();

x = extend( x, x, x );

y = fcat.from( x.labels );
data = x.data;
%%
addpath( '~/Documents/MATLAB/hannah_data/02222018/for_upload/' );
x = load( 'looking_duration.mat' );

sp = SparseLabels( x.looking_duration.labels );
y = fcat.from( sp );

x = Container( x.looking_duration.data, sp );

data = x.data;
%%
categ = categorical( y );

tic;
z = fcat.from( categ, getcats(y) );
toc;

%%

cats = { 'doses', 'genders' };

tic;
[y2, I] = keepeach( y(:), cats );
new_data = rowmean( data, I );
toc;

tic;
new_data = rowmean( data, I );
toc;
tic;
new_data2 = rowop( data, I, @(x) mean(x, 2), false );
toc;

%%

tic;
z = each1d( x, cats, @mean );
toc;
