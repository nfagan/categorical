function ci = table_variable_indices(X, ci)

%   TABLE_VARIABLE_INDICES -- Numeric column indices into table.
%
%     nci = TABLE_VARIABLE_INDICES(X, ci) for the table `X` and array of
%     column subscripts `ci` returns a numeric vector of numeric column
%     subscripts `nci`. If `ci` is numeric, it is returned unmodified. If
%     `ci` is logical, `nci` is `find(ci)`. If `ci` is a char-vector,
%     string, or cell array of strings, `nci` contains numeric indices
%     of the columns corresponding to the variable names `ci`.
%
%     See also table, rowsets, findeach

validateattributes( X, {'table'}, {}, mfilename, 'X' );

if ( ischar(ci) || isstring(ci) )
  ci = cellstr( ci );
end
if ( iscell(ci) )
  ci = cellfun( @(x) to_table_variable_index(X, x), ci );
else
  ci = to_table_variable_index( X, ci );
end

end

function ci = to_table_variable_index(X, ci)

if ( islogical(ci) )
  ci = find( ci );
  
elseif ( isnumeric(ci) )
  %
elseif ( ischar(ci) || isstring(ci) )
  [tf, ib] = ismember( ci, X.Properties.VariableNames );
  if ( ~tf )
    error( 'Reference to non-existent table variable "%s".', ci );
  else
    ci = ib;
  end
else
  error( ['Table column index should be char, string, cellstr' ...
    , ', numeric, or logical; was "%s".'], class(ci) );
end

end