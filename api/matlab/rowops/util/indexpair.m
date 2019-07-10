function [data, labels] = indexpair(data, labels, I)

%   INDEXPAIR -- Apply row index to data-label pair.
%
%     data = indexpair( dat, labs, I ) keeps rows of `dat` and `labs`
%     identified by the uint64 index vector `I`, and returns the `data`.
%     Unless explicitly copied, `labs` is modified to match the rows of 
%     `data`. `dat` and `labs` must have the same number of rows.
%
%     [..., labels] = indexpair(...) also returns the kept labels. Use this
%     additional output if passing a copy of `labs` to the function.
%
%     pair = indexpair( pair, I ) for the struct `pair` with fields 'data'
%     and 'labels', works as above, but operates on the fields of `pair`.
%
%     [data, labels] = indexpair( pair, I ) for the struct `pair` works as
%     above, but returns the indexed-fields 'data' and 'labels' as separate
%     outputs.
%
%     See also fcat, assert_ispair, mkpair, copypair

if ( nargin == 2 )
  assert_ispair( data );
  
  I = labels;
  
  if ( nargout > 1 ) 
    labels = keep( data.labels, I );
    data = rowref( data.data, I );
  else
    keep( data.labels, I );
    data.data = rowref( data.data, I );
  end    
else
  assert_ispair( data, labels );

  data = rowref( data, I );
  keep( labels, I );
end

end