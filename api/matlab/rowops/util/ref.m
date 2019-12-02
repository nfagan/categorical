function varargout = ref(a, method, sub1, varargin)

%   REF -- Simple subscript reference.
%
%     v = ref( a, method, sub ); references an element of `a` using
%     `method` and subscript `sub`. Method is one of '()' or '{}'.
%
%     `sub` is an integer-valued scalar containing a linear index into `a`, 
%     and `v` is that element of `a` as referenced with either parentheses 
%     or braces, respectively.
%
%     v = ref( a, method, sub1, ... subN ); returns the element at the
%     n-dimensional subscripts given by `sub1` ... `subN`.
%
%     v = ref( a, '()', subs ); and 
%     v = ref( a, '()', subs1, ... subsN ); 
%     for vector(s) of subscript(s), returns the slice of `a` evaluated at
%     those subscripts.
%
%     [out1, ... outN] = ref( a, '{}', subs ); and 
%     [out1, ... outN] = ref( a, '{}', subs1, ... subsN );
%     for vector(s) of subscript(s), return the list-expanded contents of 
%     `a`, evaluated at those subscripts, as separate outputs.
%     
%     See also cellrefs, lists

switch ( method )
  case '()'
    nargoutchk( 0, 1 );
    varargout{1} = a(sub1, varargin{:});
  case '{}'
    [varargout{1:nargout}] = a{sub1, varargin{:}};
  otherwise
    validatestring( method, {'()', '{}'}, mfilename, 'method' );
end

end