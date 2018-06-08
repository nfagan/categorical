function cat_profile_find(randomize)

if ( nargin < 1 )
  randomize = true;
end

f = fcat.example();
all_labs = getlabs( f );

N = numel( all_labs );

iters = 1e2;

total_ts = zeros( iters, 1 );

for i = 1:iters
  
  if ( randomize )
    some_labs = all_labs(randperm(N, randi(N, 1)));
  else
    some_labs = all_labs;
  end
  
  tic;
  I1 = find( f, some_labs );
  total_ts(i, 1) = toc();
end

c1 = sum(total_ts(:, 1));

fprintf( '\n fcat (find): %0.3f (ms)', c1 * 1e3 );
fprintf( '\n' );

end