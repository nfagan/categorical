function c = if_nonempty(a, b)

%   IF_NONEMPTY -- Return first input if non-empty, else return second.
%
%     c = if_nonempty( a, b ); returns `a` if `a` is non-empty, and `b`
%     otherwise.
%
%     See also ternary, if

if ( ~isempty(a) )
  c = a;
else
  c = b;
end

end