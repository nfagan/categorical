function rowops_profile_colons()

iters = 1e3;
cs = zeros( iters, 2 );

for i = 1:iters
  
  tic;
  n1 = repmat( {':'}, 1, 3 );
  cs(i, 1) = toc;
  
  tic;
  n2 = colons( 3 );
  cs(i, 2) = toc;
  
  assert( isequal(n1, n2) );
  
end

c1 = sum( cs(:, 1) );
c2 = sum( cs(:, 2) );

fprintf( '\n repmat: %0.3f (ms) [%d]', c1 * 1e3, iters );
fprintf( '\n colons: %0.3f (ms) [%d]', c2 * 1e3, iters );
fprintf( '\n' );

end