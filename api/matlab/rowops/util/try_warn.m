function varargout = try_warn(func)

%   TRY_WARN -- Warn on error.
%
%     try_warn( func ); calls `func` and, if it throws an error, displays a 
%     warning with the error message text.
%
%     [out1, out2, ...] = try_warn( func ); calls `func` and, if it does
%     not throw an error, returns outputs 1..n from `func`. If `func` does
%     throw an error, a warning message with the error text is displayed,
%     and outputs 1..n are empty arrays ([]).
%
%     See also attempt, conditional

[varargout{1:nargout}] = attempt( func, @warn );

end

function varargout = warn(err)

warning( err.message );
[varargout{1:nargout}] = deal( [] );

end