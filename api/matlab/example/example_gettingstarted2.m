x = Categorical();
requirecat( x, 'hi' );
setcat( x, 'hi', {'hello', 'sup', 'sup2'} );
%%
x = Categorical();

requirecat( x, 'hi' );
requirecat( x, 'sup' );

one_cat = repmat({'hello'}, 1e6, 1);
another_cat = repmat({'sup2'}, 1e6, 1);

setcat( x, 'hi', one_cat );
setcat( x, 'sup', another_cat );

%%
addpath(genpath('~/Documents/MATLAB/repositories/global'));
addpath('~/repositories/cpp/locator/api/matlab/');

%%
addpath( '~/Documents/MATLAB/hannah_data/02222018/for_upload/' );
x = load( 'looking_duration.mat' );
x = x.looking_duration.labels;
%%
sp = SparseLabels( x );
[m, f] = label_mat( sp );

%%

x = Categorical();

for i = 1:size(m, 2)
  requirecat( x, f{i} );
  setcat( x, f{i}, m(:, i) );
end

%%
tic; [I, C] = findall( x ); toc;

tic; I = findall(x); toc;

%%

sp = SparseLabels.create( 'hi', one_cat, 'sup', another_cat );


%%
tic;
labs = labeler.from( sp );
toc;

%%

tic;
y = keepeach( copy(labs), {'doses', 'images'} );
toc;

%%

tic;

[I, C] = findall( labs );
% C = maplabs( labs, C );

toc;

%%

categ = categorical( m );

%%
tic;
[I, C] = loc_findall_categorical( categ );
toc;