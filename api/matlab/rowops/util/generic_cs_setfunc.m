function varargout = generic_cs_setfunc(func, a, b, varargin)

%   GENERIC_CS_SETFUNC -- cellstr set-membership function.
%
%     a = generic_cs_setfunc( FUNC, A, B ) calls the set-membership binary
%     function `FUNC` with inputs `A` and `B`. `A` and `B` can be any
%     combination of string-like inputs that can be converted to a cell
%     array of strings with the `cellstr` function; output `a` is always a
%     cell array of strings.
%
%     a = generic_cs_setfunc( ..., FLAGS ) calls the function with
%     additional flags, or 'name', value pair-inputs. See the documentation
%     of the underlying set-membership function for valid inputs.
%
%     This function is not meant to be called directly, but is instead the
%     generic form of functions like csunion.
%
%     See also csunion, csintersect, union, intersect
%
%     IN:
%       - `func` (function_handle)
%       - `a` (cell array of strings, char)
%       - `b` (cell array of strings, char)
%       - `varargin` (/any/)
%     OUT:
%       - `varargout` (/any/)

[varargout{1:nargout}] = func( cellstr(a), cellstr(b), varargin{:} );

end