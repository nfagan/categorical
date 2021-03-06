function a = ternary(cond, a, b)

%   TERNARY -- One-line if/else.
%
%     v = ternary( COND, A, B ) returns `A` if `COND` is true, or else `B`.
%
%     It is somewhat equivalent to the `V = COND ? A : B` syntax present in 
%     C and some other languages.
%
%     See also if, else, conditional

if ( ~cond ), a = b; end

end