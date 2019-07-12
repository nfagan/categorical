function [data, labels] = frompair(data, labels)

%   FROMPAIR -- Destructure pair aggregate into data and labels.
%
%     [data, labels] = frompair( pair ); returns the fields 'data' and
%     'labels' from `pair`.
%
%     See also mkpair, indexpair, copypair, frompair2

if ( nargin == 1 )
  assert_ispair( data );
  
  labels = data.labels;
  data = data.data;
else
  assert_ispair( data, labels );
end

end