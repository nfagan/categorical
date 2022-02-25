function o = nest3(id, I, L)

%   NEST3 -- Prepare index sets with 3 levels of nesting.
%
%     o = NEST3(id, I, L) for the Mx3 matrix `id`, Mx1 cell array `I`, and 
%     Mx3 matrix `L` returns `o`, a cell array. There is one element of 
%     `o` for each unique value of `id(:, 1)`. Each element is a struct 
%     with fields 'I', 'L', 'II', and 'LI'.
%
%     Field 'I' is a unique subset of the input indices `I`. This subset is 
%     shaped into a matrix. Rows of the matrix are formed according to the 
%     unique values of `id(:, 2)` corresponding to a given unique 
%     `id(:, 1)`. Columns are then formed according to the unique values of 
%     `id(:, 3)` corresponding to a given unique `id(:, 2)`.
%
%     Field 'L' is a 1x3 cell array of labels. L{1} is a scalar label drawn 
%     from `L` identifying the element of `o`. L{2} and L{3} are labels 
%     also drawn from `L` identifying the rows and columns, respectively, 
%     of the index matrix 'I'.
%
%     Field 'II' is a matrix the same size as 'I'. Each element is the row
%     index into the input indices `I`.
%
%     Field 'LI' is a cell array the same size as 'L'. Each element is a
%     vector the same size as the corresponding element of 'L'. Each 
%     element of each vector is a row index into the input labels `L`.
%
%     //  EX
%     f = fcat.example();
%     d = fcat.example( 'smalldata' );
%     % panels are ('dose' and 'day'); x is 'image', grouped by 'roi'
%     [I, id, C] = rowsets( 3, f, {'dose', 'day'}, 'image', 'roi' );
%     L = plots.cellstr_join( C );
%     o = plots.nest3( id, I, L );
%     p = o{1}; % first panel, could choose another
%     panel_data = rowifun( @mean, p.I, d );
%     ax = gca(); cla( ax );
%     plots.bars( ax, panel_data, p.L{2}, p.L{3}, p.L{1} );
%
%     See also rowsets, plots.nest1, plots.nest2, plots.bars

assert_rowsmatch( id, I );
assert_rowsmatch( I, L );
fst = @(x) x(1);

p_I = findeach( id, 1 );
pli = cellfun( fst, p_I );

o = cell( size(p_I) );
for i = 1:numel(p_I)
  [m_I, mid] = rowsets( 2, id, 2, 3, 'mask', p_I{i} );
  ni = cellfun( 'prodofsize', m_I );
  if ( ~all(ni == 1) )
    msg = [ 'IDs corresponding to level 3 row sets should be nested' ...
      , ' within level 2 row sets.' ];
    error( msg );
  end

  r = max( mid(:, 1) );
  c = max( mid(:, 2) );

  fi = cell( r, c );
  fii = zeros( r, c );

  fl = { L(pli(i), 1), cell(r, 1), cell(c, 1) };
  fli = { pli(i), zeros(r, 1), zeros(c, 1)  };

  for j = 1:numel(m_I)
    mi = m_I{j};

    fi(mid(j, 1), mid(j, 2)) = I(mi);
    fii(mid(j, 1), mid(j, 2)) = mi;

    fl{2}(mid(j, 1)) = L(mi, 2);
    fl{3}(mid(j, 2)) = L(mi, 3);

    fli{2}(mid(j, 1)) = mi;
    fli{3}(mid(j, 2)) = mi;
  end

  p = struct();
  p.I = fi;
  p.L = fl;
  p.II = fii;
  p.LI = fli;
  o{i} = p;
end

end

% c_I = findeach( id, 2, 'mask', p_I{i} );
% cli = cellfun( fst, c_I );
% 
% rli = [];
% rc = [];
% ii = [];
% mi = {};
% 
% for j = 1:numel(c_I)
%   [r_I, r_C] = findeach( id, 3, 'mask', c_I{j} );
% 
%   ni = cellfun( 'prodofsize', r_I );
%   if ( ~all(ni == 1) )
%     msg = [ 'IDs corresponding to level 3 row sets should be nested' ...
%       , ' within level 2 row sets.' ];
%     error( msg );
%   end
% 
%   r_I = vertcat( r_I{:} );
%   [exists, lb] = ismember( r_C, rc );
%   mi(lb(exists), j) = I(r_I(exists));
%   rc(lb(exists), 1) = r_C(exists);
%   rli(lb(exists), 1) = r_I(exists);
%   ii(lb(exists), j) = r_I(exists);
% 
%   if ( ~all(exists) )
%     rest = I(r_I(~exists));
%     mi(end+1:end+numel(rest), j) = rest;
%     rc(end+1:end+numel(rest), 1) = r_C(~exists);
%     rli(end+1:end+numel(rest), 1) = r_I(~exists);
%     ii(end+1:end+numel(rest), j) = r_I(~exists);
%   end
% end
% 
% p = struct();
% p.I = mi;
% p.L = { L(pli(i), 1), L(cli, 2), L(rli, 3) };
% p.II = ii;
% p.LI = { pli(i), cli, rli };
% o{i} = p;