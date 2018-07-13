rowops_buildall();

%%

z1 = [10, 11, 12, 13];
z2 = [20, 30, 40, 50];

indices = { uint64([1, 2]), uint64(1) };

z = [z1; z2];

tic;
y = rowmean( z, indices );
toc;

tic;
n = numel( indices );
y2 = zeros( n, size(y, 2) );
for i = 1:n
  y2(i, :) = mean( z(indices{i}, :), 1 );
end
toc;
% y = mean( z, 1 );

assert( isequal(y, y2) );

%%
addpath( genpath('~/Documents/MATLAB/repositories/global') );
addpath( '~/repositories/cpp/locator' );

cont = get_example_container();
sp = cont.labels;
labs = labeler.from( sp );

%%
addpath( '~/Documents/MATLAB/hannah_data/02222018/for_upload/' );
x = load( 'looking_duration.mat' );
cont = Container( x.looking_duration.data, x.looking_duration.labels );
sp = cont.labels;
labs = labeler.from( sp );

%%

cats = unique( sp.categories );

tic;
in_data = cont.data;
[y, I] = keepeach( copy(labs), cats );
I = cellfun( @uint64, I, 'un', false );
out_data = rowmean( in_data, I );
toc;

%%

tic;
I = cellfun( @uint64, findall(labs, cats), 'un', false );
toc;

tic;
in_data_r = cont.data;
out_data_r = rowmean( in_data, I );
toc;

tic;
n_inds = numel(I);
in_data = cont.data;
cols = size( in_data, 2 );
out_data = zeros( n_inds, cols );
for i = 1:n_inds
  out_data(i, :) = mean( in_data(I{i}, :), 1 );
end
toc;

assert( isequal(out_data_r, out_data) );




