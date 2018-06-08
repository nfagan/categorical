function cat_profile_findall(randomize)

if ( nargin < 1 )
  randomize = true;
end

f = fcat.example();
c = categorical( f );
cats = getcats( f );
N = numel( cats );

iters = 1e2;

total_ts = zeros( iters, 2 );

for i = 1:iters
  
  if ( randomize )
    some_cats = cats(randperm(N, randi(N, 1)));
  else
    some_cats = cats;
  end
    
  [~, cat_inds] = ismember( some_cats, cats );
  
  tic;
  I1 = findall( f, some_cats );
  total_ts(i, 1) = toc();
  
  tic;
  I2 = cat_findall_categorical( c(:, cat_inds) );
  total_ts(i, 2) = toc();  
end

c1 = sum(total_ts(:, 1));
c2 = sum(total_ts(:, 2));

fprintf( '\n fcat        (findall): %0.3f (ms)', c1 * 1e3 );
fprintf( '\n categorical (findall): %0.3f (ms)', c2 * 1e3 );
fprintf( '\n' );

end