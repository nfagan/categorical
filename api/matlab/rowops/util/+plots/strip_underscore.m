function s = strip_underscore(s, rep_with)

%   STRIP_UNDERSCORE -- Remove underscores in string.
%
%     s = STRIP_UNDERSCORE( s ) replaces underscores in `s`, a string-like
%     array, with spaces.
%
%     s = STRIP_UNDERSCORE( s, rep ); replaces underscores with `rep`, a
%     char-vector or string scalar, instead of ' '.
%
%     See also plots.cellstr_joint, strrep

if ( nargin < 2 )
  rep_with = ' ';
end

s = strrep( s, '_', rep_with );

end