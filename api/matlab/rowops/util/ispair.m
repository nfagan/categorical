function tf = ispair(data, labels)

%   ISPAIR -- True if inputs form a valid data-label pair.
%
%     tf = ispair( data, labels ); returns true if `labels` is an fcat
%     object with the same number of rows as `data`, which can be of any
%     class.
%
%     tf = ispair( pair ); returns true if `pair` is a scalar struct with
%     fields `data` and `labels`, whose values adhere to the above
%     conditions.
%
%     See also mkpair, copypair, indexpair, fcat

if ( nargin == 1 )
  tf = isstruct( data ) && isscalar( data ) && all( isfield(data, {'data', 'labels'}) );
else
  tf = isa( labels, 'fcat' ) && rowsmatch( data, labels );
end

end
