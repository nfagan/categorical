function cat_profile_findor(randomize)

if ( nargin < 1 )
  randomize = true;
end

f = fcat.example();
c = categorical( f );
all_labs = getlabs( f );
n_labs = numel( all_labs );

N = min( n_labs, 5 );

iters = 1e2;

total_ts = zeros( iters, 2 );

I2 = false( size(c) );

for i = 1:iters
  
  if ( randomize )
    some_labs = all_labs(randperm(n_labs, randi(N, 1)));
  else
    some_labs = all_labs;
  end
  
  tic;
  I1 = findor( f, some_labs );
  total_ts(i, 1) = toc();
  
  tic;
  for j = 1:numel(some_labs)
    I2 = I2 | c == some_labs{j};
  end
  ind = find( any(I2, 2) );
  total_ts(i, 2) = toc();
  
  I2(:) = false;
end

c1 = sum( total_ts(:, 1) );
c2 = sum( total_ts(:, 2) );

fprintf( '\n fcat        (findor): %0.3f (ms)', c1 * 1e3 );
fprintf( '\n categorical (findor): %0.3f (ms)', c2 * 1e3 );
fprintf( '\n' );

end