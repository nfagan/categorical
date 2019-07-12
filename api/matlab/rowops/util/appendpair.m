function [data, labels] = appendpair(varargin)

%   APPENDPAIR -- Append pair to another.
%
%     outpair = appendpair( pair1, pair2 ); appends the contents of pair2
%     to pair1.
%
%     outpair = appendpair(...); allows mixing-and-matching of structured 
%     and destructured pairs.
%
%     [data, labels] = appendpair(...) returns the appended data and labels
%     as separate outputs.
%
%     Note that the labels of `pair1` will be modified unless explicitly
%     copied.
%
%     See also copypair, mkpair, frompair2

try
  [data_a, labels_a, data_b, labels_b] = frompair2( varargin{:} );
catch err
  throw( err );
end

data_out = [ data_a; data_b ];
append( labels_a, labels_b );

if ( nargout < 2 )
  data = mkpair( data_out, labels_a );
else
  data = data_out;
  labels = labels_a;
end

end