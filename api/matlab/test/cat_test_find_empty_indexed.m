function cat_test_find_empty_indexed()

f = fcat.example();
none_f = none( copy(f) );

nonexisting_label = '';
existing_label = 'low';

assert( ~haslab(f, nonexisting_label) );
assert( haslab(f, existing_label) );
assert( haslab(none_f, existing_label) );

funcs = { @find, @findnot, @findor, @findnone };

for i = 1:numel(funcs)
  run( f, funcs{i}, nonexisting_label, existing_label, func2str(funcs{i}) );
  run( none_f, funcs{i}, nonexisting_label, existing_label, func2str(funcs{i}) );
end

end

function run(f, func, nonexisting_label, existing_label, func_name)

ind = func( f, nonexisting_label, [] );
assert( isempty(ind), 'Non-existing label + empty index did not return an empty index for: %s' ...
  , func_name );

ind = func( f, existing_label, [] );
assert( isempty(ind), 'Existing label + empty index did not return an empty index for: %s' ...
  , func_name );

end