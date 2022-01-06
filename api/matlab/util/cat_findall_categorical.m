function [I, C] = cat_findall_categorical(categ, cats, subset_cats)

%   CAT_FINDALL_CATEGORICAL -- fcat findall equivalent for categorical arrays.
%
%     [I, C] = cat_findall_categorical( c ); for the categorical matrix `c`
%     returns a cell array of indices `I` containing groups of indices
%     identifying unique rows of `c`. `C` is a categorical array with the
%     same number of rows as `I`; the i-th row of `C` is found at every
%     row `I{i}` in `c`.
%
%     [I, C] = cat_findall_categorical( c, cats, subset_cats ); returns 
%     groups of indices by evaluating the unique rows in columns of `c`
%     identified by `subset_cats`. `cats` is a cell array of strings
%     identifying the columns of `c`.
%
%     See also cat_find_categorical

if ( nargin == 1 )
  [C, ~, ib] = unique( categ, 'rows' );
else
  [~, cat_inds] = ismember( subset_cats, cats );
  [C, ~, ib] = unique( categ(:, cat_inds), 'rows' );
end

I = accumarray( ib, (1:numel(ib))', [], @(rows) {sort(rows)} );

end