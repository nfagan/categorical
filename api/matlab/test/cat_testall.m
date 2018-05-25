function cat_testall()

%   CAT_TESTALL -- Run all tests.

cat_test_run( @cat_test_rename_cat );
cat_test_run( @cat_test_remove );
cat_test_run( @cat_test_append_create );
cat_test_run( @cat_test_merge );
cat_test_run( @cat_test_replace );
cat_test_run( @cat_test_progenitors );
cat_test_run( @cat_test_assign_rigorous );
cat_test_run( @cat_test_assign );
cat_test_run( @cat_test_create_cat );
cat_test_run( @cat_test_partcat );
cat_test_run( @cat_test_keepeach );
cat_test_run( @cat_test_keep );
cat_test_run( @cat_test_append_resize );
cat_test_run( @cat_test_append );
cat_test_run( @cat_test_append_keep );
cat_test_run( @cat_test_copy );
cat_test_run( @cat_test_resize );

end