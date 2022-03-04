function ci = numeric_column_indices(X, coli)

%   NUMERIC_COLUMN_INDICES -- Ensure column indices are numeric.

if ( isa(X, 'fcat') )
  ci = fcat_category_indices( X, coli );
elseif ( isa(X, 'table') )
  ci = table_variable_indices( X, coli );
else
  validateattributes( coli, {'numeric', 'logical'}, {}, mfilename, 'coli' );
  if ( islogical(coli) )
    ci = find( coli );
  else
    ci = coli;
  end
end

end