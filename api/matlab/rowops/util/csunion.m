function varargout = csunion(a, b, varargin)

%   CSUNION -- cellstr union.
%
%     C = csunion( A, B ) is the set-union of `A` and `B`, after ensuring
%     both `A` and `B` are cell arrays of strings. Output `C` is a cell 
%     array of strings.
%
%     See also union, generic_cs_setfunc
%
%     IN:
%       - `a` (cell array of strings, char)
%       - `b` (cell array of strings, char)
%       - `varargin` (/any/)
%     OUT:
%       - `varargout`

[varargout{1:nargout}] = generic_cs_setfunc( @union, a, b, varargin{:} );

end