function ci = fcat_category_indices(X, ci)

%   FCAT_CATEGORY_INDICES -- Numeric column indices into fcat.
%
%     nci = FCAT_CATEGORY_INDICES(X, ci) for the fcat `X` and array of
%     column subscripts `ci` returns a numeric vector of numeric column
%     subscripts `nci`. If `ci` is numeric, it is returned unmodified. If
%     `ci` is logical, `nci` is `find(ci)`. If `ci` is a char-vector,
%     string, or cell array of strings, `nci` contains numeric indices
%     of the columns corresponding to the categories `ci`.
%
%     See also fcat, rowsets, findeach

validateattributes( X, {'fcat'}, {}, mfilename, 'X' );

if ( ischar(ci) || isstring(ci) )
  ci = cellstr( ci );
end
if ( iscell(ci) )
  ci = cellfun( @(x) to_fcat_category_index(X, x), ci );
else
  ci = to_fcat_category_index( X, ci );
end

end

function ci = to_fcat_category_index(X, ci)

if ( islogical(ci) )
  ci = find( ci );
  
elseif ( isnumeric(ci) )
  %
elseif ( ischar(ci) || isstring(ci) )
  [tf, ib] = ismember( ci, getcats(X) );
  if ( ~tf )
    error( 'Reference to non-existent fcat category "%s".', ci );
  else
    ci = ib;
  end
else
  error( ['fcat category index should be char, string, cellstr' ...
    , ', numeric, or logical; was "%s".'], class(ci) );
end

end