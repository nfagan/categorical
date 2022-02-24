function test_rowsets()

f = fcat.example();
test_cellstr_categorical_fcat( f, 1:ncats(f) );

for i = 1:100
  m = randperm( rows(f), floor(rand*rows(f)) );
  n = floor( rand * ncats(f) );
  ic = randperm( ncats(f), n );  
  test_cellstr_categorical_fcat( f, ic, 'mask', m(:) );
end

end

function test_cellstr_categorical_fcat(f, ic, varargin)

c = cellstr( f );

[I, C] = findeach( c, ic, varargin{:} );
[I2, C2] = findeach( categorical(c), ic, varargin{:} );
[I3, C3] = findeach( f, nthcat(f, ic), varargin{:} );

[~, ind1] = sortrows( categorical(C) );
[~, ind2] = sortrows( categorical(C2) );
[~, ind3] = sortrows( categorical(C3) );

assert( isequal(C(ind1, :), C2(ind2, :), C3(ind3, :)) );

I = I(ind1);
I2 = I2(ind2);
I3 = I3(ind3);

assert( isequal(size(I), size(I2), size(I3)) );
assert( all(cellfun(@(x, y, z) isequal(size(x), size(y), size(z)), I, I2, I3)) );

for i = 1:numel(I)
  if ( ~isequal(sort(I{i}), sort(I2{i})) )
    error( 'Non-equal indices' );
  end
end

end