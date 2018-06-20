function cat_profile_keepeach()

x = cat_test_get_mat_categorical();

f = fcat.from( x.c );

tic;
[f2, I] = keepeach( f', getcats(f) );
c1 = toc();

tic;
[i2, c2] = cat_findall_categorical( x.c );
c2 = toc();

fprintf( '\n fcat:          %0.3f (ms)', c1 * 1e3 );
fprintf( '\n categorical:   %0.3f (ms)', c2 * 1e3 );
fprintf( '\n' );

end