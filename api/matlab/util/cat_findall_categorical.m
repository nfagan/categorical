function [I, C] = cat_findall_categorical(categ)

%   CAT_FINDALL_CATEGORICAL -- Produce output equivalent to fcat/findall,
%     for a categorical matrix.
%
%     See also cat_find_categorical

[C, ~, ib] = unique( categ, 'rows' );
I = accumarray( ib, (1:numel(ib))', [], @(rows) {sort(rows)} );

end