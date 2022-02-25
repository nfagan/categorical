function [PI, PL, II, LI] = nest1(id, I, L)

%   NEST1 -- Prepare index sets with 1 level of nesting.
%
%     PI = NEST1(id, I, L) for the Mx1 vector `id`, Mx1 cell array `I`, 
%     and Mx1 vector `L` returns `PI`, a Px1 cell vector. There is one 
%     element of `PI` for each unique value of `id(:, 1)`. Each element is
%     the vector subset of `I` corresponding to one unique value of 
%     `id(:, 1)`. 
%
%     [..., PL] = NEST1(...) also returns `PL`, a Px1 cell array whose 
%     elements correspond to `PI`. Each element is the scalar label drawn 
%     from `L` identifying the the corresponding `PI`.
%
%     [..., II] = NEST1(...) also returns `II`, a cell array the same size
%     as `PI`. Each element of `II` is a vector the same size as the
%     corresponding element of `PI`. Each element of this vector is the row 
%     index into the input indices `I` from which the corresponding element
%     in `PI` was taken.
%
%     [..., LI] = NEST1(...) also returns `LI`, a cell array the same size
%     as `PL`. Each element of this array is a vector the same size as the 
%     corresponding element of `PL`. Each element of each vector is the row 
%     index into the input labels `L` from which the corresponding element 
%     in `PL` was taken.
%
%     //  EX
%     f = fcat.example();
%     d = fcat.example( 'smalldata' );
%     % panels are ('dose' and 'day')
%     [I, id, C] = rowsets( 1, f, {'dose', 'day'} );
%     L = plots.cellstr_join( C );
%     [FI, FL] = plots.nest1( id, I, L );
%     p = FI{1}; l = FL(1, :); % first panel, could choose another.
%     panel_data = cate( 1, rowifun(@identity, p, d, 'un', 0) );
%     ax = gca(); cla( ax );
%     plots.hist( ax, panel_data, l{1} );
%
%     See also rowsets, plots.hist, plots.nest2, plots.nest3,
%       plots.lines

assert_rowsmatch( id, I );
assert_rowsmatch( I, L );

fst = @(x) x(1);

p_I = findeach( id, 1 );
pli = cellfun( fst, p_I );

PI = cell( numel(p_I), 1 );
PL = cell( numel(p_I), 1 );
II = cell( size(PI) );
LI = cell( size(PL) );

for i = 1:numel(p_I)
  PI{i} = I(p_I{i});
  II{i} = p_I{i};
  
  PL(i) = L(pli(i), 1);
  LI{i} = pli(i);
end

end