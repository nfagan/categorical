function [I, id, C] = rowsets(n, X, varargin)

%   ROWSETS -- Partition row indices into subsets by unique row products.
%
%     I = ROWSETS( 1, X, ix1 ) for the 2D array `X` and vector of column 
%     subscripts `ix1` partitions the full set of row indices into `X`, 
%     that is, `1:size(X, 1)`, into subsets `I`. There is one subset for 
%     each unique row of `X(:, ix1)` columns. Each element of `I` is the
%     set of rows of `X` containing one unique row of `X(:, ix1)` columns.
%
%     I = ROWSETS( 2, X, ix1, ix2 ) for the vectors of column subscripts
%     `ix1` and `ix2` first computes indices of unique rows over `ix1` 
%     columns, as above. Within each index set, the subset of unique
%     rows over `ix2` columns is then computed. Each element of `I` is
%     still a distinct subset of row indices into `X`. There is one element
%     for each unique combination of (`ix1` * `ix2`) columns. Each element
%     of `I` is the set of rows of `X` matching one unique product of 
%     (`X(:, ix1)` * `X(:, ix2)`) columns.
%
%     I = ROWSETS( N, X, ix1, ix2, ... ixN ) works by extension of the
%     above to compute indices of the unique products of columns
%     (`ix1` * `ix2` * ... `ixN`). 
%
%     [I, id] = ROWSETS( N, X, ... ) also returns an MxN `id` matrix with
%     one row for each element of `I`. Each column of `id` contains 
%     integers identifying a unique row of `X` evaluated over the
%     corresponding vector of column subscripts `ixi`.
%
%     [..., C] = ROWSETS(...) also returns an MxN cell matrix `C` with one
%     row for each element of `I`. Each row of `C` constitutes a unique 
%     product of unique rows of `X`. Each column is a unique row of `X`
%     evaluted over the corresponding vector of column subscripts.
%
%     [...] = ROWSETS(..., 'mask', mask) for the logical or numeric vector
%     `mask` operates on the subset of rows `X(mask, :)` and returns 
%     indices that are a subset of `mask`.
%
%     A vector of column subscripts can be empty. This corresponds to
%     specifying the complete set of row indices `1:size(X, 1)` for that
%     input. Elements of `C` corresponding to an empty vector of column 
%     subscripts are given the char label '<unspecified>'.
%
%     [...] = ROWSETS( 'unspecified_label', value ) uses `value`, which
%     can be of any type, in place of '<unspecified>'.
%
%     [...] = ROWSETS(..., 'preserve', nth) for the scalar `nth` computes
%     unique rows for `X(:, ixnth)` through `X(:, ixN)` from the complete 
%     set of rows `1:size(X, 1)`. `I` then contains indices of all possible 
%     combinations of unique row sets for levels nth:N. In this case, 
%     `I` may contain empty vectors corresponding to row sets that do not 
%     exist in `X`.
%
%     [I, id, L] = ROWSETS( ..., 'to_string', true ); converts the cell
%     array of potentially heterogeneous arrays `C` to a cell array of
%     strings `L` and sorts by rows of `L`.
%
%     EX //
%
%     T = struct2table( load('patients') );
%     [I, id, C] = rowsets( 3, T ...
%       , 'Gender', 'Smoker', 'SelfAssessedHealthStatus', 'to_string', 1 );
%     plots.simplest_barsets( T.Diastolic, I, id, C );
%     xlabel( 'Smoker' );
%     ylabel( 'Diastolic' );
%
%     See also findeach, unique, groupi, grp2idx, fcat

validateattributes( n, {'numeric'}, {'scalar', 'integer', 'positive'}, mfilename, 'n' );
validateattributes( X ...
  , {'numeric', 'fcat', 'string', 'cell', 'categorical', 'table'}, {'2d'}, mfilename, 'f' );

narginchk( 2+n, inf );

coli = reconcile_column_indices( X, varargin(1:n) );
varargin = varargin(n+1:end);

