function cat_profile_find_indexed(randomize)

if ( nargin < 1 )
  randomize = true;
end

f = fcat.example();
c = categorical( f );

labs = getlabs( f );
N = numel( labs );

iters = 1e2;

ts = zeros( iters, 3 );

for i = 1:iters  
  if ( randomize )
    some_labs = get_labs( labs, N );
    other_labs = get_labs( labs, N );
  else
    some_labs = labs;
    other_labs = labs;
  end
  
  tic;
  i1 = find( f, some_labs );
  i2 = intersect( i1, find(f, other_labs) );
  ts(i, 1) = toc();
  
  tic;
  i3 = find( f, some_labs, find(f, other_labs) );
  ts(i, 2) = toc();
  
  tic;
  ind = true( size(c) );
  for j = 1:numel(some_labs)
    ind = ind & c == some_labs{j};
  end
  ts(i, 3) = toc;
  
end

c1 = sum(ts(:, 1));
c2 = sum(ts(:, 2));
c3 = sum(ts(:, 3));

fprintf( '\n fcat        (find-intersect): %0.3f (ms)', c1 * 1e3 );
fprintf( '\n fcat          (find-indexed): %0.3f (ms)', c2 * 1e3 );
fprintf( '\n categorical        (logical): %0.3f (ms)', c3 * 1e3 );
fprintf( '\n' );

end

function some_labs = get_labs(labs, N)
some_labs = labs( randperm(N, randi(N, 1)) );
end