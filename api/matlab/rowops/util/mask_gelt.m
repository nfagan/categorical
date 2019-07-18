function m = mask_gelt(a, min, max)

%   MASK_GELE -- True for array elements within [min, max).
%
%     m = mask_gelt( a, min, max ); returns true for elements of `a` that
%     are greater than or equal to `min` and less than `max`.
%
%     See also mask_gtle

m = a >= min & a < max;

end