[I, C] = findall(x, 'rois');
%%
addpath( '~/Documents/MATLAB/hannah_data/02222018/for_upload/' );
addpath(genpath('~/Documents/MATLAB/repositories/global'));
x = load( 'looking_duration.mat' );
x = x.looking_duration.labels;

%%
sp = get_labels( get_example_container() );

%%
sp = SparseLabels( x );
%%
[m, f] = label_mat( sp );
%%

tic;
x = requirecat( Categorical(), f );
for i = 1:numel(f)
  setcat( x, f{i}, m(:, i) );
end
toc;

%%

C = Categorical();
cellfun( @(x) requirecat(C, x), unique(sp.categories), 'un', false );
tmp = Categorical();
cellfun( @(x) requirecat(tmp, x), unique(sp.categories), 'un', false );

sz = 1e3;

tic;
for i = 1:sz
  ind = randperm( size(m, 1), 1 );
  row = m(ind, :);
  for j = 1:numel(row)
    setcat( tmp, f{j}, row(j) );
  end
  append( C, tmp );
end
toc;

%%

C = Categorical();
cellfun( @(x) requirecat(C, x), unique(sp.categories), 'un', false );

sz = 1e3;

tic;
for i = 1:sz
  tmp = Categorical();
  cellfun( @(x) requirecat(tmp, x), unique(sp.categories), 'un', false );
  ind = randperm( size(m, 1), 1 );
  row = m(ind, :);
  for j = 1:numel(row)
    setcat( tmp, f{j}, row(j) );
  end
  append( C, tmp );
  delete( tmp );
end
toc;

%%

tmp = Categorical();
cellfun( @(x) requirecat(tmp, x), unique(sp.categories), 'un', false );
ind = randperm( size(m, 1), 1 );
row = m(ind, :);
for j = 1:numel(row)
  setcat( tmp, f{j}, row(j) );
end
%%
orig = tmp;

%%

tic;
C = categorical();
A = categorical();
for i = 1:sz
  ind = randperm( size(m, 1), 1 );
  row = m(ind, :);
  A(1, :) = row;
  C = [C; A];
end
toc;
