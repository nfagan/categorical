function m = mask_gele(a, min, max)

%   MASK_GELE -- True for array elements within [min, max], inclusive.
%
%     m = mask_gele( a, min, max ); returns true for elements of `a` that
%     are greater than or equal to `min` and less than or equal to `max`.
%
%     See also mask_gtlt

m = a >= min & a <= max;

end