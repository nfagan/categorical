function cat_profile_addcat()

x = fcat();

iters = 1e3;

cat_names = arrayfun( @(x) sprintf('cat%d', x), 1:iters, 'un', false );

tic;
for i = 1:iters
  addcat( x, cat_names{i} );
end

c1 = toc;

y = fcat();
tic;
addcat( y, cat_names );
c2 = toc;


fprintf( '\n fcat:        (addcat, loop) %0.3f (ms) [%d]', c1 * 1e3, iters );
fprintf( '\n fcat: (addcat, single call) %0.3f (ms) [%d]', c2 * 1e3, iters );
fprintf( '\n' );

end