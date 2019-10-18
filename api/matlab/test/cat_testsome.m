function cat_testsome(filter_func)

%   CAT_TESTSOME -- Run subset of all tests.
%
%     cat_testsome( filter_func ); calls `filter_func` once for each 
%     test-case function. The set of test-cases for which `filter_func`
%     returns true is then run.
%
%     EX //
%     % Run only tests related to 'addlab'
%     cat_testsome( @(x) contains(func2str(x), 'addlab') );
%
%     See also cat_testall, cat_test_run

funcs = cat_testfuncs();
funcs = funcs(cellfun(filter_func, funcs));

for i = 1:numel(funcs)
  cat_test_run( funcs{i} );
end

end