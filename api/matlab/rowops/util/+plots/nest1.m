function o = nest1(id, I, L)

%   NEST1 -- Prepare index sets with 1 level of nesting.
%
%     o = NEST1(id, I, L) for the Mx1 vector `id`, Mx1 cell array `I`, 
%     and Mx1 vector `L` returns `o`, a cell array. There is one element of 
%     `o` for each unique value of `id(:, 1)`. Each element is a struct 
%     with fields 'I' and 'L'.
%
%     Field 'I' is the vector subset of `I` corresponding to one unique 
%     value of `id(:, 1)`. Field 'L' is the scalar label drawn from `L` 
%     identifying the element of `o`, and the elements of 'I'. 
%
%     //  EX
%     f = fcat.example();
%     d = fcat.example( 'smalldata' );
%     % panels are ('dose' and 'day')
%     [I, id, C] = rowsets( 1, f, {'dose', 'day'} );
%     L = plots.cellstr_join( C );
%     o = plots.nest1( id, I, L );
%     p = o{1}; % first panel, could choose another.
%     panel_data = cate( 1, cellfun(@(x) d(x), p.I, 'un', 0) );
%     ax = gca(); cla( ax );
%     plots.hist( ax, panel_data, p.L{1} );
%
%     See also rowsets, plots.hist, plots.nest2, plots.nest3,
%       plots.lines

assert_rowsmatch( id, I );
assert_rowsmatch( I, L );

fst = @(x) x(1);

p_I = findeach( id, 1 );
pli = cellfun( fst, p_I );

o = cell( size(p_I) );
for i = 1:numel(p_I)
  prep = struct();
  prep.I = I(p_I{i});
  prep.L = { L(pli(i), 1) };
  o{i} = prep;
end

end