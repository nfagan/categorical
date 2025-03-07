function [data, newlabs, I] = proportions_of(labs, proportions_each, proportions_of, mask)

%   PROPORTIONS_OF -- Proportions of the number of label combinations in
%     categories.
%
%     data = proportions_of( labels, props_each, props_of ); calculates, 
%     for each combination of labels in the category(ies) 
%     `props_each`, the proportions of the number of labels or label 
%     combinations from the categories `props_of`. 
%
%     data = proportions_of( ..., mask ); restricts the calculation to rows
%     of labels identified by `mask`. Label combinations of which to
%     calculate proportions will also only be drawn from `mask` rows.
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

if ( nargin < 4 )
  mask = rowmask( labs );
end

props_of_labels = combs( labs, proportions_of, mask );
n_combinations = size( props_of_labels, 2 );

[plabs, I] = keepeach_or_one( labs', proportions_each, mask );

data = rownan( numel(I) * n_combinations );
newlabs = fcat.like( plabs );

for i = 1:numel(I)
  sub_mask = I{i};
  
  N = numel( sub_mask );

  for j = 1:n_combinations
    current_labels = props_of_labels(:, j);
    
    n_prop_of = numel( find(labs, current_labels, sub_mask) );
    proportion_of = n_prop_of / N;

    assign_stp = (i-1) * n_combinations + j;
    data(assign_stp) = proportion_of;
    
    setcat( plabs, proportions_of, current_labels, i );
    append( newlabs, plabs, i );
  end
end

end