defaults = struct();
defaults.mask = [];
defaults.unspecified_label = '<unspecified>';
defaults.preserve = [];
defaults.preserve_masked = false;
defaults.sort_by_index = false;
defaults.to_string = false;
[params, provided] = shared_utils.general.parsestruct( defaults, varargin );

preserve = params.preserve;
if ( ~isempty(preserve) )
  validateattributes( preserve, {'numeric'}, {'scalar', 'integer'}, mfilename, 'preserve' );
  assert( preserve >= 1 && preserve <= n, 'Expected preserve in range [1, %d].', n );
end
if ( isempty(params.preserve_masked) )
  params.preserve_masked = false;
end

no_mask = rowmask( X );
if ( ismember('mask', provided) )
  mask = find_if_logical( params.mask );
else
  mask = no_mask;
end

unspecified = { params.unspecified_label };

I = {};
C = cell( 0, n );
id = zeros( 0, n );
cs = {};
is = {};

sets = make_set( mask, 0, zeros(1, n) );
stp = 1;

while ( ~isempty(sets) )
  set = sets(end);
  sets(end) = [];
  assert(set.ind(set.depth+1) == 0);
  depth1 = set.depth + 1;
  ind = set.ind;
  
  if ( ~isempty(preserve) && depth1 >= preserve )
    if ( params.preserve_masked )
      pi = mask;
    else
      pi = no_mask;
    end
    
    if ( is_unspecified(X, coli{depth1}) )
      cc = unspecified;
      ic = { set.mask };
    else
      [~, cc] = generalized_findall( X, coli{depth1}, pi );
      ic = generalized_find_combinations( X, coli{depth1}, cc, set.mask );
    end
  else
    [ic, cc] = generalized_findall_check_unspecified( ...
      X, coli{depth1}, set.mask, unspecified );
  end
  
  for i = 1:numel(ic)
    ind(depth1) = i;
    cs{depth1, i} = cc(i, :);
    is(depth1, i) = ic(i);
    
    if ( depth1 == n )
      I{stp, 1} = ic{i};
      id(stp, :) = ind;
      
      for j = 1:n
        C(stp, j) = cs(j, ind(j));
      end
      
      stp = stp + 1;
    else
      sets(end+1) = make_set( ic{i}, depth1, ind );
    end
  end
end

if ( params.sort_by_index )
  [~, ord] = sort( min_index(I) );
  I = reshape( I(ord), size(I) );
  C = reshape( C(ord, :), size(C) );
end

if ( nargout > 1 )
  for i = 1:size(id, 2)
    id(:, i) = uniquerow_ic( vertcat(C{:, i}) );
  end
end

if ( params.to_string )
  C = plots.cellstr_join( C );
  [C, ord] = sortrows( C );
  I = I(ord);
  id = id(ord, :);
end

end

function s = make_set(mask, depth, ind)
s = struct( 'mask', mask, 'depth', depth, 'ind', ind );
end

function [i, c] = generalized_findall_check_unspecified(X, coli, mask, unspecified)

if ( is_unspecified(X, coli) )
  c = unspecified;
  i = { mask };
else
  [i, c] = generalized_findall( X, coli, mask );
end

end

function I = find_combinations_eq(f, each, C, mask)

has_mask = nargin > 3;

if ( has_mask )
  tf = true( numel(mask), 1 );
else
  tf = true( size(f, 1), 1 );
end

I = cell( size(C, 1), 1 );

for i = 1:size(C, 1)
  for j = 1:size(C, 2)
    sel = C(i, j);
    if ( has_mask )
      tf = tf & f(mask, each(j)) == sel;
    else
      tf = tf & f(:, each(j)) == sel;
    end
  end
  I{i} = find( tf );
  if ( has_mask )
    I{i} = mask(I{i});
  end
  tf(:) = true;
end

end

function I = find_combinations_strcmp(f, each, C, mask)

has_mask = nargin > 3;

if ( has_mask )
  tf = true( numel(mask), 1 );
else
  tf = true( size(f, 1), 1 );
end

I = cell( size(C, 1), 1 );

