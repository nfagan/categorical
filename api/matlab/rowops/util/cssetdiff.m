function varargout = cssetdiff(a, b, varargin)

%   CSSETDIFF -- cellstr set difference.
%
%     C = cssetdiff( A, B ) is the set-difference of `A` and `B`, after
%     ensuring both `A` and `B` are cell arrays of strings. Output `C` is a 
%     cell array of strings.
%
%     See also setdiff, generic_cs_setfunc
%
%     IN:
%       - `a` (cell array of strings, char)
%       - `b` (cell array of strings, char)
%       - `varargin` (/any/)
%     OUT:
%       - `varargout`

[varargout{1:nargout}] = generic_cs_setfunc( @setdiff, a, b, varargin{:} );

end