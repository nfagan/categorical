function [data, labs] = copypair(data, labels)

%   COPYPAIR -- Copy labels in pair.
%
%     pair_b = copypair( pair_a ); for the struct `pair_a` with fields
%     'data' and 'labels' returns a new struct `pair_b` whose data are the 
%     same as in `pair_a`, and whose labels are an explicit by-value copy 
%     of those in `pair_a`.
%
%     [data, labels] = copypair( pair_a ); works as above, but destructures
%     the fields of `pair_a` into separate outputs `data` and `labels`.
%
%     [data_b, labels_b] = copypair( data_a, labels_a ) copies `labels_a`
%     and returns them as `labels_b`. `labels_a` must have the same rows as
%     `data_a`.
%
%     Note that only the labels in `pair_a` are explicitly copied by value; 
%     i.e., if the data in `pair_a` are a reference / handle type, then the 
%     data in `pair_b` will remain a reference to the same memory as in 
%     `pair_a`.
%
%     See also mkpair, indexpair, assert_ispair

if ( nargin == 1 )
  assert_ispair( data );
  
  if ( nargout > 1 )
    labs = copy( data.labels );
    data = data.data;
  else
    data.labels = copy( data.labels );
  end
else
  assert_ispair( data, labels );
  labs = copy( labels );
end

end