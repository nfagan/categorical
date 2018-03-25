function cat_test_assert_depends_present( test_name )

if ( nargin < 1 )
  test_name = '(unspecified)';
end

if ( isempty(which('get_example_container')) )
  error( ['Test "%s" depends on the `global` repository, available' ...
    , ' at: https://github.com/nfagan/global. Download or clone the repository' ...
    , ' and add it to matlab''s search path.'], test_name );
end

end