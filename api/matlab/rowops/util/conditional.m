function varargout = conditional(condition, true_expr, false_expr)

%   CONDITIONAL -- Conditionally execute expression(s).
%
%     a = conditional( cond, expr ); for function_handles `cond` and
%     `expr` calls `cond()` and, if it returns true, subsequently calls
%     `expr()`, returning its result in `a`. If `cond` returns false (or
%     a false-y value), `expr` is not called, and the result `a` is the
%     empty array ([]).
%
%     a = conditional( ..., else_expr ) calls `else_expr` if `cond` returns
%     false (or a false-y value), returning the result in `a`.
%
%     [out1, out2, ... outN] = conditional(...) requests N outputs from the
%     executed expression function. If the result of `cond` is false-y and
%     no `else_expr` is provided, then each output is the empty array ([]).
%
%     See also ternary, if, else, guard_empty

if ( condition() )
  [varargout{1:nargout}] = true_expr();
  
elseif ( nargin > 2 )
  [varargout{1:nargout}] = false_expr();
  
else
  [varargout{1:nargout}] = deal( [] );
end

end