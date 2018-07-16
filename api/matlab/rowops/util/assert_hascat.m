function assert_hascat(obj, c)

%   ASSERT_HASCAT -- Assert categories exist.
%
%     assert_hascat( obj, CATS ); throws an error if not all categories in
%     `CATS` exist in the fcat object `obj`.  `CATS` can be a cell array of
%     strings or char.
%
%     IN:
%       - `obj` (fcat)
%       - `c` (cell array of strings, char)

present = hascat( obj, c );

if ( ~all(present) )
  c = cellstr( c );
  missing = strjoin( c(~present), ' | ' );
  error( 'The following categories do not exist:\n\n%s', missing );
end

end