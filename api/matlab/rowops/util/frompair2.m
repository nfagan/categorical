function [data_a, labels_a, data_b, labels_b] = frompair2(varargin)

%   FROMPAIR2 -- Destructure 2 pair aggregates into data and labels.
%
%     [data1, labels1, data2, labels2] = frompair2( pair1, pair2 ); returns
%     the fields 'data' and 'labels' from each of `pair1` and `pair2`.
%
%     [...] = frompair2(...); always returns the same four outputs as
%     above, but allows mixing-and-matching of structured and destructured
%     pairs. Namely, 
%
%       [...] = frompair2( pair1, pair2 );
%       [...] = frompair2( data1, labels1, pair2 ); 
%       [...] = frompair2( pair1, data2, labels2 );
%       [...] = frompair2( data1, labels1, data2, labels2 );
%
%     all return the same 4 outputs.
%
%     See also frompair, mkpair, emptypair, appendpair

narginchk( 2, 4 );

switch ( nargin )
  case 2
    % frompair2( pair1, pair2 );
    
    assert_ispair( varargin{1} );
    assert_ispair( varargin{2} );

    data_a = varargin{1}.data;
    labels_a = varargin{1}.labels;

    data_b = varargin{2}.data;
    labels_b = varargin{2}.labels;
  case 3
    if ( isa(varargin{3}, 'fcat') )
      % frompair2( pair1, data, labels );

      assert_ispair( varargin{1} );
      assert_ispair( varargin{2:end} );

      data_a = varargin{1}.data;
      labels_a = varargin{1}.labels;

      data_b = varargin{2};
      labels_b = varargin{3};
    else
      % frompair2( data, labels, pair2 );

      assert_ispair( varargin{1:2} );
      assert_ispair( varargin{3} );

      data_a = varargin{1};
      labels_a = varargin{2};

      data_b = varargin{3}.data;
      labels_b = varargin{3}.labels;
    end
  case 4
    % frompair2( data1, labels1, data2, labels2 );
    assert_ispair( varargin{1:2} );
    assert_ispair( varargin{3:end} );

    data_a = varargin{1};
    labels_a = varargin{2};

    data_b = varargin{3};
    labels_b = varargin{4};
end

end