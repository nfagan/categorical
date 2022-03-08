function [PI, PL, II, LI] = nest3(id, I, L)

%   NEST3 -- Prepare index sets with 3 levels of nesting.
%
%     PI = NEST3(id, I, L) for the Mx3 matrix `id`, Mx1 cell array `I`, and 
%     Mx3 matrix `L` returns `PI`, a Px1 cell vector. There is one element 
%     of `PI` for each unique value of `id(:, 1)`. Each element is a matrix
%     constructed from a distinct subset of the input indices `I`. Rows of 
%     the matrix are formed according to the unique values of `id(:, 2)` 
%     corresponding to a given unique `id(:, 1)`. Columns are then formed 
%     according to the unique values of `id(:, 3)` corresponding to a given 
%     unique `id(:, 2)`.
%
%     [..., PL] = NEST3(...) also returns `PL`, a Px3 cell array whose rows
%     correspond to elements of `PI`. The first column contains scalar
%     labels drawn from `L` corresponding to a unique value of `id(:, 1)`. 
%     The second and third columns are labels also drawn from `L` 
%     identifying the rows and columns, respectively, of the index matrix 
%     in the corresponding element of `PI`.
%
%     [..., II] = NEST3(...) also returns `II`, a cell array the same size
%     as `PI`. Each element of `II` corresponds to an element of `PI`. 
%     Each element is a vector of row indices into the input indices `I` 
%     from which the corresponding elements in `PI` were taken.
%
%     [..., LI] = NEST3(...) also returns `LI`, a cell array the same size
%     as `PL`. Each element of this array is a vector the same size as the 
%     corresponding element of `PL`. Each element of each vector is the row 
%     index into the input labels `L` from which the corresponding element 
%     in `PL` was taken.
%
%     //  EX
%     f = fcat.example();
%     d = fcat.example( 'smalldata' );
%     % panels are ('dose' and 'day'); x is 'image', grouped by 'roi'
%     [I, id, C] = rowsets( 3, f, {'dose', 'day'}, 'image', 'roi' );
%     L = plots.cellstr_join( C );
%     [FI, FL] = plots.nest3( id, I, L );
%     p = FI{1}; l = FL(1, :); % first panel, could choose another
%     panel_data = rowifun( @mean, p, d );
%     ax = gca(); cla( ax );
%     plots.bars( ax, panel_data, l{2}, l{3}, l{1} );
%
%     See also rowsets, plots.nest1, plots.nest2, plots.bars

validateattributes( id, {'numeric'}, {}, mfilename, 'id' );
validateattributes( I, {'cell'}, {}, mfilename, 'I' );

assert_rowsmatch( id, I );
assert_rowsmatch( I, L );
assert( isequal(size(id), size(L)), 'id and label sizes do not correspond.' );
assert( size(id, 2) >= 3 ...
  , 'id and labels should be matrices with at least 3 columns.' );

p_I = findeach( id, 1 );
pli = cellfun( @(x) x(1), p_I );

PI = cell( numel(p_I), 1 );
PL = cell( numel(p_I), 3 );
II = cell( size(PI) );
LI = cell( size(PL) );

for i = 1:numel(p_I)
  [m_I, mid] = rowsets( 2, id, 2, 3, 'mask', p_I{i} );

  r = max( mid(:, 1) );
  c = max( mid(:, 2) );

  fi = cell( r, c );
  fii = cell( r, c );

  fl = { L(pli(i), 1), cell(r, 1), cell(c, 1) };
  fli = { pli(i), zeros(r, 1), zeros(c, 1)  };

  for j = 1:numel(m_I)
    mi = m_I{j};

    fi{mid(j, 1), mid(j, 2)} = cat( 1, I{mi} );
    fii{mid(j, 1), mid(j, 2)} = ...
      cate( 1, arrayfun(@(m) repmat(m, size(I{m})), mi, 'un', 0) );

    fl{2}(mid(j, 1)) = L(mi(1), 2);
    fl{3}(mid(j, 2)) = L(mi(1), 3);

    fli{2}(mid(j, 1)) = mi(1);
    fli{3}(mid(j, 2)) = mi(1);
  end
  
  PI{i} = fi;
  PL(i, :) = fl;
  II{i} = fii;
  LI(i, :) = fli;
end

end