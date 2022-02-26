function test_rowsets()

f = fcat.example();
test_cellstr_categorical_table_fcat( f, 1:ncats(f) );

for i = 1:100
  fprintf( '\n %d of %d', i, 100 );
  m = randperm( rows(f), floor(rand*rows(f)) );
  n = floor( rand * ncats(f) );
  ic = randperm( ncats(f), n );  
  test_cellstr_categorical_table_fcat( f, ic, 'mask', m(:) );
end

end

function test_cellstr_categorical_table_fcat(f, ic, varargin)

c = cellstr( f );

categorical_table = array2table( categorical(c) );
cellstr_table = array2table( c );

[I, C] = findeach( c, ic, varargin{:} );
[I2, C2] = findeach( categorical(c), ic, varargin{:} );
[I3, C3] = findeach( f, nthcat(f, ic), varargin{:} );
[I4, C4] = findeach( categorical_table, ic, varargin{:} );
[I5, C5] = findeach( cellstr_table, ic, varargin{:} );

if ( ~isempty(ic) )
  C4 = table2array( C4 );
  C5 = table2array( C5 );
end

[~, ind1] = sortrows( categorical(C) );
[~, ind2] = sortrows( categorical(C2) );
[~, ind3] = sortrows( categorical(C3) );
[~, ind4] = sortrows( categorical(C4) );
[~, ind5] = sortrows( categorical(C5) );

assert( isequal(C(ind1, :), C2(ind2, :), C3(ind3, :), C4(ind4, :), C5(ind5, :)) );

I = I(ind1);
I2 = I2(ind2);
I3 = I3(ind3);
I4 = I4(ind4);
I5 = I5(ind5);

assert( isequal(size(I), size(I2), size(I3), size(I4), size(I5)) );
assert( all(cellfun(...
  @(x, y, z, w, o) isequal(size(x), size(y), size(z), size(w), size(o)) ...
  , I, I2, I3, I4, I5)) );

for i = 1:numel(I)
  if ( ~isequal(sort(I{i}), sort(I2{i}), sort(I3{i}), sort(I4{i}), sort(I5{i})) )
    error( 'Non-equal indices' );
  end
end

end