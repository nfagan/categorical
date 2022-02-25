function o = nest2(id, I, L)

%   NEST2 -- Prepare index sets with 2 levels of nesting.
%
%     o = NEST2(id, I, L) for the Mx2 matrix `id`, Mx1 cell array `I`, and 
%     Mx2 matrix `L` returns `o`, a cell array. There is one element of `o` 
%     for each unique value of `id(:, 1)`. Each element is a struct with 
%     fields 'I' and 'L'.
%
%     Field 'I' is a vector subset of the input indices `I`. This subset
%     is formed according to the unique values of `id(:, 2)` corresponding 
%     to a given unique `id(:, 1)`.
%
%     Field 'L' is a 1x2 cell array of labels. L{1} is a scalar label drawn 
%     from `L` identifying the element of `o`. L{2} is a vector of labels 
%     also drawn from `L` identifying elements of the index subset 'I'.
%
%     //  EX
%     f = fcat.example();
%     d = rand( rows(f), 21 );
%     % panels are ('dose' and 'day'); lines are 'roi'
%     [I, id, C] = rowsets( 2, f, {'dose', 'day'}, 'roi' );
%     L = plots.cellstr_join( C );
%     o = plots.nest2( id, I, L );
%     p = o{1}; % first panel, could also choose 2nd or 3rd
%     panel_data = cate( 1, cellfun(@(x) mean(d(x, :), 1), p.I, 'un', 0) );
%     ax = gca(); cla( ax );
%     plots.lines( ax, 1:size(panel_data, 2), panel_data, p.L{2}, p.L{1} );
%
%     See also rowsets, plots.bars, plots.nest3, plots.lines

assert_rowsmatch( id, I );
assert_rowsmatch( I, L );

fst = @(x) x(1);

p_I = findeach( id, 1 );
pli = cellfun( fst, p_I );

o = cell( size(p_I) );
for i = 1:numel(p_I)  
  g_I = findeach( id, 2, 'mask', p_I{i} );
  gli = cellfun( fst, g_I );
  
  m_I = cell( numel(g_I), 1 );
  for j = 1:numel(g_I)
    m_I(j) = I(g_I{j});
  end
  
  prep = struct();
  prep.I = m_I;
  prep.L = { L(pli(i), 1), L(gli, 2) };
  o{i} = prep;
end

end