function cat_test_run(func)

%   CAT_TEST_RUN -- Run test function.
%
%     IN:
%       - `func` (function_handle)

func_name = func2str( func );

try
  func();
  cat_test_util_print_ok( func_name );
catch err
  fprintf( '\n `%s` failed with message:\n %s\n', func2str(func), err.message );
end

end