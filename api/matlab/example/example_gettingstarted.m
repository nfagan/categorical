x = cat_create();
cat_requirecat(x, 'hi');
cat_setcat(x, 'hi', {'hello', 'sup', 'sup2'});
cat_setcat(x, 'hi', {'hello', 'sup', 'sup2'});
cat_setcat(x, 'hi', {'hello', 'sup', 'sup2'});

%%

x = cat_create();
cat_requirecat(x, 'hi');
cat_requirecat(x, 'sup');

one_cat = repmat({'hello'}, 1e6, 1);
another_cat = repmat({'sup2'}, 1e6, 1);

cat_setcat(x, 'hi', one_cat);
cat_setcat(x, 'sup', another_cat);

%%
addpath(genpath('~/Documents/MATLAB/repositories/global'));
addpath('~/repositories/cpp/locator/api/matlab/');

%%
tic; [I, C] = cat_findallc( x, {'sup', 'hi'} ); toc;

%%

sp = SparseLabels.create( 'hi', one_cat, 'sup', another_cat );

%%

sp = repeat(get_labels(get_example_container()), 10);
[m, f] = label_mat( sp );

%%
tic;
z = cat_create();

for i = 1:numel(f)
    cat_requirecat(z, f{i});
    cat_setcat(z, f{i}, m(:, i));
end
toc;

%%
tic;
labs = labeler.from( sp );
toc;

%%

tic;

[I, C] = findall( labs );
C = maplabs( labs, C );

toc;

%%

tic;
[I1, C1] = cat_findallc(z, f);
C1 = reshape(C1, numel(f), numel(C1)/numel(f));
toc;

%%
addpath( '~/Documents/MATLAB/hannah_data/02222018/for_upload/' );
x = load( 'looking_duration.mat' );
x = x.looking_duration.labels;

%%
sp = SparseLabels( x );
labs = labeler.from( x );

%%

tic;
z = cat_create();

fs = fieldnames( x );

for i = 1:numel(fs)
    cat_requirecat(z, fs{i});
    cat_setcat(z, fs{i}, x.(fs{i}));
end
toc;
%%
tic;
[I1, C1] = cat_findallc(z, fs);
C1 = reshape(C1, numel(fs), numel(C1)/numel(fs));
toc;
