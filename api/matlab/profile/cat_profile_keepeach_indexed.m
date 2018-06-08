function cat_profile_keepeach_indexed()

f = fcat.example( 'large' );

iters = 1e1;

cats = getcats( f );
NC = numel( cats );

labs = getlabs( f );
NL = numel( labs );

ts = zeros( iters, 2 );

for i = 1:iters
  disp( i );
  
  some_cats = cats( randperm(NC, randi(NC, 1)) );
  some_labs = labs( randperm(NL, randi(NL, 1)) );
  
  I1 = find( f, some_labs );
  
  tic;
  f1 = keepeach( keep(copy(f), I1), some_cats );
  ts(i, 1) = toc();
  
  tic;
  [f2, I2] = keepeach( copy(f), some_cats, I1 );
  ts(i, 2) = toc();  
end

c1 = sum(ts(:, 1));
c2 = sum(ts(:, 2));

fprintf( '\n fcat   (keepeach-copied): %0.3f (ms)', c1 * 1e3 );
fprintf( '\n fcat  (keepeach-indexed): %0.3f (ms)', c2 * 1e3 );
fprintf( '\n' );

end