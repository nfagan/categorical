function varargout = attempt(try_func, catch_func)

%   ATTEMPT -- Functional try/catch.
%
%     a = attempt( try_func, catch_func ); calls `try_func()` and, if it
%     does not throw an error, returns its result in `a`. If an error
%     occurs, `catch_func(err)` is called with the MException `err`, and
%     the result of this function is returned in `a`.
%
%     [out1, out2, ...] requests any number of outputs from `try_func`.
%     `catch_func` should return the same number of outputs as `try_func`.
%
%     a = attempt( try_func ); works as above, except that no alternative
%     function is called in the event that `try_func()` throws an error. In
%     this case, all requested outputs will be the empty array ([]).
%
%     See also conditional, try, catch

if ( nargin == 1 )
  try
    [varargout{1:nargout}] = try_func();
  catch
    [varargout{1:nargout}] = [];
  end
else
  try
    [varargout{1:nargout}] = try_func();
  catch err
    [varargout{1:nargout}] = catch_func( err );
  end
end

end