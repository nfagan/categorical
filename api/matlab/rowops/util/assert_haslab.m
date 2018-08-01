function assert_haslab(obj, c)

%   ASSERT_HASLAB -- Assert labels exist.
%
%     assert_haslab( obj, LABS ); throws an error if not all labels in
%     `LABS` exist in the fcat object `obj`.  `LABS` can be a cell array of
%     strings or char.
%
%     IN:
%       - `obj` (fcat)
%       - `c` (cell array of strings, char)

present = haslab( obj, c );

if ( ~all(present) )
  c = cellstr( c );
  missing = strjoin( c(~present), ' | ' );
  error( 'The following labels do not exist:\n\n%s', missing );
end

end