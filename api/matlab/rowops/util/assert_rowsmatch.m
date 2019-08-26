function assert_rowsmatch(a, b, varargin)

%   ASSERT_ROWSMATCH -- Ensure inputs have matching rows.
%
%     assert_rowsmatch( a, b ); throws an error if inputs `a` and `b` do 
%     not have the same number of rows.
%
%     See also rowsmatch, rowmsg

if ( ~rowsmatch(a, b) )
  error( rowmsg(a, b, varargin{:}) );
end

end