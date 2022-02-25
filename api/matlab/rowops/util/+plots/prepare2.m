function o = prepare2(id, I, L)

%   PREPARE2 -- Prepare index sets with 2 levels of nesting.
%
%     o = PREPARE2(id, I, L) for the Mx2 matrix `id`, Mx1 cell array `I`, 
%     and Mx2 matrix `L` returns `o`, a cell array. There is one element of 
%     `o` for each unique value of `id(:, 1)`. Each element is a struct 
%     with fields 'I', 'gl', and 'pl'.
%
%     Field 'I' is a vector subset of the input indices `I`. This subset
%     is formed according to the unique values of `id(:, 2)` corresponding 
%     to a given unique `id(:, 1)`.
%
%     Field 'pl' is a scalar label drawn from `L` identifying the element 
%     of `o`. Field 'gl' contains labels also drawn from `L` identifying 
%     elements of the index subset 'I'.
%
%     //  EX
%     f = fcat.example();
%     d = rand( rows(f), 21 );
%     % panels are ('dose' and 'day'); lines are 'roi'
%     [I, id, C] = rowsets( 2, f, {'dose', 'day'}, 'roi' );
%     L = cellfun( @strjoin, C, 'un', 0 );
%     o = plots.prepare2( id, I, L );
%     p = o{1}; % first panel, could also choose 2nd or 3rd
%     panel_data = cate( 1, cellfun(@(x) mean(d(x, :), 1), p.I, 'un', 0) );
%     ax = gca(); cla( ax );
%     plots.lines( ax, 1:size(panel_data, 2), panel_data, p.gl, p.pl );
%
%     See also rowsets, plots.bars, plots.prepare3, plots.lines

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
  
  gl = L(gli, 2);
  pl = L(pli(i), 1);
  
  prep = struct();
  prep.I = m_I;
  prep.gl = gl;
  prep.pl = pl;
  o{i} = prep;
end

end