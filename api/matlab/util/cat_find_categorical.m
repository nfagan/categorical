function ind = cat_find_categorical(c, cats, selectors, f)

%   CAT_FIND_CATEGORICAL -- fcat find equivalent for categorical arrays.
%
%     ind = cat_find_categorical( c, cats, selectors, f ); produces a
%     logical vector `ind` such that `isequal( find(ind), find(f,
%     selectors)` is true. 
%
%     `c` is the categorical equivalent of `f`, and `cats` is the cell
%     array of category names identifying columns of `c`. `selectors` is a
%     cell array of strings or char.
%
%     See also cat_findall_categorical, fcat/find, fcat/fcat

if ( ~iscell(selectors) )
  selectors = cellstr( selectors );
end

selector_cats = whichcat( f, selectors );
[groups, names] = findgroups( selector_cats );
unique_groups = unique( groups );

ind = true( size(c, 1), 1 );

for i = 1:numel(unique_groups)
  group_ind = find( groups == unique_groups(i) );
  c_col = c(:, ismember(cats, names{i}));
  
  for j = 1:numel(group_ind)
    if ( j == 1 )
      res = c_col == selectors{group_ind(j)};
    else
      res = res | c_col == selectors{group_ind(j)};
    end
  end
  
  ind = ind & res;
end

end