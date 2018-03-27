x = labeled( rand(100, 1), fcat.with({'hi', 'hello'}, 1) );

%%

cont = get_example_container();
lab = labeled( cont.data, fcat.from(cont.labels) );

%%

tic;
data = getdata( lab );
B = labeled( 0, fcat.with(getcats(lab), 1) );
rebuilt = requirecat( labeled(), getcats(B) );

for i = 1:1e3
  ind = randi( numel(data), 1, 1 );
  setdata( B, data(ind) );
  B(1, :) = lab(ind, :);
  append( rebuilt, B );
end
toc;

%%
data = getdata( lab );
c = categorical( getlabels(lab) );
%%
new_data = [];
new_labs = categorical();

tic;
for i = 1:1e3
  ind = randi( numel(data), 1, 1 );
  new_labs = [ new_labs; c(ind, :) ];
  new_data = [ new_data; data(ind) ];
end
toc;

%%

tic;
B = Container();
sz = shape( cont, 1 );
for i = 1:1e3
  B = append( B, cont(randi(sz, 1, 1)) );
end
toc;

%%

tic;
shp = shape( cont, 1 );
for i = 1:1e3
  z = cont(randperm(randi(shp, 1, 1)));
end
toc;

%%
tic;
sz = size( lab, 1 );
for i = 1:1e3
  z = lab(randperm(randi(sz, 1, 1)));
end
toc;