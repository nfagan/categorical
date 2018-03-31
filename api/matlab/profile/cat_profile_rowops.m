function cat_profile_rowops

x = cat_test_get_mat_categorical();

f = fcat.from( x.c, x.f );

data = rand( size(f, 1), 10 );

z = labeled( data, f );

tic;
z2 = each( copy(z), getcats(z), @(x) mean(x, 1) );
c1 = toc;

tic;
z3 = eachindex( copy(z), getcats(z), @rowmean );
c2 = toc;

tic;
[f2, I] = keepeach( copy(f), getcats(f) );
data2 = rowop( data, I, @(x) mean(x, 1) );
c3 = toc;

tic;
[f2, I] = keepeach( copy(f), getcats(f) );
data3 = rowmean( data, I );
c4 = toc;

assert( isequal(data2, data3) );

fprintf( '\n labeled     (mean): %0.3f (ms)', c1 * 1e3 );
fprintf( '\n labeled  (rowmean): %0.3f (ms)', c2 * 1e3 );
fprintf( '\n fcat        (mean): %0.3f (ms)', c3 * 1e3 );
fprintf( '\n fcat     (rowmean): %0.3f (ms)', c4 * 1e3 );

end