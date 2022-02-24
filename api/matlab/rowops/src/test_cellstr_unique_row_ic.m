function test_cellstr_unique_row_ic(f)

if ( nargin < 1 )
  f = fcat.example();
end

for i = 1:1000
  ri = randperm( rows(f), 1000 );
  ci = randperm( numel(getcats(f)), floor(numel(getcats(f)) * rand()) );
  
  sub = cellstr( f, ci, ri );
  ind = cellstr_unique_row_ic( sub );
  
  sub_cat = categorical( f, ci, ri );
  if ( isempty(sub_cat) )
    assert( isempty(sub) );
    sub_cat = reshape( sub_cat, size(sub) );
  end
  
  [un_sub_cat, ~, un_c] = unique( sub_cat, 'rows' );
  assert( numel(unique(un_c)) == numel(unique(ind)) );
  
  un_ind = unique( ind );
  un_sub = sub(arrayfun(@(x) find(ind == x, 1), un_ind), :);
  un_subc = categorical( un_sub );
  assert( isequal(sortrows(un_subc), un_sub_cat) );
end

end