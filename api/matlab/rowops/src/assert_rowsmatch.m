function assert_rowsmatch(a, b)

%   ASSERT_ROWSMATCH -- Ensure inputs have matching rows.
%
%     See also rowsmatch, rowmsg
%
%     IN:
%       - `a` (/any/)
%       - `b` (/any/)

assert( rowsmatch(a, b), rowmsg(a, b) );

end