for i = 1:size(C, 1)
  for j = 1:size(C, 2)
    sel = C(i, j);
    if ( has_mask )
      tf = tf & strcmp( f(mask, each(j)), sel );
    else
      tf = tf & strcmp( f(:, each(j)), sel );
    end
  end
  I{i} = find( tf );
  if ( has_mask )
    I{i} = mask(I{i});
  end
  tf(:) = true;
end

end

function I = find_combinations_table(f, each, C, mask)

has_mask = nargin > 3;

if ( has_mask )
  tf = true( numel(mask), 1 );
else
  tf = true( size(f, 1), 1 );
end

I = cell( size(C, 1), 1 );

for i = 1:size(C, 1)
  for j = 1:size(C, 2)    
    sel = C{i, j};
    if ( ~isscalar(sel) )
      error( 'Non-scalar table entries are not supported.' );
    end    
    if ( has_mask )
      v = f{mask, each(j)};
      if ( iscell(v) )
        tf = tf & strcmp( v, sel );
      else
        tf = tf & v == sel;
      end
    else
      v = f{:, each(j)};
      if ( iscell(v) )
        tf = tf & strcmp( v, sel );
      else
        tf = tf & v == sel;
      end
    end
  end
  I{i} = find( tf );
  if ( has_mask )
    I{i} = mask(I{i});
  end
  tf(:) = true;
end

end

function I = generalized_find_combinations(f, each, C, varargin)

if ( isa(f, 'fcat') )
  I = cell( size(C, 1), 1 );
  for i = 1:size(C, 1)
    I{i} = find( f, C(i, :), varargin{:} );
  end
else
  each = find_if_logical( each );
  if ( numel(each) ~= size(C, 2) )
    error( ['Number of column identifiers (`each`) must match the number of' ...
      , ' rows of unique column combinations.'] );
  end
  
  if ( isnumeric(f) || iscategorical(f) )
    I = find_combinations_eq( f, each, C, varargin{:} );
  elseif ( iscellstr(f) || isstring(f) )
    I = find_combinations_strcmp( f, each, C, varargin{:} );
  elseif ( istable(f) )
    I = find_combinations_table( f, each, C, varargin{:} );
  else
    error( ['Expected fcat, table, categorical, cellstr, or string array' ...
      , ' got "%s".'], class(f) );
  end
end

end

function ic = uniquerow_ic(a)

if ( iscell(a) )
  [~, ic] = cellstr_unique_rowi( a );
else
  [~, ~, ic] = unique( a, 'rows', 'stable' );
end

end

function [c, i] = uniquerows(a)

if ( iscell(a) )
  [ia, i] = cellstr_unique_rowi( a );
  c = a(ia, :);
else
  [c, ~, i] = unique( a, 'rows', 'stable' );
end

end

function each = fcat_each(a, each)

if ( islogical(each) )
  each = find( each );
end
if ( isnumeric(each) )
  each = nthcat( a, each );
end

end

function [i, c] = generalized_findall(a, each, varargin)

if ( isa(a, 'fcat') )
  [i, c] = findall( a, fcat_each(a, each), varargin{:} );
  c = c';
else
  if ( ~ismatrix(a) )
    error( 'Expected 2D array.' );
  end
  if ( nargin < 3 )
    [c, i] = uniquerows( a(:, each) );
    i = groupi( i );
  else
    m = varargin{1};
    [c, i] = uniquerows( a(m, each) );
    i = cellfun( @(x) m(x), groupi(i), 'un', 0 );
  end
end

end

function tf = is_unspecified(f, a)

if ( isa(f, 'fcat') )
  tf = ~ischar( a ) && isempty( a );
else
  if ( islogical(a) )
    tf = ~any( a );
  else
    tf = isempty( a );
  end
end

end

function i = find_if_logical(i)
if ( islogical(i) )
  i = find( i );
end
end

function coli = reconcile_column_indices(X, coli)

if ( istable(X) )
  for i = 1:numel(coli)
    coli{i} = table_variable_indices( X, coli{i} );
  end
end

end

function mini = min_index(I)

mini = nan( numel(I), 1 );
for i = 1:numel(I)
  if ( ~isempty(I{i}) )
    mini(i) = min(I{i});
  end
end

end