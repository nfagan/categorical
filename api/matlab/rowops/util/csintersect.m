function varargout = csintersect(a, b, varargin)

%   CSINTERSECT -- cellstr intersect.
%
%     C = csintersect( A, B ) is the set-intersection of `A` and `B`, after 
%     ensuring both `A` and `B` are cell arrays of strings. Output `C` is a 
%     cell array of strings.
%
%     See also intersect, generic_cs_setfunc
%
%     IN:
%       - `a` (cell array of strings, char)
%       - `b` (cell array of strings, char)
%       - `varargin` (/any/)
%     OUT:
%       - `varargout`

[varargout{1:nargout}] = generic_cs_setfunc( @intersect, a, b, varargin{:} );

end