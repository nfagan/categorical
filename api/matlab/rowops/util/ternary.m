function a = ternary(cond, a, b)

%   TERNARY -- One-line if/else.
%
%     v = ternary( COND, A, B ) returns `A` if `COND` is true, or else `B`.
%
%     It is equivalent to the `V = COND ? A : B` syntax present in C and
%     some other languages.
%
%     See also if, else
%
%     IN:
%       - `cond` (logical)
%       - `a` (/any/)
%       - `b` (/any/)
%     OUT:
%       - `a` (/any/)

if ( ~cond ), a = b; end

end