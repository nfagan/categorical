function [PI, PL, II, LI] = nest2(id, I, L)

%   NEST2 -- Prepare index sets with 2 levels of nesting.
%
%     PI = NEST2(id, I, L) for the Mx2 matrix `id`, Mx1 cell array `I`, and 
%     Mx2 matrix `L` returns `PI`, a Px1 cell vector. There is one element 
%     of `PI` for each unique value of `id(:, 1)`. Each element is a vector
%     subset of the input indices `I`. Elements are formed according to the
%     unique values of `id(:, 2)` corresponding to a given unique 
%     `id(:, 1)`.
%
%     [..., PL] = NEST2(...) also returns `PL`, a Px2 cell array whose rows
%     correspond to elements of `PI`. The first column contains scalar
%     labels drawn from `L` corresponding to a unique value of `id(:, 1)`. 
%     The second column contains labels also drawn from `L` identifying the 
%     index elements in the corresponding element of `PI`.
%
%     [..., II] = NEST2(...) also returns `II`, a cell array the same size
%     as `PI`. Each element of `II` corresponds to an element of `PI`. 
%     Each element is a vector of row indices into the input indices `I` 
%     from which the corresponding elements in `PI` were taken.
%
%     [..., LI] = NEST2(...) also returns `LI`, a cell array the same size
%     as `PL`. Each element of this array is a vector the same size as the 
%     corresponding element of `PL`. Each element of each vector is the row 
%     index into the input labels `L` from which the corresponding element 
%     in `PL` was taken.
%
%     //  EX
%     f = fcat.example();
%     d = rand( rows(f), 21 );
%     % panels are ('dose' and 'day'); lines are 'roi'
%     [I, id, C] = rowsets( 2, f, {'dose', 'day'}, 'roi' );
%     L = plots.cellstr_join( C );
%     [FI, FL] = plots.nest2( id, I, L );
%     p = FI{1}; l = FL(1, :); % first panel, could choose another
%     panel_data = cate( 1, rowifun(@mean, p, d, 'un', 0) );
%     ax = gca(); cla( ax );
%     plots.lines( ax, 1:size(panel_data, 2), panel_data, l{2}, l{1} );
%
%     See also rowsets, plots.bars, plots.nest3, plots.lines

assert_rowsmatch( id, I );
assert_rowsmatch( I, L );

fst = @(x) x(1);

p_I = findeach( id, 1 );
pli = cellfun( fst, p_I );

PI = cell( numel(p_I), 1 );
PL = cell( numel(p_I), 2 );
II = cell( size(PI) );
LI = cell( size(PL) );

for i = 1:numel(p_I)  
  g_I = findeach( id, 2, p_I{i} );
  gli = cellfun( fst, g_I );
  
  pi = cell( numel(g_I), 1 );
  ii = cell( size(pi) );
  for j = 1:numel(g_I)
    gi = g_I{j};
    pi{j} = cat( 1, I{gi} );
    ii{j} = cate( 1, arrayfun(@(g) repmat(g, size(I{g})), gi, 'un', 0) );
  end  
  
  PI{i} = pi;
  PL(i, :) = { L(pli(i), 1), L(gli, 2) };
  II{i} = ii;
  LI(i, :) = { pli(i), gli };  
end

end