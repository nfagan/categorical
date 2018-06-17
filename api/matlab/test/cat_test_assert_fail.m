function cat_test_assert_fail(func, msg, varargin)

%   CAT_TEST_ASSERT_FAIL -- Ensure an operation fails.
%
%     cat_test_assert_fail( @func, '%s failed', 'msg' ) calls func() and,
%     if it does not throw an error, throws an error with message: 'msg
%     failed.'
%
%     IN:
%       - `func` (function_handle)
%       - `msg` (char)
%       - `varargin` (char) |OPTIONAL|

fail_id = '__failed__';

try
  func();
  error( fail_id );
catch err
  if ( strcmp(err.message, fail_id) )
    error( msg, varargin{:} );
  end
end

end