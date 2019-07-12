function assert_ispair(data, labels)

%   ASSERT_ISPAIR -- Assert that inputs form a valid data, label pair.
%
%     assert_ispair( data, labels ); throws an error if `labels` is not an
%     fcat object, or if `data` and `labels` do not have the same number of
%     rows.
%
%     assert_ispair( pair ); throws an error if `pair` is not a struct with
%     fields 'data' and 'labels', or if those fields contain values that
%     violate the above conditions.
%
%     See also rowsmatch, rows, fcat

narginchk( 1, 2 );

if ( nargin == 1 )
  if ( ~isstruct(data) || ~isscalar(data) || ~all(isfield(data, {'data', 'labels'})) )
    error( 'Pair must be a struct with fields ''data'' and ''labels''.' );
  end
 
  labels = data.labels;
  data = data.data;
end

if ( ~isa(labels, 'fcat') )
  error( 'Labels must be an fcat object; were of class "%s".', class(labels) );
end

assert_rowsmatch( data, labels, 'data', 'labels' );

end