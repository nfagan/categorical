function [data, newlabs] = proportions_of(labs, proportions_each, proportions_of, mask)

%   PROPORTIONS_OF -- Proportions of the number of label combinations in
%     categories.
%
%     data = proportions_of( labels, proportions_each, proportions_of );
%     calculates, for each combination of labels in the category(ies)
%     `proportions_each`, the proportions of the number of labels or 
%     label combinations from the categories `proportions_of`. 
%
%     data = proportions_of( ..., mask ); restricts the calculation to rows
%     of labels identified by `mask`.
%
%     [data, labels] = proportions_of( ... ) also returns new labels
%     identifying rows of `data`.
%
%     See also fcat, fcat/combs, fcat/findall
%
%     EX //
%
%     f = fcat.example();
%     % for each 'dose', what is the proportion of the number of rows of
%     % each 'image'? 
%     [data, labels] = proportions_of( f', 'dose', 'image' );
%
%     IN:
%       - `labs` (fcat)
%       - `proportions_each` (cell array of strings, char)
%       - `proportions_of` (cell array of strings, char)
%       - `mask` (uint64) |OPTIONAL|
%     OUT:
%       - `data` (double)
%       - `newlabs` (fcat)

if ( nargin < 4 )
  mask = rowmask( labs );
end

props_of_labels = combs( labs, proportions_of, mask );
n_combinations = size( props_of_labels, 2 );

if ( isempty(proportions_each) )
  I = { mask };
  plabs = one( keep(labs', mask) );
else
  [plabs, I] = keepeach( labs', proportions_each, mask );
end

data = rownan( numel(I) * n_combinations );
newlabs = fcat();

for i = 1:numel(I)
  sub_mask = I{i};
  tmp_labs = plabs(i);
  
  N = numel( sub_mask );

  for j = 1:n_combinations
    current_labels = props_of_labels(:, j);
    
    n_prop_of = numel( find(labs, current_labels, sub_mask) );
    proportion_of = n_prop_of / N;

    assign_stp = (i-1) * n_combinations + j;
    data(assign_stp) = proportion_of;
    
    setcat( tmp_labs, proportions_of, current_labels );
    append( newlabs, tmp_labs );
  end
end

end