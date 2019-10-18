function cat_testall()

%   CAT_TESTALL -- Run all tests.

funcs = cat_testfuncs();

for i = 1:numel(funcs)
  cat_test_run( funcs{i} );
end

end