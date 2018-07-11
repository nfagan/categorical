function assert_rowsmatch(a, b)

%   ASSERT_ROWSMATCH -- Ensure inputs have matching rows.
%
%     See also rowsmatch, rowmsg
%
%     IN:
%       - `a` (/any/)
%       - `b` (/any/)

if ( ~rowsmatch(a, b) )
  error( rowmsg(a, b) );
end

end