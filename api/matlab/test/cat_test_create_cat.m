function cat_test_create_cat()

x = fcat();
x.requirecat('hi');
x('hi') = 'sup';
requirecat(x, 'yo');
z = combs( x );

end