function assert_hascat(obj, c)

%   ASSERT_HASCAT -- Assert categories exist.
%
%     assert_hascat( obj, cats ); throws an error if not all categories in
%     `cats` exist in the fcat object `obj`. `cats` can be a cell array of
%     strings or char.
%
%     See also fcat, assert_ispair

present = hascat( obj, c );

if ( ~all(present) )
  c = cellstr( c );
  missing = strjoin( c(~present), ' | ' );
  error( 'The following categories do not exist:\n\n%s', missing );
end

end