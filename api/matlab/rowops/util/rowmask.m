function mask = rowmask(data)

%   ROWMASK -- Create a column-vector mask, (1:rows(X))';
%
%     mask = rowmask( A ); creates an Mx1 column-vector, where M is equal 
%     to `size( A, 1 )`.
%
%     See also fcat, fcat/find, rows

mask = (1:rows(data))';

end
