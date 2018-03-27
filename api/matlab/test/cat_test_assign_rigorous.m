function cat_test_assign_rigorous()

x = cat_test_get_mat_categorical();

c = x.c;

f = fcat.from( c, x.f );

n_inds = 1e2;

new_cat = categorical();
new_cat(n_inds, numel(x.f)) = '<undefined>';
indices = randperm( size(f, 1), n_inds );

new_cat(1:size(new_cat, 1), :) = c(indices, :);

new_f = fcat.with( x.f, n_inds );
new_f(:) = f(indices);

[cat_new_f, cats] = categorical( new_f );

for i = 1:numel(cats)
  other_ind = strcmp( x.f, cats{i} );
  other_str = cellstr( new_cat(:, other_ind) );
  assert( isequal(new_f(:, i), other_str), 'Objects were not equal.' );
end


end