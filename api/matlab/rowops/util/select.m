function a = select(n, f)

%   SELECT -- Select one output from function returning multiple outputs.
%
%     c = select( n, f ) calls `f()`, requesting `n` outputs from it, and
%     returns the `n`-th one. For example, c = select( 2, f ); returns
%     the second output of `f`.
%
%     `f` is a function_handle and `n` is an integer-valued scalar >= 0.
%
%     See also collect, splat, conditional, attempt

if ( n == 0 )
  nargoutchk( 0, 0 );
  return
end

c = collect( n, f );
a = c{n};

end