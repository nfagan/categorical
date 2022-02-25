function o = nest3(id, I, L)

%   NEST3 -- Prepare index sets with 3 levels of nesting.
%
%     o = NEST3(id, I, L) for the Mx3 matrix `id`, Mx1 cell array `I`, and 
%     Mx3 matrix `L` returns `o`, a cell array. There is one element of 
%     `o` for each unique value of `id(:, 1)`. Each element is a struct 
%     with fields 'I' and 'L'.
%
%     Field 'I' is a unique subset of the input indices `I`. This subset is 
%     shaped into a matrix. Columns of the matrix are formed according 
%     to the unique values of `id(:, 2)` corresponding to a given unique
%     `id(:, 1)`. Rows are then formed according to the unique values of 
%     `id(:, 3)` corresponding to a given unique `id(:, 2)`.
%
%     Field 'L' is a 1x3 cell array of labels. L{1} is a scalar label drawn 
%     from `L` identifying the element of `o`. L{2} and L{3} are labels 
%     also drawn from `L` identifying the columns and rows, respectively, 
%     of the index matrix 'I'.
%
%     //  EX
%     f = fcat.example();
%     d = fcat.example( 'smalldata' );
%     % panels are ('dose' and 'day'); groups are 'roi'; x is 'image';
%     [I, id, C] = rowsets( 3, f, {'dose', 'day'}, 'roi', 'image' );
%     L = plots.cellstr_join( C );
%     o = plots.nest3( id, I, L );
%     p = o{1}; % first panel, could also choose 2nd or 3rd
%     panel_data = cellfun( @(x) mean(d(x)), p.I );
%     ax = gca(); cla( ax );
%     plots.bars( ax, panel_data, p.L{3}, p.L{2}, p.L{1} );
%
%     See also rowsets, plots.nest1, plots.nest2, plots.bars

assert_rowsmatch( id, I );
assert_rowsmatch( I, L );
fst = @(x) x(1);

p_I = findeach( id, 1 );
pli = cellfun( fst, p_I );

o = cell( size(p_I) );
for i = 1:numel(p_I)  
  g_I = findeach( id, 2, 'mask', p_I{i} );
  gli = cellfun( fst, g_I );
  
  xli = [];
  mxc = [];
  m_I = {};
  for j = 1:numel(g_I)
    [x_I, x_C] = findeach( id, 3, 'mask', g_I{j} );
    
    ni = cellfun( 'prodofsize', x_I );
    if ( ~all(ni == 1) )
      msg = [ 'IDs corresponding to X row sets should be nested' ...
        , ' within group row sets.' ];
      error( msg );
    end
    
    x_I = vertcat( x_I{:} );    
    [exists, lb] = ismember( x_C, mxc );
    m_I(lb(exists), j) = I(x_I(exists));
    mxc(lb(exists), 1) = x_C(exists);
    xli(lb(exists), 1) = x_I(exists);
    
    rest = I(x_I(~exists));
    m_I(end+1:end+numel(rest), j) = rest;
    mxc(end+1:end+numel(rest), 1) = x_C(~exists);
    xli(end+1:end+numel(rest), 1) = x_I(~exists);
  end
  
  prep = struct();
  prep.I = m_I;
  prep.L = { L(pli(i), 1), L(gli, 2), L(xli, 3) };
  o{i} = prep;
end

end